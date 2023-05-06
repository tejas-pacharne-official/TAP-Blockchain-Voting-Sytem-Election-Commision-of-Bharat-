pragma solidity >=0.7.0 <0.9.0;

contract ElectionComissionofBharat {
    
    struct Election {
        
        uint E_ward; 
        uint E_PIN;  
        mapping(uint => Candidate)  E_candidates;
        uint E_Year;
        uint E_Id;
        bool E_voting_phase;
        uint E_total_voters;
        uint E_candidate_count;

    }

    struct Voter {

        bool V_voted;  // if true, that person already voted
        uint V_adhar_no; // UID last 4 digits 
        uint V_Id;   // Voter ID number
        uint V_PIN;   // Pincode
        uint V_ward;  // Ward No
        address V_address;
        uint weight;
        bool V_isValue;
        bool V_linked;
    }

    struct Chairperson{

        uint ch_id;
        string ch_name;
        address ch_address;

    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    struct Candidate{
        string c_name;
        uint c_id;
        uint c_votes;
        string party_name;
    }

    // Global Variables

    address public chairperson;
    mapping(uint => Voter) public voters;
    uint voters_count;
    uint charipersons_count;
    mapping(address => Chairperson) internal chairpersons;
    Election[] elections;
    uint election_id_count = 0;
    Proposal[] public proposals;

    constructor(uint f_Id,string memory f_name) {

        chairperson = msg.sender;
        chairpersons[msg.sender].ch_name = f_name;
        chairpersons[msg.sender].ch_id = f_Id;
        chairpersons[msg.sender].ch_address = msg.sender;

    }   

    function createElection(uint f_ward, uint f_pin , uint f_year ) public {
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to create election."
        );

        elections.push();
        Election storage e1 = elections[elections.length-1];
        e1.E_ward = f_ward;
        e1.E_PIN = f_pin;
        e1.E_voting_phase=  false;
        e1.E_Year = f_year;
        e1.E_total_voters = 0;
        e1.E_candidates[e1.E_candidate_count] = Candidate({c_name: "NOTA", c_id: e1.E_candidate_count, c_votes: 0 , party_name: "NOTA"});
        e1.E_candidate_count+=1;
        e1.E_Id = elections.length;
        
    }
    
    /*
    function getElection() public view returns Election{
        
        retrun  
    
    }*/

    function changeElectionPhase(uint f_ward, uint f_pin , uint f_year) public{
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to add candidate ."
        );
        bool flag = true;
        for(uint i =0; i < elections.length; i++){
            
            
            if(elections[i].E_ward == f_ward && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year ){
                
                elections[i].E_voting_phase = true;
                flag = true;
            
            }

        }
        require(
            flag,
            "Error 2.5: The election details not found."
        );

    }

    function addCandidate(uint f_ward, uint f_pin ,uint f_year , string memory f_name , string memory f_party )public {
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to add candidate ."
        );
        bool flag =false;
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward == f_ward && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year ){
                require(
                elections[i].E_voting_phase == false, 
                    " Election is over or started, Cannot add candidate "
                );
                elections[i].E_candidates[elections[i].E_candidate_count] = Candidate({c_name: f_name, c_id: elections[i].E_candidate_count ,c_votes: 0, party_name: f_party});
                elections[i].E_candidate_count+=1;
                flag = true;
            }

        }
        require(
            flag,
            "Error 2.5: The election details not found."
        );

    }
    
    function giveRightToVote(uint voter_id) public {
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to give right to vote."
        );

        voters[voter_id].V_voted= false;
    
    }

    function linkVoterId(uint voter_id, address f_voter_address) public {

        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to link voter id."
        );

        require(
            voters[voter_id].V_isValue,
            "Error 2.2: Please ask voter to fill details."
        );

        voters[voter_id].V_address = f_voter_address;
        voters[voter_id].V_linked = true;  
    }

    /*
        bool V_voted;  // if true, that person already voted 
        uint V_adhar_no; // UID done
        uint V_Id;   // Voter ID number done
        uint V_PIN;   // Pincode done
        uint V_ward;  // Ward No done
        address V_address; 
        uint weight;
        bool V_isValue; done
    */

    function addVoterDetails(uint f_ID,uint f_adhar_no ,uint f_PIN,uint f_ward) public {

        require(
            !voters[f_ID].V_isValue,
            "Error 2.2: Details already added ..."
        );
        voters[f_ID].V_Id = f_ID;
        voters[f_ID].V_isValue =true; 
        voters[f_ID].V_adhar_no = f_adhar_no;
        voters[f_ID].V_PIN = f_PIN;
        voters[f_ID].V_ward= f_ward;

    }  

    function getVoterDetails(uint f_id) public view returns (Voter memory v1){

        require(
            voters[f_id].V_isValue,
            "Error 2.2: Please fill details.Details not available"
        );
        v1 = voters[f_id];

    }

    function vote(uint f_id , uint c_id) public {
        
        /*
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        */

        require( voters[f_id].V_address != msg.sender , 
        "You can only vote with valid linked account, 2 attempts left to get banned..."
        );

        require( voters[f_id].V_voted == true, 
        "Already Voted Cannot Vote again");

        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward == voters[f_id].V_ward  && elections[i].E_PIN == voters[f_id].V_PIN){
                require(
                elections[i].E_voting_phase != false, 
                    " Voting Phase is not yet started ... "
                );
                require( 
                elections[i].E_candidate_count < c_id, 
                "Already Voted Cannot Vote again"
                );

                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    if(elections[i].E_candidates[j].c_id == c_id ){
                        
                        elections[i].E_candidates[j].c_votes +=1;
                        voters[f_id].V_voted = true;
                        break;
                    
                    }
                }
                
                require(false, 
                "Candidate Id Not Found ...");
            }
        }
        
    }

    function vote(uint f_id , string memory f_party) public {
        
        /*
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        */

        require( voters[f_id].V_address != msg.sender , 
        "You can only vote with valid linked account, 2 attempts left to get banned..."
        );

        require( voters[f_id].V_voted == true, 
        "Already Voted Cannot Vote again");
        
        for(uint i =0; i < elections.length; i++){

            if(elections[i].E_ward == voters[f_id].V_ward  && elections[i].E_PIN == voters[f_id].V_PIN){
                require(
                elections[i].E_voting_phase = false, 
                    " Voting Phase is not yet started ... "
                );

                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    if(  keccak256(abi.encodePacked(elections[i].E_candidates[j].party_name)) == keccak256(abi.encodePacked(f_party)) ){
                        elections[i].E_candidates[j].c_votes +=1;
                        voters[f_id].V_voted = true;
                        break;
                    }
                }
                
                require(false, 
                "Candidate Id Not Found ...");
            }

        }
        
    }


    function winningProposal() public view
        returns (uint winningProposal_)
        {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function getCandidateVoteCount(uint f_ward,uint f_pin , uint f_year,uint f_candidate_id)public view returns (Candidate memory f_votes_count)
    {
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == true,
                    "Voting phase is not yet started please try again later ... "
                );                                                      
                require(
                elections[i].E_candidate_count < f_candidate_id,
                    "Voting phase is on please try again later ... "
                );  
                f_votes_count = elections[i].E_candidates[f_candidate_id];
                break;                                                              
            }           

        }

    }


    function getWinnerName(uint f_ward,uint f_pin , uint f_year)public view returns (string memory winnerName)
    {
        uint max = 0;
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == true, 
                    "Voting phase is on please try again later ... "
                );
                
                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    
                    if( elections[i].E_candidates[j].c_votes >  elections[i].E_candidates[max].c_votes){

                        max = j;

                    }
                }
                winnerName = elections[i].E_candidates[max].c_name;
                break;

            }

        }
    }

}


