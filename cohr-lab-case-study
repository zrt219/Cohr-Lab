# CASE STUDY · FULL-STACK WEB3 DAPP

# COHR LAB

**Modeling real-world semiconductor laser fabrication as an immutable on-chain state machine — deterministic batch lifecycle tracking from crystal growth to final pigtail on XRPL EVM.**

---

## Stack

- XRPL EVM
- Solidity 0.8.x
- ethers.js v5
- Foundry
- HTML Canvas
- Surge

---

## Deployment

- **Live:** https://cohr-lab.vercel.app/
- **Contract:** `0x870201041262975C5b40941e1fE85792Fb2dfF3D`
- **Chain ID:** `1449000` (XRPL EVM Testnet)

---

## Key Metrics

| Metric | Value |
|---|---|
| Contract | Solidity 0.8.x |
| Pipeline Stages | 6 (Crystal → Pigtail) |
| Write Surface | 4+ write functions |
| Read Surface | Full batch + step retrieval |
| Deploy Time | < 5 minutes |
| Frontend | Wallet-connected, no backend |
| Hosting | Surge |
| State Model | Deterministic irreversible lifecycle |

---

# ⚙ Executive Summary

COHR LAB is a full-stack Web3 application that encodes semiconductor laser fabrication as a deterministic on-chain state machine deployed to the XRPL EVM Sidechain. The system tracks a production batch from **LEC crystal growth** through **wafering**, **MOCVD epitaxy**, **photolithography**, **LIV probe testing**, and final **cleave + pigtail packaging**, with each irreversible physical transition represented by a permanent on-chain state advance.

This is not a cosmetic manufacturing theme layered on top of a generic CRUD contract. The contract logic mirrors a real industrial process where the object being tracked undergoes irreversible physical transformation. Once a wafer has advanced to epitaxy, it cannot return to crystal growth. Once the device reaches final pigtail, the lifecycle is complete. The contract enforces that same directionality on-chain through explicit stage and status invariants.

The core engineering challenge was not just the contract. It was the combination of:

- a non-standard EVM chain
- strict lifecycle correctness
- owner-scoped batch control
- event-first auditability
- zero backend architecture
- frontend transaction handling on an RPC environment that does **not** expose `eth_estimateGas` or `eth_gasPrice`

On most mainstream EVM chains, frontend write calls can lean on automatic gas estimation and gas price discovery. XRPL EVM breaks that assumption. Both ethers.js v5 and Foundry attempt those RPC methods by default, and both fail unless every write path is explicitly overridden with hardcoded gas settings and legacy transaction type encoding. That means the application had to absorb infrastructure-level incompatibilities transparently in order to function at all.

The final result is a live, deployed, backendless full-stack dApp that demonstrates:

- real industrial domain modeling in Solidity
- deterministic state machine architecture
- event-driven traceability
- per-record ownership instead of global admin control
- XRPL EVM-specific transaction engineering
- full-stack deployment from contract to live frontend

---

# ⚙ Problem Statement

Semiconductor laser fabrication is a high-precision, capital-intensive manufacturing process with multiple irreversible stages across a multi-week production cycle. A batch moves through crystal growth, wafer preparation, epitaxial deposition, lithographic patterning, test, and packaging. At each stage, process integrity matters. If a production record is altered after the fact, the credibility of the entire manufacturing history collapses.

Conventional manufacturing execution systems create three structural weaknesses.

## 1. Lifecycle records are mutable

A traditional MES typically stores process history in relational or enterprise databases with administrator write access. That means a yield result, threshold current measurement, or stage completion record can be edited after the fact. There is no cryptographic guarantee that the lifecycle history being presented is the same lifecycle history that actually occurred.

## 2. Manufacturing data is siloed

Different parts of the fabrication line are often managed by different teams, systems, and software surfaces. Crystal growth data may live in one system, lithography data in another, test data in another, and packaging records elsewhere. Even when these systems are internally consistent, they do not naturally produce one append-only, tamper-evident, unified history.

## 3. Third-party auditability is weak

If a downstream buyer, regulator, insurer, or counterparty wants to verify the provenance of a batch, they are typically forced to trust an internally generated record. They cannot independently replay the lifecycle from a public source of truth. Verification becomes institutional rather than cryptographic.

## Why an on-chain fabrication model matters

An on-chain state machine solves those weaknesses directly:

- **immutability** — stage transitions cannot be rewritten once committed
- **unified lifecycle** — all stages exist under one contract and one event log
- **independent auditability** — any party with chain access can verify lifecycle history
- **deterministic sequencing** — invalid transitions are rejected by contract logic
- **operator accountability** — ownership is tied to the address that created the batch

COHR LAB is meaningful because semiconductor fabrication is exactly the kind of domain where irreversible physical processes should have irreversible digital state transitions.

---

# ⚙ Solidity Architecture

## Contract Design Philosophy

The contract targets Solidity 0.8.x and intentionally avoids external dependencies. There is no OpenZeppelin import surface, no library chain, no proxy architecture, and no upgrade pattern. The goal is a **single-purpose, single-file, fully auditable contract** with minimal dependency risk and minimal attack surface.

That design choice matters for three reasons.

### 1. Auditability

A reviewer can inspect the full contract without traversing inherited modules, interfaces, utility libraries, or proxy storage layouts. The logic surface is compact and self-contained.

### 2. Attack surface reduction

Every imported dependency increases the number of assumptions in the system. For a narrow lifecycle-tracking contract, those assumptions are unnecessary overhead. COHR LAB keeps only the logic required to model the fabrication lifecycle.

### 3. Deterministic lifecycle over generic extensibility

This contract is not trying to be a framework. It is trying to be correct. The architecture optimizes for explicit state control, predictable invariants, and direct readability rather than abstract extensibility.

---

## Core Data Model

The entire system centers on a `Batch` struct representing one fabrication batch. The struct stores identity, ownership, lifecycle stage, terminal status, per-stage timestamps, and per-stage notes.

```solidity
struct Batch {
    uint256 id;
    string name;
    address owner;
    uint8 stage; // 0–5
    uint8 status; // 0 = Active, 1 = Complete, 2 = Abandoned
    uint256[6] stageTimestamps;
    string[6] stepNotes;
}
```

### Why this struct design is strong

- `stage` is stored as `uint8`, not `uint256`, reducing footprint
- `status` is an explicit enum-like value, not inferred from booleans
- `stageTimestamps` is a fixed-size array, avoiding dynamic array overhead
- `stepNotes` maps directly to fabrication steps for operator annotations
- ownership is stored **per batch**, not only at contract level

This is a disciplined storage design, not a loosely assembled object.

---

## State Machine Design

COHR LAB is a **linear irreversible state machine**.

```text
createBatch()
  → stage = 0, status = Active

advanceBatch()
  → 0 → 1 → 2 → 3 → 4 → 5

stage == 5
  → status = Complete (terminal)

abandonBatch()
  → status = Abandoned (terminal)
```

The system enforces three key invariants before advancing a batch:

- the batch must still be **Active**
- the current stage must be **less than 5**
- the caller must be the **owner of that batch**

Once a batch reaches stage `5`, the contract atomically sets the batch to `Complete`. Once a batch is abandoned, it is terminal. There is no reactivation path. That is deliberate. Manufacturing history in this system is append-only, not reversible.

---

## Access Control Model

COHR LAB does **not** use a global admin authority. Instead, it uses **per-batch ownership**.

The address that creates a batch becomes that batch’s owner. All write operations verify `msg.sender == batch.owner` before permitting mutation. There is no contract-level super-admin that can arbitrarily rewrite the lifecycle of any batch.

This is a strong architectural decision because it aligns with the real-world operational model:

- different operators may own different production runs
- lifecycle control should be scoped to the record being acted on
- centralized override would be both a security risk and a domain mismatch

In other words, authority belongs at the **data object level**, not just the contract level.

---

## Contract Functions

### Write Surface

These functions modify state and emit lifecycle events.

#### `createBatch(string name)`

Creates a new batch, initializes it at stage `0`, marks status as Active, stores `block.timestamp` at the first stage slot, and assigns `msg.sender` as owner. Emits `BatchCreated`.

#### `advanceBatch(uint256 id)`

Advances the batch one stage forward if it is still active, has not reached the final stage, and the caller is the owner. Records the timestamp for the new stage and emits `BatchAdvanced`. Reaching stage `5` sets the status to Complete.

#### `abandonBatch(uint256 id)`

Sets the batch to Abandoned. This is a terminal state. Further transitions are blocked. Emits `BatchAbandoned`.

#### `setStepNote(uint256 id, uint8 step, string note)`

Adds an annotation to a specific stage index. This does not change the stage or status, but it enriches the lifecycle record with operator context. Emits `StepNoteAdded`.

### Read Surface

These functions expose full batch state for frontend and audit use.

#### `getBatch(uint256 id)`

Returns the full `Batch` struct, including all stage timestamps and notes.

#### `getBatchSteps(uint256 id)`

Returns the timestamp array and notes array separately, which is useful for frontend rendering.

#### `getBatchCount()`

Returns the total number of batches. Enables frontend enumeration of batch IDs.

#### `getBatchesByOwner()`

Iterates over all batches and returns the IDs owned by `msg.sender`. This gives a wallet-scoped operational view of the user’s batches.

---

## Events

Events are not an afterthought in this architecture. They are the primary audit interface.

```solidity
event BatchCreated(uint256 indexed id, string name, address indexed owner, uint256 timestamp);
event BatchAdvanced(uint256 indexed id, uint8 fromStage, uint8 toStage, uint256 timestamp);
event BatchAbandoned(uint256 indexed id, address indexed owner, uint256 timestamp);
event StepNoteAdded(uint256 indexed id, uint8 step, string note, uint256 timestamp);
```

### Why the event design matters

- `id` is indexed for efficient filtering by batch
- `owner` is indexed where relevant for operator-scoped queries
- every state mutation leaves an immutable off-chain reconstruction trail
- historical truth lives in the log stream, not only in current storage

This architecture is built around a critical principle:

> **The event log is the ledger of history. Storage is the latest materialized state.**

That design makes COHR LAB suitable for audit, analytics, and lifecycle replay use cases.

---

# ⚙ Fabrication Stage Mapping

Each on-chain stage corresponds directly to a real semiconductor laser fabrication operation. This is one of the strongest parts of the system: the state machine is not arbitrary. It mirrors real industrial flow.

| ID | Stage Name | Physical Meaning |
|---|---|---|
| 0 | LEC Crystal Growth | InP/GaAs boule pulled from melt using liquid encapsulated Czochralski |
| 1 | Wafering + CMP | Slicing and planarization to prepare wafers for epitaxy |
| 2 | MOCVD Epitaxy | Active laser layers deposited using metal-organic chemical vapor deposition |
| 3 | Photolithography + ICP-RIE | Ridge waveguide definition and plasma etch processing |
| 4 | LIV Probe Testing | Light-current-voltage characterization at wafer level |
| 5 | Cleave + Pigtail | Final cleavage, coating, fiber pigtailing, and sealing |

### Why this mapping is important

Most smart contracts use states like `Pending`, `Approved`, `Shipped`, or `Completed`. Those are generic business workflow abstractions.

COHR LAB uses domain-grounded states:

- they map to actual physical operations
- they reflect irreversible process progression
- they embed manufacturing semantics into contract logic
- they make the smart contract legible to both blockchain engineers and domain operators

This is domain modeling, not theme dressing.

---

# ⚙ XRPL EVM Chain Specifics

## Chain Profile

| Property | Value |
|---|---|
| Chain | XRPL EVM Testnet |
| Chain ID | 1449000 |
| EVM Level | London-compatible |
| Transaction Type | Legacy only (`type: 0`) |
| `eth_estimateGas` | Not supported |
| `eth_gasPrice` | Not supported |
| Required gasLimit | `300000` |
| Required gasPrice | `100 gwei` |
| Foundry Flag | `--legacy` required |

The chain is EVM-compatible at execution level, but **not** tooling-compatible in the way mainstream Ethereum chains are. That distinction matters. A contract may compile correctly, but the surrounding tooling stack can still fail unless transactions are constructed with chain-specific rules.

---

## Practical Consequence

Most standard tooling assumes two things:

1. gas can be estimated automatically
2. gas price can be queried from RPC

XRPL EVM breaks both assumptions.

That means:

- ethers.js write flows can fail before submission
- wallet signing can fail or surface vague RPC errors
- Foundry broadcast scripts can break without legacy mode
- transactions can revert or never fully form unless overrides are explicit

This is why COHR LAB had to enforce a manual transaction pattern across all write calls.

---

## Required ethers.js Override Pattern

Every write call must set explicit overrides:

```javascript
const TX_OVERRIDES = {
  gasLimit: 300000,
  gasPrice: ethers.utils.parseUnits("100", "gwei"),
  type: 0
};
```

And then every write must use those overrides:

```javascript
await contract.createBatch(name, TX_OVERRIDES);
await contract.advanceBatch(batchId, TX_OVERRIDES);
```

Without that pattern, the app is not production-functional on XRPL EVM.

---

## Foundry Deployment Pattern

Foundry must also target legacy transactions:

```bash
forge script script/Deploy.s.sol:DeployCohrLab --rpc-url https://rpc.testnet.xrplevm.org --broadcast --legacy -vvvv
```

If `--legacy` is omitted, Foundry attempts EIP-1559 style transaction construction and the chain rejects the transaction type.

---

# ⚙ Frontend System Design

The frontend is a wallet-connected operational interface with **no backend**, **no API layer**, and **no centralized server logic**. All authoritative state comes directly from the contract and its event log. The frontend is responsible for:

- wallet connection
- transaction preparation
- write submission using XRPL EVM-compatible overrides
- batch enumeration
- owner-scoped reads
- rendering batch stage data
- rendering per-step notes and timestamps

This architecture matters because it proves the system can function fully as an on-chain application rather than relying on an off-chain service layer to patch over blockchain limitations.

## Why “No Backend” Is Important

A lot of so-called Web3 apps still rely heavily on backend coordination. COHR LAB does not. Its core functionality lives directly on-chain:

- state transitions happen in Solidity
- identity comes from wallet ownership
- audit history comes from events
- frontend reads state directly from contract view functions
- deployment is static hosting plus blockchain connectivity

That is a much cleaner demonstration of true full-stack Web3 engineering.

---

# ⚙ Build Log — Engineering War Diary

The final system looks clean, but the engineering path was not frictionless. The case study identifies multiple concrete issues that had to be solved before production stability was reached. These are valuable because they show where real systems break: not in abstract theory, but at the boundary between contract, chain, tooling, and frontend.

## Issue 1 — Transactions silently failing

### Symptom

Write calls did not reliably submit or confirm.

### Root cause

XRPL EVM does not support `eth_estimateGas`, but ethers.js assumes gas estimation is available before constructing transactions. That mismatch caused write paths to fail or behave unpredictably.

### Fix

Hardcode:

- `gasLimit: 300000`
- `gasPrice: 100 gwei`

And pass those overrides on **every** write call.

### Lesson

**Never assume automatic gas estimation exists on non-standard EVM chains.**

## Issue 2 — Missing `eth_gasPrice`

### Symptom

Provider gas discovery failed before transaction submission.

### Root cause

The RPC endpoint omits `eth_gasPrice`, so default provider behavior breaks early in the flow.

### Fix

Set `gasPrice` explicitly rather than relying on provider discovery.

### Lesson

**Provider defaults are part of your chain dependency surface. Validate them explicitly.**

## Issue 3 — Legacy transaction type required

### Symptom

Transactions were rejected with unsupported transaction type behavior.

### Root cause

The chain accepts legacy transactions, not standard EIP-1559 flows from default tool behavior.

### Fix

Set `type: 0` in ethers overrides and use `--legacy` in Foundry broadcast.

### Lesson

**EVM compatibility is not the same thing as full tooling compatibility.**

## Issue 4 — ABI wiring mismatch

### Symptom

A frontend call into `advanceBatch()` appeared to succeed at wiring level but reverted unexpectedly.

### Root cause

The frontend passed raw string input values where the contract expected `uint256`. HTML inputs always yield strings, and type coercion at the contract boundary produced invalid behavior.

### Fix

Explicitly wrap IDs using `ethers.BigNumber.from(...)` before calling contract methods.

### Lesson

**Validate and normalize every external input at the frontend call site before an irreversible on-chain write.**

## Issue 5 — Foundry deployment blocked on Windows environment mismatch

### Symptom

Broadcast and artifact path handling failed during Windows-based deploy attempts.

### Root cause

Foundry path expectations under WSL and Windows shell environments diverged, producing artifact and broadcast path failures.

### Fix

Run Foundry deployment from WSL2 consistently instead of mixing PowerShell or cmd with WSL-based project expectations.

### Lesson

**For cross-platform Solidity toolchains, environment consistency matters as much as the Solidity code.**

## Issue 6 — MetaMask chain add failure

### Symptom

`wallet_addEthereumChain` failed during network onboarding.

### Root cause

The chain ID was provided as an integer, while EIP-3085 expects a hexadecimal string.

### Fix

Convert `1449000` to hex string form before passing it to the wallet chain-add request.

### Lesson

**Wallet integration bugs are often interface-format bugs, not chain bugs.**

## Issue 7 — `getBatchesByOwner()` returned empty results

### Symptom

Owner-scoped reads appeared broken.

### Root cause

The function depends on `msg.sender`, but the frontend invoked it in a provider context before a signer was connected. That caused identity-sensitive reads to resolve against the zero-address execution context.

### Fix

Gate owner-dependent reads behind wallet connection state and connect the contract through a signer rather than provider-only context.

### Lesson

**Any read function that depends on caller identity is not a generic public read. Treat it as signer-context logic.**

## Issue 8 — Static hosting deep-link reload failure

### Symptom

Reloading on nested app routes returned 404s.

### Root cause

Surge serves `index.html` at root but needs a routing fallback for client-side deep links.

### Fix

Add `200.html` as a copy of `index.html` so unmatched routes fall back correctly.

### Lesson

**Static hosting still has routing architecture constraints. Frontend deployment is part of full-stack correctness.**

---

# ⚙ Engineering Principles

The project yields a set of clean engineering rules that generalize beyond COHR LAB.

## 1. Never rely on automatic gas estimation on non-standard EVM chains

If the target chain is not a mainstream EVM environment, assume gas-related RPC methods may be incomplete or absent and design explicit override paths first.

## 2. Encode state explicitly

Boolean flags and implicit lifecycle inference make contracts harder to audit and easier to misuse. Explicit stage and terminal status encoding keeps the logic legible and safe.

## 3. Treat events as the historical truth layer

Current storage shows the latest state. Indexed events provide the forensic history. Design them as first-class architecture.

## 4. Use per-record ownership when the data model demands it

Global admin control is convenient, but often wrong. If records have local authority domains, ownership should live on the record itself.

## 5. Validate all external inputs at the boundary

The frontend is the last mutation layer before an irreversible on-chain change. Strings, numbers, IDs, and step indexes all need explicit normalization.

## 6. Align digital state with physical reality

COHR LAB works because the state machine mirrors the real-world fabrication process. Strong smart contract systems come from accurate domain compression, not arbitrary state labels.

---

# ⚙ Production Path — Forward Look

The current build proves the architecture. The next version would harden it for multi-actor industrial deployment.

## Role-Based Access Control

The current per-batch ownership model works well for single-operator scope, but a production system would likely introduce distinct roles:

- fabrication operator
- quality engineer
- facility manager
- external auditor

A future version could layer OpenZeppelin `AccessControl` or a similar minimal RBAC system over the current model while preserving batch-level authority boundaries.

## Multisig-Controlled Batch Operations

High-value production runs should not rely on a single externally owned account for lifecycle control. Future versions could route critical transitions through a multisig such as Gnosis Safe, especially for:

- abandonment decisions
- terminal completion acknowledgment
- cross-team signoff stages

## Oracle-Based Process Data

The current design tracks stage movement and notes. A stronger production version would attach cryptographically verifiable measurements such as:

- MOCVD growth metrics
- lithography process parameters
- LIV threshold current
- slope efficiency
- batch quality flags

This could be integrated through Chainlink or an internal oracle network bridging validated lab data on-chain.

## Tokenized Batch Representation

Each batch can map naturally to an ERC-721 token without changing the lifecycle model. That would make manufacturing provenance transferable and portable across external systems while keeping lifecycle state in the original contract or an integrated extension layer.

## Cross-Chain Verification

A future system could expose manufacturing proofs to other EVM environments using bridging or proof systems, enabling external verifiers to validate fabrication history without directly querying the source chain every time.

## Extension to Adjacent Industries

The architectural pattern is broader than semiconductor lasers. It generalizes well to any multi-stage irreversible physical process, including:

- pharmaceutical synthesis
- aerospace component fabrication
- rare earth processing
- battery manufacturing
- regulated food traceability

COHR LAB is one specific, strong instantiation of a larger on-chain industrial systems pattern.

---

# ⚙ Final Outcome

COHR LAB was built as a live, fully deployed, wallet-connected full-stack Web3 system with:

- a verified contract deployment
- deterministic batch lifecycle logic
- real fabrication-domain state mapping
- immutable event-based traceability
- XRPL EVM-specific transaction handling
- static frontend hosting with no backend dependency

This makes it a strong demonstration of both **Solidity engineering discipline** and **full-stack Web3 execution under non-standard chain constraints**.

---

## Live Links

- **App:** https://cohrlab.surge.sh
- **Contract:** `0x870201041262975C5b40941e1fE85792Fb2dfF3D`

---

## Summary

COHR LAB demonstrates the ability to:

- model a real industrial system accurately in Solidity
- design deterministic irreversible state machines
- engineer around non-standard EVM RPC limitations
- build wallet-connected frontend flows without backend dependence
- use events as a first-class audit layer
- translate physical manufacturing workflows into verifiable on-chain systems

It is not just a fabrication-themed dApp.

It is a real process architecture compressed into an auditable smart contract system.
