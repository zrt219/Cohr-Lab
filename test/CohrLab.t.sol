// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {CohrLab} from "../src/CohrLab.sol";

contract CohrLabTest is Test {

    CohrLab public lab;
    address public alice = address(0xA11CE);
    address public bob   = address(0xB0B);

    function setUp() public {
        lab = new CohrLab();
    }

    /* ───────────────────────────────────────────
       createBatch
    ─────────────────────────────────────────── */

    function test_CreateBatch_Basic() public {
        vm.prank(alice);
        uint256 id = lab.createBatch("WAFER-001");
        assertEq(id, 0);
        assertEq(lab.batchCount(), 1);

        (
            uint256 bid,
            string memory name,
            address owner,
            uint8 step,
            ,
            ,
            bool complete,
            bool abandoned
        ) = lab.getBatch(0);

        assertEq(bid,    0);
        assertEq(name,   "WAFER-001");
        assertEq(owner,  alice);
        assertEq(step,   0);
        assertEq(complete,  false);
        assertEq(abandoned, false);
    }

    function test_CreateBatch_Multiple() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-001");
        lab.createBatch("WAFER-002");
        lab.createBatch("WAFER-003");
        vm.stopPrank();

        assertEq(lab.batchCount(), 3);

        uint256[] memory ids = lab.getBatchesByOwner(alice);
        assertEq(ids.length, 3);
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
        assertEq(ids[2], 2);
    }

    function test_CreateBatch_RevertEmptyName() public {
        vm.prank(alice);
        vm.expectRevert(CohrLab.EmptyName.selector);
        lab.createBatch("");
    }

    function test_CreateBatch_RevertNameTooLong() public {
        // 33 characters — over limit
        vm.prank(alice);
        vm.expectRevert(CohrLab.NameTooLong.selector);
        lab.createBatch("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    }

    function test_CreateBatch_ExactMaxName() public {
        // 32 characters — exactly at limit
        vm.prank(alice);
        uint256 id = lab.createBatch("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        assertEq(id, 0);
    }

    /* ───────────────────────────────────────────
       advanceBatch
    ─────────────────────────────────────────── */

    function test_AdvanceBatch_FullPipeline() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-FULL");

        for (uint8 i = 0; i < 6; i++) {
            (, , , uint8 step, , , bool complete, ) = lab.getBatch(0);
            assertEq(step, i);
            assertEq(complete, false);
            lab.advanceBatch(0);
        }

        (, , , uint8 finalStep, , , bool finalComplete, ) = lab.getBatch(0);
        assertEq(finalStep,    6);
        assertEq(finalComplete, true);
        vm.stopPrank();
    }

    function test_AdvanceBatch_RevertNotOwner() public {
        vm.prank(alice);
        lab.createBatch("WAFER-X");

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.NotBatchOwner.selector, 0, bob));
        lab.advanceBatch(0);
    }

    function test_AdvanceBatch_RevertAlreadyComplete() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-DONE");
        for (uint8 i = 0; i < 6; i++) lab.advanceBatch(0);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.BatchAlreadyComplete.selector, 0));
        lab.advanceBatch(0);
        vm.stopPrank();
    }

    function test_AdvanceBatch_RevertAbandoned() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-ABN");
        lab.abandonBatch(0);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.BatchAbandonedError.selector, 0));
        lab.advanceBatch(0);
        vm.stopPrank();
    }

    function test_AdvanceBatch_InvalidBatch() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.InvalidBatch.selector, 999));
        lab.advanceBatch(999);
    }

    /* ───────────────────────────────────────────
       abandonBatch
    ─────────────────────────────────────────── */

    function test_AbandonBatch() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-YIELD-FAIL");
        lab.advanceBatch(0); // to step 1
        lab.abandonBatch(0);
        vm.stopPrank();

        (, , , , , , bool complete, bool abandoned) = lab.getBatch(0);
        assertEq(complete,  false);
        assertEq(abandoned, true);
    }

    function test_AbandonBatch_RevertNotOwner() public {
        vm.prank(alice);
        lab.createBatch("WAFER-Q");

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.NotBatchOwner.selector, 0, bob));
        lab.abandonBatch(0);
    }

    function test_AbandonBatch_RevertAlreadyAbandoned() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-Q2");
        lab.abandonBatch(0);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.BatchAbandonedError.selector, 0));
        lab.abandonBatch(0);
        vm.stopPrank();
    }

    function test_AbandonBatch_RevertAlreadyComplete() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-FULL2");
        for (uint8 i = 0; i < 6; i++) lab.advanceBatch(0);
        vm.expectRevert(abi.encodeWithSelector(CohrLab.BatchAlreadyComplete.selector, 0));
        lab.abandonBatch(0);
        vm.stopPrank();
    }

    /* ───────────────────────────────────────────
       setStepNote
    ─────────────────────────────────────────── */

    function test_SetStepNote() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-NOTE");
        lab.advanceBatch(0); // complete step 0
        lab.setStepNote(0, 0, "threshold 9.8mA, PASS");
        vm.stopPrank();

        (, string[6] memory notes) = lab.getBatchSteps(0);
        assertEq(notes[0], "threshold 9.8mA, PASS");
    }

    function test_SetStepNote_RevertInvalidStep() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-NOTE2");
        vm.expectRevert(abi.encodeWithSelector(CohrLab.InvalidStep.selector, 6));
        lab.setStepNote(0, 6, "bad step");
        vm.stopPrank();
    }

    function test_SetStepNote_RevertNoteTooLong() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-NOTE3");
        // 129 characters
        string memory longNote = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        vm.expectRevert(CohrLab.NoteTooLong.selector);
        lab.setStepNote(0, 0, longNote);
        vm.stopPrank();
    }

    /* ───────────────────────────────────────────
       view functions
    ─────────────────────────────────────────── */

    function test_TimeAtCurrentStep() public {
        vm.prank(alice);
        lab.createBatch("WAFER-TIME");

        vm.warp(block.timestamp + 300);
        uint256 t = lab.timeAtCurrentStep(0);
        assertGe(t, 300);
    }

    function test_TimeAtCurrentStep_ZeroWhenComplete() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-TIMEC");
        for (uint8 i = 0; i < 6; i++) lab.advanceBatch(0);
        assertEq(lab.timeAtCurrentStep(0), 0);
        vm.stopPrank();
    }

    function test_BatchDuration() public {
        vm.prank(alice);
        lab.createBatch("WAFER-DUR");

        vm.warp(block.timestamp + 1000);
        uint256 d = lab.batchDuration(0);
        assertGe(d, 1000);
    }

    function test_GetBatchSteps_Timestamps() public {
        vm.startPrank(alice);
        lab.createBatch("WAFER-TS");
        uint256 t0 = block.timestamp;

        vm.warp(t0 + 60);
        lab.advanceBatch(0); // completes step 0

        vm.warp(t0 + 120);
        lab.advanceBatch(0); // completes step 1
        vm.stopPrank();

        (uint256[6] memory ts, ) = lab.getBatchSteps(0);
        assertEq(ts[0], t0 + 60);
        assertEq(ts[1], t0 + 120);
        assertEq(ts[2], 0);
    }

    function test_GetBatchesByOwner_Empty() public view {
        uint256[] memory ids = lab.getBatchesByOwner(bob);
        assertEq(ids.length, 0);
    }

    /* ───────────────────────────────────────────
       events
    ─────────────────────────────────────────── */

    function test_Event_BatchCreated() public {
        vm.expectEmit(true, true, false, true);
        emit CohrLab.BatchCreated(alice, 0, "WAFER-EV", block.timestamp);
        vm.prank(alice);
        lab.createBatch("WAFER-EV");
    }

    function test_Event_BatchCompleted() public {
        vm.prank(alice);
        lab.createBatch("WAFER-EVC");

        vm.startPrank(alice);
        for (uint8 i = 0; i < 5; i++) lab.advanceBatch(0);
        vm.expectEmit(true, true, false, false);
        emit CohrLab.BatchCompleted(alice, 0, "WAFER-EVC", 0);
        lab.advanceBatch(0);
        vm.stopPrank();
    }

    /* ───────────────────────────────────────────
       FUZZ TESTS
    ─────────────────────────────────────────── */

    /**
     * @dev Fuzz: any valid name (1–32 bytes) must create a batch successfully.
     *      Foundry will also try empty and >32 byte strings — verify reverts.
     */
    function testFuzz_CreateBatch_NameBoundaries(string calldata name) public {
        uint256 len = bytes(name).length;
        if (len == 0) {
            vm.prank(alice);
            vm.expectRevert(CohrLab.EmptyName.selector);
            lab.createBatch(name);
        } else if (len > 32) {
            vm.prank(alice);
            vm.expectRevert(CohrLab.NameTooLong.selector);
            lab.createBatch(name);
        } else {
            vm.prank(alice);
            uint256 id = lab.createBatch(name);
            assertEq(id, 0);
            assertEq(lab.batchCount(), 1);
        }
    }

    /**
     * @dev Fuzz: advancing a random number of steps should always stay within
     *      [0, 6] and flip complete=true exactly when step reaches 6.
     */
    function testFuzz_AdvanceBatch_Monotonic(uint8 advances) public {
        vm.assume(advances <= 20); // keep run time bounded
        vm.startPrank(alice);
        lab.createBatch("WAFER-FUZZ");

        uint8 expected = 0;
        for (uint8 i = 0; i < advances; i++) {
            if (expected >= 6) {
                vm.expectRevert(abi.encodeWithSelector(CohrLab.BatchAlreadyComplete.selector, 0));
                lab.advanceBatch(0);
                break;
            }
            lab.advanceBatch(0);
            expected++;
        }

        (, , , uint8 step, , , bool complete, ) = lab.getBatch(0);
        uint8 cap = advances > 6 ? 6 : advances;
        assertEq(step, cap);
        assertEq(complete, cap >= 6);
        vm.stopPrank();
    }
}
