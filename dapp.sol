pragma solidity >=0.4.22 <0.7.0;
// SPDX-License-Identifier: MIT

contract SecretVote {
    
    // state variables
    uint8 votingTime = 60;    // default length of time in seconds that the users are allowed to vote for
    uint256 startTime = 0;
    uint256 registrationFee = 1000000; // default registration fee

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
    address[] registeredVoters;
    
    /// constructor run when voting is initalised
    constructor() payable public {
        
        // assign chairperson and give them a vote
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        
    }
    
    
    /// functions
    
    // create new choice based on name and add to array
    function setNewChoice(string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can set the choices.");
        require(isVotingOver(), "You cannot set a new choice while voting is in progress.");

        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            require(keccak256(bytes(choices[choiceNum].name)) != keccak256(bytes(_name)), "This choice already exists.");
        }
        
        Choice memory choice = Choice(_name, 0);
        choices.push(choice);

    }
    
    
    // gets the name of the choice at this index
    function getChoice(uint16 choiceNum) public view returns (string memory _choice){
    
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        return choices[choiceNum].name;
       
    }

    
    // sets the length of time for voting phase
    function setVotingTime(uint8 time) public {
        
        require(msg.sender == chairperson, "Only the chairperson can set the voting time.");
        require(isVotingOver(), "You cannot set the voting time while voting is in progress.");

        votingTime = time;
        
    }
    
    
    // sets the registration fee amount
    function setFee(uint256 fee) public {
        
        require(msg.sender == chairperson, "Only the chairperson can set the registration fee.");
        require(isVotingOver(), "You cannot set the registration fee while voting is in progress.");
        registrationFee = fee;
        
    }
    
    
    // initiates the voting phase - users can only vote after this function has been run
    function initiateVote() public {
        
        require(msg.sender == chairperson, "Only the chairperson can start the vote.");
        require(!isVotingOver(), "There is already a vote in progress.");
        require(choices.length > 1, "There must be at least two choices set in order to start a vote.");
        
        startTime = now;
        
        // reset weights of registered users to 0
        for (uint8 i = 0; i < registeredVoters.length; i++){
            address sender = registeredVoters[i];
            voters[sender].weight = 0;
        }
        
    }
    
    
    // allows chairperson to change the name of a choice 
    function setChoiceName(uint16 choiceNum, string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can change the name of a choice.");
        require(isVotingOver(), "You cannot change the name of a choice while voting is in progress.");
        
        for (uint8 i = 0; i < choices.length; choiceNum++) {
            require(keccak256(bytes(choices[i].name)) != keccak256(bytes(_name)), "This choice name already exists.");
        }
        
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
        
        Voter storage sender = voters[msg.sender];
        
        require(sender.weight == 0, "You are already registered.");
        require(msg.value > registrationFee, "You must pay 1,000,000 wei to vote.");
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to register.");
        
        // increment weight and add address to registered voters array
        sender.weight = 1;
        registeredVoters.push(msg.sender);
        
    }
    
    
    // voting
    function vote(uint8 toChoice) public returns (string memory name_) {
        
        // get sender and check for exceptions
        Voter storage sender = voters[msg.sender];
        
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to vote.");
        require(sender.weight > 0, "You must be registed in order to vote.");
        require(!sender.voted, "You have already voted.");
        require(toChoice < choices.length, "Your vote was out of bounds.");
        
        // vote for the choice based on sender's weight
        sender.vote = toChoice;
        choices[toChoice].voteCount += sender.weight;
        name_ = choices[toChoice].name;
        
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