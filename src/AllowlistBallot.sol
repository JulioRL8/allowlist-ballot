// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

contract AllowlistBallot {
    error InvalidConfiguration();
    error InvalidVoter();
    error BallotClosed();
    error BallotOpen();
    error Ineligible();
    error AlreadyVoted();

    uint256 public immutable closesAt;
    uint256 public yesVotes;
    uint256 public noVotes;
    mapping(address voter => bool) public eligible;
    mapping(address voter => bool) public voted;

    event VoteCast(address indexed voter, bool support);

    constructor(address[] memory voters, uint64 duration) {
        if (duration == 0) revert InvalidConfiguration();
        if (voters.length == 0) revert InvalidConfiguration();

        closesAt = block.timestamp + duration;
        for (uint256 i; i < voters.length; ++i) {
            address voter = voters[i];
            if (voter == address(0)) revert InvalidVoter();
            if (eligible[voter]) revert InvalidVoter();
            eligible[voter] = true;
        }
    }

    function vote(bool support) external {
        if (block.timestamp >= closesAt) revert BallotClosed();
        if (!eligible[msg.sender]) revert Ineligible();
        if (voted[msg.sender]) revert AlreadyVoted();
        voted[msg.sender] = true;

        if (support) {
            ++yesVotes;
        } else {
            ++noVotes;
        }
        emit VoteCast(msg.sender, support);
    }

    function passed() external view returns (bool) {
        if (block.timestamp < closesAt) revert BallotOpen();
        return yesVotes > noVotes;
    }
}
