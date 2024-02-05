// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.8.2 <0.9.0;

/**
 * Voting Smart Contract
 *
 * Register candidates with unique identifiers.
 * Allow users to vote for a candidate.
 * Retrieve the total votes for each candidate.
 */
contract Voting {
    string[] public candidate;
    mapping(string => uint256) public votes;

    event StoreCandidate(string indexed candidate, address indexed candidateAddress);
    event VoteCandidate(string indexed candidate, address indexed sender);

    function enterCandidateName(string memory _candidate) public {
        require(bytes(_candidate).length > 0, "Enter candidate name correctly");
        require(!candidateExists(_candidate), "Candidate name already exists");

        candidate.push(_candidate);
        emit StoreCandidate(_candidate, msg.sender);
    }

    function candidateExists(string memory _candidate) public view returns (bool) {
        for (uint256 i = 0; i < candidate.length; i++) {
            if (keccak256(bytes(candidate[i])) == keccak256(bytes(_candidate))) {
                return true;
            }
        }
        return false;
    }

    function voteaCandidate(string memory _candidate) public {
        require(candidateExists(_candidate), "Candidate name is wrong or candidate does not exist");

        votes[_candidate]++;
        emit VoteCandidate(_candidate, msg.sender);
    }

    function getCandidateVotes() public view returns (uint256[] memory) {
        uint256[] memory candidateVotes = new uint256[](candidate.length);

        for (uint256 i = 0; i < candidate.length; i++) {
            candidateVotes[i] = votes[candidate[i]];
        }
        return candidateVotes;
    }
}
