pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

contract SecretVote {
    
    // state variables
    bool voting = false;
    
    uint8 votingTime = 60;    // length of time in seconds that the users are allowed to vote for
    uint256 startTime = 0;

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
    function setChoice(string memory _name) public {
        
        require (msg.sender == chairperson, "Only the chairperson can set the choices.");
        Choice memory choice = Choice(_name, 0);
        choices.push(choice);

    }
    
    
    // gets the name of the choice at this index
    function getChoice(uint16 choiceNum) public view returns (string memory _choice){
    
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        return choices[choiceNum].name;
       
    }
    
    
    // initiates the voting phase - users can only vote after this function has been run
    function initiateVote() public {
        
        require(msg.sender == chairperson, "Only the chairperson can start the vote.");
        require(!voting, "There is already a vote in progress.");
        require(choices.length > 1, "There must be at least two choices set in order to start a vote.");
        voting = true;
        startTime = now;
        
    }
    
    
    // allows chairperson to change the name of a choice 
    function setName(uint16 choiceNum, string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can change the name of a choice.");
        require(!voting, "You cannot change the name of a choice while voting is in progress.");
        
        choices[choiceNum].name = _name;
        
    }
    
    
    // returns vote count of a choice only if voting is over
    function getVoteCount(uint16 choiceNum) public view returns (uint _voteCount) {
        
        require(isVotingOver(), "You cannot view the vote counts while voting is in progress.");
        _voteCount = choices[choiceNum].voteCount;
        
    }
    
    
    // voter registers to vote by paying 1m wei
    // any number of addresses can register
    function registerToVote() public payable {
        
        // check exceptions
        require(msg.value > 1000000, "You must pay 1,000,000 wei to vote.");
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to register.");
        
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
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to vote.");
        require(!sender.voted, "You have already voted.");
        require(toChoice < choices.length, "Your vote was out of bounds.");
        
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
        
        uint256 endTime = now;
        
        if (endTime - startTime > votingTime) {
            return true;
        }
        else {
            return false;
        }
        
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