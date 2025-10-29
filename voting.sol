// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }
    Proposal[] public proposals;

    mapping(address => bool) Allowed;
    constructor(address[] memory _voters) {
        Allowed[msg.sender] = true;
        for(uint i = 0; i < _voters.length; i++) {
            Allowed[_voters[i]] = true;
        }
    }

    mapping(uint => mapping(address => bool)) hasVoted;
    mapping(uint => mapping(address => bool)) voteChoice;

    event ProposalCreated(uint id);
    event VoteCast(uint id, address addr);

    function newProposal(address _target, bytes memory _data) external {
        require(Allowed[msg.sender], "not allowed");
        proposals.push(Proposal({target: _target, data: _data, yesCount: 0, noCount: 0}));
        emit ProposalCreated(proposals.length - 1);
    }

    function castVote(uint _id, bool _vote) external {
        require(Allowed[msg.sender], "not allowed");  
        if(hasVoted[_id][msg.sender]) {
            bool oldVote = voteChoice[_id][msg.sender];
            if(oldVote != _vote) {
                if(oldVote) {
                    proposals[_id].yesCount--;
                    proposals[_id].noCount++;
                }
                else {
                    proposals[_id].yesCount++;
                    proposals[_id].noCount--;
                }
                voteChoice[_id][msg.sender] = _vote;
            }
        }
        else {
            hasVoted[_id][msg.sender] = true; 
            voteChoice[_id][msg.sender] = _vote;
            
            if(_vote) proposals[_id].yesCount++;
            else proposals[_id].noCount++;
        }
        if(proposals[_id].yesCount == 10) {
            (bool success, ) = proposals[_id].target.call(proposals[_id].data);
            require(success);
        }  
        emit VoteCast(_id, msg.sender);
    }
}
