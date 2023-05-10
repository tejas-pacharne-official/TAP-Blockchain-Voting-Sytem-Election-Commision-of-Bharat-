pragma solidity >=0.7.0 <0.9.0;

contract ElectionComissionofBharat {
    
    struct Election {
        
        uint E_ward; 
        uint E_PIN;  
        mapping(uint => Candidate) E_candidates;
        uint E_Year;
        uint E_Id;
        uint E_total_voters;
        uint E_candidate_count;
        election_phases E_voting_phase;
        mapping (address => EVM) E_evm;

    }

    struct EVM {
        address EVM_address;
        string EVM_location;
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

    struct Candidate{
        string c_name;
        uint c_id;
        uint c_votes;
        string party_name;
    }

    // Global Variables
    
    enum election_phases{ Yet_to_Start , Started, Finished }
    mapping(uint => Voter) voters;
    uint voters_count;
    uint charipersons_count;
    mapping(address => Chairperson) internal chairpersons;
    Election[] elections;
    uint election_id_count = 0;
    mapping(address => bool) internal duplicate;

    constructor(uint f_Id,string memory f_name) {

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
        e1.E_voting_phase=  election_phases.Yet_to_Start;
        e1.E_Year = f_year;
        e1.E_total_voters = 0;
        e1.E_candidates[e1.E_candidate_count] = Candidate({c_name: "NOTA", c_id: e1.E_candidate_count, c_votes: 0 , party_name: "NOTA"});
        e1.E_candidate_count+=1;
        e1.E_Id = elections.length;
        
    }
    

    function changeElectionPhase(uint f_ward, uint f_pin , uint f_year) public{
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can have right to add candidate ."
        );
        bool flag = true;
        for(uint i =0; i < elections.length; i++){
            
            
            if(elections[i].E_ward == f_ward && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year ){
                
                if(elections[i].E_voting_phase == election_phases.Yet_to_Start){
                    elections[i].E_voting_phase = election_phases.Started;
                    flag = true;
                }
                else if(elections[i].E_voting_phase == election_phases.Started){
                    elections[i].E_voting_phase = election_phases.Finished;
                    flag = true;
                }
                else{
                    require(
                        false,
                        "Election Finished If you are chairman to kya hua, ye blockchain hai ! kiska baap chi change nahi kar sakta result bhadve"
                    );
                }
                
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
                elections[i].E_voting_phase == election_phases.Yet_to_Start, 
                    " Election is started or finished, Cannot add candidate "
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
        voters[voter_id].V_voted = false;
    
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
        require(
            duplicate[f_voter_address] == false,
            "Address already present in th system..."    
        );
        voters[voter_id].V_address = f_voter_address;
        voters[voter_id].V_linked = true; 
        duplicate[f_voter_address] = true; 
    }


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
        voters[f_ID].V_voted = false;

    }  

    function getVoterDetails(uint f_id) public view returns (Voter memory v1){

        require(
            voters[f_id].V_isValue,
            "Error 2.2: Please fill details.Details not available"
        );
        v1 = voters[f_id];

    }

    function voteUsingEVM(uint f_ward , uint f_pin , uint f_year , uint f_id , uint c_id) public {
        
        bool flag = false;
        require( voters[f_id].V_voted == false, 
            "Already Voted Cannot Vote again"
        );

        for(uint i =0; i < elections.length; i++){

            if(elections[i].E_ward ==f_ward && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == election_phases.Started, 
                    " Voting Phase is not yet started ... "
                );
                require( 
                elections[i].E_candidate_count > c_id, 
                "Candidate id not found"
                );
                require( 
                    keccak256(abi.encodePacked(elections[i].E_evm[msg.sender].EVM_address)) == keccak256(abi.encodePacked(msg.sender)),
                    "Invalid EVM please ask chairman to add EVM..."
                );
                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    if(keccak256(abi.encodePacked(j)) == keccak256(abi.encodePacked(c_id))){
                        
                        elections[i].E_candidates[j].c_votes +=1;
                        voters[f_id].V_voted = true;
                        elections[i].E_total_voters += 1; 
                        flag = true;
                        break;

                    
                    }
                }
                require(flag,
                "Error 2.5: Candidaee id not found ...");
            }
        }
        
    }

    function vote(uint f_id , uint c_f_id , uint f_year) public {
        
        bool flag=false;
        require( keccak256(abi.encodePacked(voters[f_id].V_address)) == keccak256(abi.encodePacked(msg.sender)), 
        "You can only vote with valid linked account, 2 attempts left to get banned..."
        );

        require( voters[f_id].V_voted == false, 
        "Already Voted Cannot Vote again");

        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward == voters[f_id].V_ward  && elections[i].E_PIN == voters[f_id].V_PIN && elections[i].E_Year == f_year){

                require(
                elections[i].E_voting_phase == election_phases.Started, 
                    " Voting Phase is not yet started ... "
                );

                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    if(keccak256(abi.encodePacked(j)) == keccak256(abi.encodePacked(c_f_id))
                      ){
                        elections[i].E_candidates[j].c_votes +=1;
                        voters[f_id].V_voted = true;
                        elections[i].E_total_voters += 1; 
                        flag=true;
                        break;
                    
                    }
                }
                require(flag, 
                "Candidate Id Not Found ...");
            }
        }

    }

    function vote(uint f_id , string memory f_party , uint f_year) public {
        bool flag=false;
        require( keccak256(abi.encodePacked(voters[f_id].V_address)) == keccak256(abi.encodePacked(msg.sender)),
        "You can only vote with valid linked account, 2 attempts left to get banned..."
        );

        require( voters[f_id].V_voted == false, 
        "Already Voted Cannot Vote again");
        
        for(uint i =0; i < elections.length; i++){

            if(elections[i].E_ward == voters[f_id].V_ward  && elections[i].E_PIN == voters[f_id].V_PIN && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == election_phases.Started , 
                    " Voting Phase is not yet started ... "
                );

                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    if( keccak256(abi.encodePacked(elections[i].E_candidates[j].party_name)) == keccak256(abi.encodePacked(f_party)) ){
                        elections[i].E_candidates[j].c_votes +=1;
                        voters[f_id].V_voted = true;
                        elections[i].E_total_voters += 1;
                        flag=true; 
                        break;
                    }
                }
                require(flag, 
                "Candidate Id Not Found ...");
            }

        }
        
    }

   /* function getCandidateVoteCount(uint f_ward,uint f_pin , uint f_year,uint f_candidate_id)public view returns (Candidate memory f_votes_count)
    {
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == election_phases.Finished,
                    "Voting phase is not yet finihed please try again later ... "
                );                                                      
                require(
                elections[i].E_candidate_count > f_candidate_id,
                    "Voting phase is on please try again later ... "
                );  
                f_votes_count = elections[i].E_candidates[f_candidate_id];
                break;                                                              
            }           
        }
    }
*/
    function getCandidateDetails(uint f_ward,uint f_pin , uint f_year,uint f_candidate_id)public view returns (Candidate memory f_votes_count)
    {
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == election_phases.Yet_to_Start || elections[i].E_voting_phase == election_phases.Finished,
                    "Voting phase is On please try again later ... "
                );                                                      
                require(
                elections[i].E_candidate_count > f_candidate_id,
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
                elections[i].E_voting_phase == election_phases.Finished, 
                    "Voting phase is not finshed please try again later ... "
                );
                
                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    
                    if( elections[i].E_candidates[j].c_votes >  elections[i].E_candidates[max].c_votes){
                        max = j;

                    }

                }
                
                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){
                    
                    if( keccak256(abi.encodePacked(elections[i].E_candidates[max].c_votes)) == keccak256(abi.encodePacked(elections[i].E_candidates[j].c_votes)) && keccak256(abi.encodePacked(max)) != keccak256(abi.encodePacked(j)) ){
                        
                        winnerName = string.concat(" ",elections[i].E_candidates[j].c_name);
                    }

                }

                winnerName = string.concat(" ",elections[i].E_candidates[max].c_name);
                break;

            }

        }
    }
 
    
    function getElectionDetails(uint f_ward,uint f_pin , uint f_year)public view returns (uint ward ,uint pin, uint year, uint id , uint total_voters , uint can_total_count ,election_phases phase ){
        require(
            chairpersons[msg.sender].ch_address == msg.sender,
            "Error 1.1: Only chairperson can see election details."
        );
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                
                ward = elections[i].E_ward;
                pin = elections[i].E_PIN;
                year = elections[i].E_Year;
                id = elections[i].E_Id;
                total_voters = elections[i].E_total_voters;
                can_total_count = elections[i].E_candidate_count;
                phase = elections[i].E_voting_phase;
                break;

            }
        }
    }

    function addEVM(uint f_ward , uint f_pin , uint f_year , string memory f_location , address f_evm_address)public{
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                elections[i].E_evm[f_evm_address].EVM_address = f_evm_address;
                elections[i].E_evm[f_evm_address].EVM_location = f_location;
                break;
            }
        }
    }

    function getAllCandidateDetails(uint f_ward,uint f_pin , uint f_year)public view returns (Candidate[] memory f_candidates)
    {
        string memory t_name;
        uint t_c_id;
        uint t_c_votes;
        string memory t_party_name;
        
        for(uint i =0; i < elections.length; i++){
            
            if(elections[i].E_ward ==f_ward  && elections[i].E_PIN == f_pin && elections[i].E_Year == f_year){
                require(
                elections[i].E_voting_phase == election_phases.Yet_to_Start || elections[i].E_voting_phase == election_phases.Finished,
                    "Voting phase is On please try again later ... "
                ); 
                Candidate[] memory c1 = new Candidate[](elections[i].E_candidate_count) ;               
                for(uint j =0 ;j< elections[i].E_candidate_count ; j++){   
                    
                    t_name = elections[i].E_candidates[j].c_name;
                    t_c_id = elections[i].E_candidates[j].c_id;
                    t_c_votes = elections[i].E_candidates[j].c_votes;
                    t_party_name = elections[i].E_candidates[j].party_name;
                    c1[j]=Candidate({c_name : t_name, c_id : t_c_id , c_votes : t_c_votes , party_name :t_party_name});
                    
                }
                f_candidates = c1;
                break;
            }           
        }
    }
}
