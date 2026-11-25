// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {AllowlistBallot} from "../src/AllowlistBallot.sol";
import {TestBase} from "./TestBase.sol";

contract AllowlistBallotTest is TestBase {
    AllowlistBallot private ballot;
    address private constant ALICE = address(0xA11CE);
    address private constant BOB = address(0xB0B);

    function setUp() public {
        address[] memory voters = new address[](2);
        voters[0] = ALICE;
        voters[1] = BOB;
        ballot = new AllowlistBallot(voters, 1 hours);
    }

    function testRejectsZeroDuration() public {
        address[] memory voters = new address[](1);
        voters[0] = ALICE;
        vm.expectRevert(AllowlistBallot.InvalidConfiguration.selector);
        new AllowlistBallot(voters, 0);
    }

    function testRejectsEmptyElectorate() public {
        vm.expectRevert(AllowlistBallot.InvalidConfiguration.selector);
        new AllowlistBallot(new address[](0), 1);
    }

    function testRejectsZeroVoter() public {
        vm.expectRevert(AllowlistBallot.InvalidVoter.selector);
        new AllowlistBallot(new address[](1), 1);
    }

    function testRejectsDuplicateVoter() public {
        address[] memory voters = new address[](2);
        voters[0] = ALICE;
        voters[1] = ALICE;
        vm.expectRevert(AllowlistBallot.InvalidVoter.selector);
        new AllowlistBallot(voters, 1);
    }

    function testMajorityAtDeadline() public {
        vm.warp(ballot.closesAt() - 1);
        vm.expectRevert(AllowlistBallot.BallotOpen.selector);
        ballot.passed();
        vm.prank(ALICE);
        ballot.vote(true);

        vm.warp(ballot.closesAt());
        assertTrue(ballot.passed());
        vm.prank(BOB);
        vm.expectRevert(AllowlistBallot.BallotClosed.selector);
        ballot.vote(false);
    }

    function testTieFailsAndCountsBothVotes() public {
        vm.prank(ALICE);
        ballot.vote(true);
        vm.prank(BOB);
        ballot.vote(false);
        assertEq(ballot.yesVotes(), 1);
        assertEq(ballot.noVotes(), 1);
        vm.warp(ballot.closesAt());
        assertTrue(!ballot.passed());
    }

    function testRejectsUnlistedAndRepeatVoters() public {
        vm.expectRevert(AllowlistBallot.Ineligible.selector);
        ballot.vote(true);
        vm.prank(ALICE);
        ballot.vote(true);
        vm.prank(ALICE);
        vm.expectRevert(AllowlistBallot.AlreadyVoted.selector);
        ballot.vote(false);
    }
}
