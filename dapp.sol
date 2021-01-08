pragma solidity >=0.4.22 <0.7.0;
// SPDX-License-Identifier: MIT

contract SecretLanguage {
    
    // state variables
    
    uint8 maxVoters = 6;    // max number of addresses that can vote
    
    // struct for programming languages to vote for
    struct Language {
        string name;
        uint voteCount; // make private?
    }
    
    // struct for potential voters
    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
    }
    
    // create voter-address mappings and languages arrays
    address chairperson;
    mapping(address => Voter) voters;
    Language[3] private languages;
    
    /// constructor run when voting is initalised
    constructor() payable public {
        
        // assign chairperson and give them two votes
        chairperson = msg.sender;
        voters[chairperson].weight = 2;
        
        // assign languages
        languages[0].name = "Python";
        languages[1].name = "Java";
        languages[2].name = "C";
        
    }
    
    /// functions
    
    // chairperson changes the name of a language 
    function setName(uint16 _language_num, string memory _name) public {
        
        require (msg.sender == chairperson, "Only chairperson can change name");
        languages[_language_num].name = _name;
        
    }
    
    // voter registers to vote by paying 1m wei
    // any number of addresses can register
    function registerToVote() public payable returns (string memory message_) {
        
        // check exceptions
        require(msg.value > 1000000, "You must pay 1,000,000 wei to vote.");
        if (isVotingOver()) return "Voting is over. You can no longer register but you can view the results.";
        
        // assign sender and increment their weight if not the chairperson
        Voter storage sender = voters[msg.sender];
        if (sender.weight == 0){    // to prevent chairperson from gaining a third vote by registering
            sender.weight = 1;
        }
    }
    
    
    // voting
    // no more than maxVoters can vote
    function vote(uint8 toLanguage) public returns (string memory name_) {
        
        // get sender and check for exceptions
        Voter storage sender = voters[msg.sender];
        if (sender.voted) return "You have already voted.";
        if (toLanguage >= languages.length) return "Your vote was out of bounds.";
        if (isVotingOver()) return "Voting is over. You can view the results.";
        
        // vote for the language based on sender's weight
        sender.vote = toLanguage;
        languages[toLanguage].voteCount += sender.weight;
        name_ = languages[toLanguage].name;
        
        // assign voted if sender has weight, meaning they are registered
        // otherwise leave as false so they can still vote if they register, after trying to vote while unregistered
        if (sender.weight > 0){
            sender.voted = true;
        }
        
    }
    
    // gets the number of votes cast so far and checks if equal to maximum number of votes
    function isVotingOver() private view returns (bool _isOver) {
        
        uint256 numVotes = 0;
        
        for (uint8 lang_num = 0; lang_num < languages.length; lang_num++) {
            numVotes += languages[lang_num].voteCount;
        }
        
        if (numVotes >= maxVoters + 1) {    // +1 to offset the vote weight of 2 from the contract creator
            return true;
        }
        else {
            return false;
        }
        
    }
    
    
    // get the winning language
    function winningLanguage() public view returns (string memory _winningLanguageName) {
        
        if (!isVotingOver()) return "You cannot view the winner until voting ends.";
        uint256 winningVoteCount = 0;
        
        // loop through and replace when a higher vote count is found
        
        for (uint8 lang_num = 0; lang_num < languages.length; lang_num++) {
            if (languages[lang_num].voteCount > winningVoteCount) {
                winningVoteCount = languages[lang_num].voteCount;
                _winningLanguageName = languages[lang_num].name;
            }
        }
        
        return _winningLanguageName;
        
    }
    
}