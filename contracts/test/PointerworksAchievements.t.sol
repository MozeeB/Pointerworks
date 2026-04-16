// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {PointerworksAchievements} from "../src/PointerworksAchievements.sol";

contract PointerworksAchievementsTest is Test {
    PointerworksAchievements internal c;
    address internal alice = address(0xA11CE);
    bytes32 internal h = keccak256("demo-solution");

    function setUp() public {
        c = new PointerworksAchievements();
    }

    function test_completeLevel_setsBitAndStoresHash() public {
        vm.prank(alice);
        c.completeLevel(0, h);

        assertTrue(c.hasCompleted(alice, 0));
        assertEq(c.solutionHash(alice, 0), h);
        assertEq(c.completedCount(alice), 1);
    }

    function test_completeLevel_idempotentReplay() public {
        vm.startPrank(alice);
        c.completeLevel(2, h);
        c.completeLevel(2, keccak256("different-hash"));
        vm.stopPrank();

        // First hash preserved (first-solution wins).
        assertEq(c.solutionHash(alice, 2), h);
        assertEq(c.completedCount(alice), 1);
    }

    function test_completeLevel_revertsOnInvalidLevel() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(PointerworksAchievements.InvalidLevel.selector, uint8(10)));
        c.completeLevel(10, h);
    }

    function test_multipleLevels_accumulate() public {
        vm.startPrank(alice);
        c.completeLevel(0, h);
        c.completeLevel(3, h);
        c.completeLevel(9, h);
        vm.stopPrank();

        assertEq(c.completedCount(alice), 3);
        assertTrue(c.hasCompleted(alice, 0));
        assertTrue(c.hasCompleted(alice, 3));
        assertTrue(c.hasCompleted(alice, 9));
        assertFalse(c.hasCompleted(alice, 5));
    }
}
