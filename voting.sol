// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executed;
    }
    
    Proposal[] public proposals;
    mapping(address => mapping(uint => bool)) public hasVoted;
    mapping(address => mapping(uint => bool)) public choiceVote;
    mapping(address => bool) public allowed;

    event ProposalCreated(uint proposalId);
    event VoteCast(uint proposalId, address voter);

    constructor(address[] memory _voters) {
        allowed[msg.sender] = true;
        for (uint i = 0; i < _voters.length; i++) {
            allowed[_voters[i]] = true;
        }
    }

    function newProposal(address _to, bytes calldata _data) external {
        require(allowed[msg.sender], "not allowed");
        proposals.push(Proposal({target: _to, data: _data, yesCount: 0, noCount: 0, executed: false}));
        emit ProposalCreated(proposals.length - 1);
    }

    function castVote(uint _id, bool _vote) external {
        require(allowed[msg.sender], "not allowed");
        if (!hasVoted[msg.sender][_id]) { 
            hasVoted[msg.sender][_id] = true;
            choiceVote[msg.sender][_id] = _vote;
            if (_vote) proposals[_id].yesCount++;
            else proposals[_id].noCount++;
        }
        else {
            bool oldVote = choiceVote[msg.sender][_id];
            if (oldVote != _vote) {
                choiceVote[msg.sender][_id] = _vote;

                if (oldVote) proposals[_id].yesCount--;
                else proposals[_id].noCount--;

                if (_vote) proposals[_id].yesCount++;
                else proposals[_id].noCount++;
            }    
        }
        if (proposals[_id].yesCount >= 10 && !proposals[_id].executed) {
            (bool success, ) = proposals[_id].target.call(proposals[_id].data);
            require(success);
            proposals[_id].executed = true;
        } 
        emit VoteCast(_id, msg.sender);
    }
}
