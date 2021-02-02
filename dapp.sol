pragma solidity >=0.4.22 <0.7.0;
// SPDX-License-Identifier: MIT

contract SecretVote {
    
    // state variables
    uint8 votingTime = 60;    // default length of time in seconds that the users are allowed to vote for
    uint256 startTime;
    uint256 registrationFee = 1000000; // default registration fee
    bool voteInitiated;
    uint8 numCommits;   // number of committed votes
    uint8 numConfirms;  // number of confirmed votes
    
    // struct for choices to vote for
    struct Choice {
        string name;
        uint voteCount;
    }
    
    // struct for potential voters
    struct Voter {
        bool registered;
        bool voted;
        bool confirmed;
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

    }
    
    
    /// functions
    
    // specify new choice based on name and add to array - requirement 1
    function addNewChoice(string memory _name) public {
        
        require(msg.sender == chairperson, "Only the chairperson can add a choice.");
        require(isVotingOver(), "You cannot add a new choice while voting is in progress.");

        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            require(keccak256(bytes(choices[choiceNum].name)) != keccak256(bytes(_name)), "This choice already exists.");
        }
        
        Choice memory choice = Choice(_name, 0);
        choices.push(choice);

    }
    
    
    // remove a choice from the choices - requirement 1
    function removeChoice(uint16 choiceNum) public {
        
        require(msg.sender == chairperson, "Only the chairperson can remove a choice.");
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        
        // reorders as a consequence of removal
        choices[choiceNum] = choices[choices.length - 1];
        choices.pop();
        
    }
    
    
    // resets the choice array
    function resetChoices() public {
        
        require(msg.sender == chairperson, "Only the chairperson can reset the choices.");
        require(isVotingOver(), "You cannot reset the choices while voting is in progress.");
        require(choices.length > 0, "There are no choices to reset.");
        
        uint256 length = choices.length;
        for (uint8 i = 0; i < length; i++){
            choices.pop();
        }
        
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
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        
        // ensure no choice exists with same name
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
    
    
    // gets the voting time and the registration fee
    function getProperties() public view returns (uint8 _votingTimeSeconds, uint256 _registrationFeeWei) {
        
        _votingTimeSeconds = votingTime;
        _registrationFeeWei = registrationFee;
        
    }
    
    
    // transfer the ownership of the contract to another users
    function changeOwner(address _address) public {
        
        require(msg.sender == chairperson, "Only the chairperson can set the registration fee.");
        require(isVotingOver(), "You cannot change the ownership of the contract while voting is in progress.");
        
        chairperson = _address;
        
    }
    
    
    // owner of the contract initiates the voting phase between a number of choices - requirement 1
    function initiateVote() public {
        
        require(msg.sender == chairperson, "Only the chairperson can start the vote.");
        require(isVotingOver(), "There is already a vote in progress.");
        require(choices.length > 1, "There must be at least two choices set in order to start a vote.");
        
        // reset state variables
        startTime = now;
        numCommits = 0;
        numConfirms = 0;
        
        // reset attributes of registered and voted users
        for (uint8 i = 0; i < registeredVoters.length; i++){
            address sender = registeredVoters[i];
            voters[sender].registered = false;
            voters[sender].voted = false;
            voters[sender].confirmed = false;
            voters[sender].vote = "";
        }
        
        // reset the vote counts of the choices to 0
        for (uint8 choiceNum = 0; choiceNum < choices.length; choiceNum++) {
            choices[choiceNum].voteCount = 0;
        }
        
        voteInitiated = true;
        
    }
    
    
    // user registers to vote by paying a registration fee - requirement 2
    // any number of addresses can register
    function registerToVote() public payable {
        
        Voter storage sender = voters[msg.sender];
        
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to register.");
        require(msg.value > registrationFee, "You must pay the correct fee to vote. Please check this amount using getProperties()");
        require(!sender.registered, "You are already registered.");
        
        // update registered attribute and add address to registered voters array
        sender.registered = true;
        registeredVoters.push(msg.sender);
        
    }
    
    
    // takes hash of nonce + vote and stores as voter's vote
    // prevents users from voting multiple times - requirement 2
    // hash prevents everyone from seeing the vote during voting phase - requirement 3 
    function commitVote(bytes32 voteHash) public {
        
        // get sender and check for exceptions
        Voter storage sender = voters[msg.sender];
        
        require(!isVotingOver(), "There is currently no vote in progress. Please wait until the next vote begins to commit your vote.");
        require(sender.registered, "You must be registered in order to commit your vote.");
        require(!sender.voted, "You have already committed your vote.");
        
        // update sender attributes and increment number of commits
        sender.vote = voteHash;
        sender.voted = true;
        numCommits++;
        
    }
    
    
    // check the hash of input nonce and index against stored hash
    // prevents users from voting multiple times - requirement 2
    function confirmVote(string memory nonce, string memory stringVoteIndex, uint256 intVoteIndex) public {
        
        Voter storage sender = voters[msg.sender];
        
        require(isVotingOver(), "You cannot confirm your vote until voting ends.");
        require(sender.voted, "You must have already voted in order to confirm your vote.");
        require(!sender.confirmed, "You have already confirmed your vote.");
        
        // concatenate nonce and vote, and hash
        string memory toHash = string(abi.encodePacked(nonce, stringVoteIndex));
        bytes32 confirmVoteHash = keccak256(bytes(toHash));
        
        // confirm that hashes are equal and increments vote count
        bytes32 committedVoteHash = sender.vote;
        require(committedVoteHash == confirmVoteHash,
        "Either the nonce or the vote (or both) were not recognised and your vote was not confirmed.");
        
        require(intVoteIndex < choices.length, "The choice number is out of bounds. Your vote is invalid and will not be counted.");
        
        // update vote count and sender attributes and increment number of confirms
        choices[intVoteIndex].voteCount += 1;
        sender.confirmed = true;
        numConfirms++;
        
    }
    
    
    // uses current timestamp to check if the voting time has elapsed
    function isVotingOver() public view returns (bool isOver) {
        
        uint256 currentTime = now;
        
        if (currentTime - startTime > votingTime) {
            return true;
        }
        else {
            return false;
        }
        
    }
    
    
    // returns the amount of time left in the current voting phase. if no voting phase active, returns -1
    function votingTimeLeft() public view returns (uint256 _time) {
        
        if (isVotingOver()) {
            return 0;
        }
        
        return votingTime - (now - startTime);
        
    }
    
    
    // returns vote count of a choice only if voting is over
    // users cannot see the results until voting is over - requirement 3
    function getVoteCount(uint16 choiceNum) public view returns (string memory _name, uint _voteCount) {
        
        require(isVotingOver(), "You cannot view the vote counts while voting is in progress.");
        require(choiceNum < choices.length, "The choice number is out of bounds.");
        
        _name = choices[choiceNum].name;
        _voteCount = choices[choiceNum].voteCount;
        
    }
    
    
    // get the winning choice
    // result of the vote is viewable to everyone after everyone has voted - requirement 4
    function winningChoice() public view returns (string memory winningChoiceName) {
        
        require(isVotingOver(), "You cannot view the winner until voting ends.");
        require(voteInitiated, "You cannot view the winner when a vote has not occured.");
        require(numCommits == numConfirms, "All users must confirm their vote before you can view the winner.");
        
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