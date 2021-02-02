pragma solidity >=0.4.22 <0.7.0;
// SPDX-License-Identifier: MIT

contract SecretVote {
    
    // state variables
    uint8 votingTime = 60;    // default length of time in seconds that the users are allowed to vote for
    uint256 startTime = 0;
    uint256 registrationFee = 1000000; // default registration fee
    bool voteInitiated;
    
    // struct for choices to vote for
    struct Choice {
        string name;
        uint voteCount;
    }
    
    // struct for potential voters
    struct Voter {
        bool registered;
        bool voted;
        bytes32 vote;
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
        voters[chairperson].registered = true;
        registeredVoters.push(msg.sender);
        
    }
    
    
    /// functions
    
    // create new choice based on name and add to array
    function addNewChoice(string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can add a choice.");
        require(isVotingOver(), "You cannot add a new choice while voting is in progress.");

        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            require(keccak256(bytes(choices[choiceNum].name)) != keccak256(bytes(_name)), "This choice already exists.");
        }
        
        Choice memory choice = Choice(_name, 0);
        choices.push(choice);

    }
    
    
    // remove a choice from the choices
    function removeChoice(uint16 choiceNum) public {
        
        require(msg.sender == chairperson, "Only the chairperson can remove a choice.");
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        
        // reorders as a consequence of removal
        choices[choiceNum] = choices[choices.length - 1];
        choices.pop();
        
    }
    
    
    // gets the name of the choice at this index
    function getChoice(uint16 choiceNum) public view returns (string memory _choice){
    
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        return choices[choiceNum].name;
       
    }
    
    
    // allows chairperson to change the name of a choice 
    function setChoiceName(uint16 choiceNum, string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can change the name of a choice.");
        require(isVotingOver(), "You cannot change the name of a choice while voting is in progress.");
        
        for (uint8 i = 0; i < choices.length; i++) {
            require(keccak256(bytes(choices[i].name)) != keccak256(bytes(_name)), "This choice name already exists.");
        }
        
        choices[choiceNum].name = _name;
        
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
    
    
    // transfer the ownership of the contract to another users
    function changeOwner(address _address) public {
        
        require(msg.sender == chairperson, "Only the chairperson can set the registration fee.");
        require(isVotingOver(), "You cannot change the ownership of the contract while voting is in progress.");
        
        chairperson = _address;
        
    }
    
    
    // initiates the voting phase - users can only vote after this function has been run
    function initiateVote() public {
        
        require(msg.sender == chairperson, "Only the chairperson can start the vote.");
        require(isVotingOver(), "There is already a vote in progress.");
        require(choices.length > 1, "There must be at least two choices set in order to start a vote.");
        
        startTime = now;
        
        // reset attributes of registered and voted users to false
        for (uint8 i = 0; i < registeredVoters.length; i++){
            address sender = registeredVoters[i];
            voters[sender].registered = false;
            voters[sender].voted = false;
        }
        
        // reset the vote counts of the choices to 0
        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            choices[choiceNum].voteCount = 0;
        }
        
        voteInitiated = true;
        
    }
    
    
    // voter registers to vote by paying 1m wei
    // any number of addresses can register
    function registerToVote() public payable {
        
        Voter storage sender = voters[msg.sender];
        
        require(!sender.registered, "You are already registered.");
        require(msg.value > registrationFee, "You must pay 1,000,000 wei to vote.");
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to register.");
        
        // update registered attribute and add address to registered voters array
        sender.registered = true;
        registeredVoters.push(msg.sender);
        
    }
    
    
    // takes hash of nonce + vote and stores as voter's vote
    function commitVote(bytes32 voteHash) public {
        
        // get sender and check for exceptions
        Voter storage sender = voters[msg.sender];
        
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to commit your vote.");
        require(sender.registered, "You must be registered in order to commit your vote.");
        require(!sender.voted, "You have already voted.");

        // update sender attributes and return
        sender.vote = voteHash;
        sender.voted = true;
        
    }
    
    
    // check the hash of input nonce and index against stored hash
    function confirmVote(string memory nonce, string memory stringVoteIndex, uint256 intVoteIndex) public {
        
        Voter storage sender = voters[msg.sender];
        require(isVotingOver(), "You cannot confirm your vote until voting ends.");
        require(sender.voted, "You must have already voted in order to confirm your vote.");
        
        // concatenate nonce and vote, and hash
        string memory toHash = string(abi.encodePacked(nonce, stringVoteIndex));
        bytes32 confirmVoteHash = keccak256(bytes(toHash));
        
        // confirm that hashes are equal and increments vote count
        bytes32 committedVoteHash = sender.vote;
        require(committedVoteHash == confirmVoteHash, 
        "Either the nonce or the vote (or both) were not recognised and your vote was not confirmed.");
        
        choices[intVoteIndex].voteCount += 1;
        
    }
    
    
    // uses current timestamp to check if the voting time has elapsed
    function isVotingOver() private view returns (bool _isOver) {
        
        uint256 endTime = now;
        
        if (endTime - startTime > votingTime) {
            return true;
        }
        else {
            return false;
        }
        
    }
    
    
    // returns vote count of a choice only if voting is over
    function getVoteCount(uint16 choiceNum) public view returns (string memory _name, uint _voteCount) {
        
        require(isVotingOver(), "You cannot view the vote counts while voting is in progress.");
        
        _name = choices[choiceNum].name;
        _voteCount = choices[choiceNum].voteCount;
        
    }
    
    
    // get the winning choice
    function winningChoice() public view returns (string memory winningChoiceName) {
        
        require(isVotingOver(), "You cannot view the winner until voting ends.");
        require(voteInitiated, "You cannot view the winner when a vote has not occured.");
        
        uint256 winningVoteCount = 0;
        
        // loop through and replace when a higher vote count is found
        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            if (choices[choiceNum].voteCount > winningVoteCount) {
                winningVoteCount = choices[choiceNum].voteCount;
                winningChoiceName = choices[choiceNum].name;
            }
            else if (choices[choiceNum].voteCount == winningVoteCount) {
                winningChoiceName = string(abi.encodePacked(winningChoiceName, ", ", choices[choiceNum].name));
            }
        }
        
        return winningChoiceName;
        
    }
    
}