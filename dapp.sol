pragma solidity >=0.4.22 <0.7.0;
// SPDX-License-Identifier: MIT

contract SecretVote {
    
    // state variables
    bool voting = false;
    
    uint8 maxVoters = 6;    // max number of addresses that can vote
    uint8 numChoices = 0;
    
    // struct for choices to vote for
    struct Choice {
        string name;
        uint voteCount;
    }
    
    // struct for potential voters
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
    }
    
    // create voter-address mappings and choices arrays
    Choice[] private choices;
    address chairperson;
    mapping(address => Voter) voters;
    
    /// constructor run when voting is initalised
    constructor() payable public {
        
        // assign chairperson and give them two votes
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        
    }
    
    
    /// functions
    
    // create new choice based on name and add to array
    function setChoices(string memory _name) public {
        
        require (msg.sender == chairperson, "Only the chairperson can set the choices.");
        Choice memory choice = Choice(_name, 0);
        choices.push(choice);

    }
    
    
    function getChoice(uint16 choiceNum) public view returns (string memory _choice){
    
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        return choices[choiceNum].name;
       
    }
    
    
    function initiateVote() private {
        
        require (msg.sender == chairperson, "Only the chairperson can start the vote.");
        voting = true;
        
    }
    
    
    // chairperson changes the name of a choice 
    function setName(uint16 choiceNum, string memory _name) public {
        
        require (msg.sender == chairperson, "Only the chairperson can change the name.");
        
        uint256 numVotes = getTotalVotes();
        require(numVotes == 0, "You cannot change the name after voting has started.");

        choices[choiceNum].name = _name;
        
    }
    
    
    // returns vote count of a choice only if voting is over
    function getVoteCount(uint16 choiceNum) public view returns (uint _voteCount) {
        
        require(isVotingOver(), "You cannot view the vote counts until voting ends.");
        _voteCount = choices[choiceNum].voteCount;
        
    }
    
    
    // voter registers to vote by paying 1m wei
    // any number of addresses can register
    function registerToVote() public payable {
        
        // check exceptions
        require(msg.value > 1000000, "You must pay 1,000,000 wei to vote.");
        require(!isVotingOver(), "Voting is over. You can no longer register but you can view the results.");
        
        // assign sender and increment their weight if not the chairperson
        Voter storage sender = voters[msg.sender];
        if (sender.weight == 0){    // to prevent chairperson from gaining a third vote by registering
            sender.weight = 1;
        }
    }
    
    
    // voting
    // no more than maxVoters can vote
    function vote(uint8 toChoice) public returns (string memory name_) {
        
        // get sender and check for exceptions
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You have already voted.");
        require(toChoice < choices.length, "Your vote was out of bounds.");
        require(!isVotingOver(), "Voting is over. You can view the results.");
        
        // vote for the choice based on sender's weight
        sender.vote = toChoice;
        choices[toChoice].voteCount += sender.weight;
        name_ = choices[toChoice].name;
        
        // assign voted if sender has weight, meaning they are registered
        // otherwise leave as false so they can still vote if they register, after trying to vote while unregistered
        if (sender.weight > 0){
            sender.voted = true;
        }
        
    }
    
    
    // gets the number of votes cast so far and checks if equal to maximum number of votes
    function isVotingOver() private view returns (bool _isOver) {
        
        uint256 numVotes = getTotalVotes();
        
        if (numVotes >= maxVoters + 1) {    // +1 to offset the vote weight of 2 from the chairperson
            return true;
        }
        else {
            return false;
        }
        
    }
    
    
    // counts total number of votes
    function getTotalVotes() private view returns (uint _numVotes) {
        
        uint256 numVotes = 0;

        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            numVotes += choices[choiceNum].voteCount;
        }
        
        return numVotes;
        
    }
    
    
    // get the winning choice
    function winningChoice() public view returns (string memory winningChoiceName) {
        
        require(isVotingOver(), "You cannot view the winner until voting ends.");
        uint256 winningVoteCount = 0;
        
        // loop through and replace when a higher vote count is found
        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            if (choices[choiceNum].voteCount > winningVoteCount) {
                winningVoteCount = choices[choiceNum].voteCount;
                winningChoiceName = choices[choiceNum].name;
            }
        }
        
        return winningChoiceName;
        
    }
    
}