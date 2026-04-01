// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title  CohrLab
 * @notice On-chain manufacturing simulation for Coherent Corp photonics pipeline.
 *         Each batch represents a real InP laser chip traveling through 6 fab steps:
 *         0. LEC Crystal Growth
 *         1. Wafering + CMP
 *         2. MOCVD Epitaxy
 *         3. Photolithography + ICP-RIE
 *         4. LIV Probe Testing
 *         5. Cleave + AR Coat + Pigtailing
 *         (step 6 = complete)
 *
 * @dev    Deployed on XRPL EVM Sidechain Testnet (Chain ID: 1449000)
 *         Compatible: no block.difficulty, no tx.gasprice reliance, no unsupported opcodes.
 */
contract CohrLab {

    /* ─────────────────────────────────────────────
       CONSTANTS
    ───────────────────────────────────────────── */
    uint8  public constant TOTAL_STEPS   = 6;
    uint16 public constant MAX_NAME      = 32;
    uint16 public constant MAX_NOTE      = 128;

    /* ─────────────────────────────────────────────
       CUSTOM ERRORS
    ───────────────────────────────────────────── */
    error NotBatchOwner(uint256 batchId, address caller);
    error BatchAlreadyComplete(uint256 batchId);
    error BatchAbandonedError(uint256 batchId);
    error InvalidBatch(uint256 batchId);
    error InvalidStep(uint8 step);
    error EmptyName();
    error NameTooLong();
    error NoteTooLong();

    /* ─────────────────────────────────────────────
       STRUCTS
    ───────────────────────────────────────────── */
    struct Batch {
        uint256    id;
        string     name;
        address    owner;
        uint8      currentStep;        // 0–5 active, 6 = complete
        uint256    createdAt;
        uint256    lastAdvanced;
        bool       complete;
        bool       abandoned;
        uint256[6] stepTimestamps;     // timestamp when each step was completed
        string[6]  stepNotes;          // optional operator notes per step
    }

    /* ─────────────────────────────────────────────
       STATE
    ───────────────────────────────────────────── */
    uint256 public batchCount;
    mapping(uint256 => Batch)       private _batches;
    mapping(address => uint256[])   private _ownerBatches;

    /* ─────────────────────────────────────────────
       EVENTS
    ───────────────────────────────────────────── */
    event BatchCreated(
        address indexed owner,
        uint256 indexed batchId,
        string          name,
        uint256         timestamp
    );

    event BatchAdvanced(
        address indexed owner,
        uint256 indexed batchId,
        uint8           fromStep,
        uint8           toStep,
        uint256         timestamp
    );

    event BatchCompleted(
        address indexed owner,
        uint256 indexed batchId,
        string          name,
        uint256         duration
    );

    event BatchAbandonedEvent(
        address indexed owner,
        uint256 indexed batchId,
        uint8           atStep,
        uint256         timestamp
    );

    event StepNoteSet(
        address indexed owner,
        uint256 indexed batchId,
        uint8           step,
        string          note
    );

    /* ─────────────────────────────────────────────
       MODIFIERS
    ───────────────────────────────────────────── */
    modifier onlyBatchOwner(uint256 batchId) {
        if (batchId >= batchCount)              revert InvalidBatch(batchId);
        if (_batches[batchId].owner != msg.sender) revert NotBatchOwner(batchId, msg.sender);
        _;
    }

    modifier batchExists(uint256 batchId) {
        if (batchId >= batchCount) revert InvalidBatch(batchId);
        _;
    }

    /* ─────────────────────────────────────────────
       WRITE FUNCTIONS
    ───────────────────────────────────────────── */

    /**
     * @notice Create a new batch and place it at Step 0 (LEC Crystal Growth).
     * @param  name  Human-readable batch name, e.g. "WAFER-042". Max 32 bytes.
     * @return batchId  The ID of the newly created batch.
     */
    function createBatch(string calldata name) external returns (uint256 batchId) {
        uint256 nameLen = bytes(name).length;
        if (nameLen == 0)        revert EmptyName();
        if (nameLen > MAX_NAME)  revert NameTooLong();

        batchId = batchCount++;
        Batch storage b = _batches[batchId];
        b.id           = batchId;
        b.name         = name;
        b.owner        = msg.sender;
        b.currentStep  = 0;
        b.createdAt    = block.timestamp;
        b.lastAdvanced = block.timestamp;
        b.complete     = false;
        b.abandoned    = false;

        _ownerBatches[msg.sender].push(batchId);

        emit BatchCreated(msg.sender, batchId, name, block.timestamp);
    }

    /**
     * @notice Advance a batch to the next manufacturing step.
     *         Progression: 0 → 1 → 2 → 3 → 4 → 5 → 6 (complete).
     * @param  batchId  The batch to advance.
     */
    function advanceBatch(uint256 batchId) external onlyBatchOwner(batchId) {
        Batch storage b = _batches[batchId];
        if (b.complete)  revert BatchAlreadyComplete(batchId);
        if (b.abandoned) revert BatchAbandonedError(batchId);

        uint8 from = b.currentStep;
        uint8 to   = from + 1;

        b.stepTimestamps[from] = block.timestamp;
        b.currentStep          = to;
        b.lastAdvanced         = block.timestamp;

        emit BatchAdvanced(msg.sender, batchId, from, to, block.timestamp);

        if (to >= TOTAL_STEPS) {
            b.complete        = true;
            uint256 duration  = block.timestamp - b.createdAt;
            emit BatchCompleted(msg.sender, batchId, b.name, duration);
        }
    }

    /**
     * @notice Abandon a batch mid-pipeline (e.g. yield failure, contamination).
     * @param  batchId  The batch to abandon.
     */
    function abandonBatch(uint256 batchId) external onlyBatchOwner(batchId) {
        Batch storage b = _batches[batchId];
        if (b.complete)  revert BatchAlreadyComplete(batchId);
        if (b.abandoned) revert BatchAbandonedError(batchId);

        b.abandoned = true;
        emit BatchAbandonedEvent(msg.sender, batchId, b.currentStep, block.timestamp);
    }

    /**
     * @notice Attach an operator note to a step (e.g. "threshold 9.8mA, PASS").
     * @param  batchId  The batch.
     * @param  step     Step index (0–5).
     * @param  note     Note string. Max 128 bytes.
     */
    function setStepNote(uint256 batchId, uint8 step, string calldata note)
        external
        onlyBatchOwner(batchId)
    {
        if (step >= TOTAL_STEPS)           revert InvalidStep(step);
        if (bytes(note).length > MAX_NOTE) revert NoteTooLong();
        _batches[batchId].stepNotes[step] = note;
        emit StepNoteSet(msg.sender, batchId, step, note);
    }

    /* ─────────────────────────────────────────────
       VIEW FUNCTIONS
    ───────────────────────────────────────────── */

    /**
     * @notice Get full batch details.
     */
    function getBatch(uint256 batchId)
        external
        view
        batchExists(batchId)
        returns (
            uint256 id,
            string  memory name,
            address owner,
            uint8   currentStep,
            uint256 createdAt,
            uint256 lastAdvanced,
            bool    complete,
            bool    abandoned
        )
    {
        Batch storage b = _batches[batchId];
        return (
            b.id,
            b.name,
            b.owner,
            b.currentStep,
            b.createdAt,
            b.lastAdvanced,
            b.complete,
            b.abandoned
        );
    }

    /**
     * @notice Get step timestamps and operator notes for a batch.
     */
    function getBatchSteps(uint256 batchId)
        external
        view
        batchExists(batchId)
        returns (uint256[6] memory timestamps, string[6] memory notes)
    {
        return (
            _batches[batchId].stepTimestamps,
            _batches[batchId].stepNotes
        );
    }

    /**
     * @notice Get all batch IDs owned by a given address.
     */
    function getBatchesByOwner(address owner)
        external
        view
        returns (uint256[] memory)
    {
        return _ownerBatches[owner];
    }

    /**
     * @notice Time spent at the current step (seconds).
     *         Returns 0 for complete/abandoned batches.
     */
    function timeAtCurrentStep(uint256 batchId)
        external
        view
        batchExists(batchId)
        returns (uint256)
    {
        Batch storage b = _batches[batchId];
        if (b.complete || b.abandoned) return 0;
        return block.timestamp - b.lastAdvanced;
    }

    /**
     * @notice Total pipeline duration for a batch (seconds).
     *         Live counter for in-progress batches.
     */
    function batchDuration(uint256 batchId)
        external
        view
        batchExists(batchId)
        returns (uint256)
    {
        return block.timestamp - _batches[batchId].createdAt;
    }
}
