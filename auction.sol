
//@author Mahsa Bastankhah
pragma solidity ^0.5.0;
import "./Verifier.sol";
//pragma experimental abiencoderv2
pragma experimental ABIEncoderV2;
contract Auction {
    /////////////////////////////////////////////////////////////////// Variable Definition
    VerifierCipher verifierCipher;
    VerifierWinner verifierWinner;
    enum AuctionState { init,
                        AllBiddersRevealed , // function checkIfAllBiddersRevealed has been executed 
						Verified,//function verify has been executed
						cheaterAuctioneer}
    struct Bidder {
        uint[2] commit;
        uint cipher;
        bool paidBack;
        bool existing;
        bool revealed;
        uint[2] pubKey;
		uint deposit;
    }
	
    event GuiltyBidder(string privateKey , address addr);
    AuctionState public state;
    bool withdrawLock;
    mapping(address => Bidder) public bidders;
    address[] public indexs; // addresses of bidders
    //Auction Parameters
    address public auctioneerAddress;
    uint    public bidEnd;
    uint    public revealEnd;
    uint    public verifyEnd;
	uint 	public checkoutEnd;
    uint    public maxBiddersCount;
    uint    public fairnessFees;
    uint[2]  public auctioneerPublicKey; 
	bool auctioneerPaidBack;
	uint auctioneerDeposit;
    //these values are set when the auctioneer determines the winner
    address public winner;
    uint public highestBid;   
    uint public secondHighestBid;
    bool  public testing; 
    uint blockedDeposit;// sum of deposit blocked frome guilty bidders and guilty auctioneer
    uint guiltyNumber;// number of guilty bidders plus guilty auctioneer
    
    /////////////////////////////////////////////////////////////////// Modifiers
    
    modifier onlyAuctioneer() {
        require(msg.sender == auctioneerAddress);
        _;
    }
    
    modifier inBidInterval() {
       require(block.number < bidEnd || testing );
        _;
    }
    
    modifier inRevealInterval() {
        require((block.number < revealEnd && block.number > bidEnd) || testing);
        _;
    }
    
    modifier inVerifyInterval() {
        require((block.number < verifyEnd && block.number > revealEnd) || testing);
        _;
    }
    
	
	modifier inCheckoutInterval() {
         require ((block.number < checkoutEnd && block.number > verifyEnd)|| testing);   
        _;
    }
    
    modifier fainnessFeePaid() {
         require(msg.value >= fairnessFees );  //paying fees  
        _;
    }
    modifier thisStatePassed(AuctionState _auctionState) {
         require(state == _auctionState );  //paying fees  
        _;
    }
    /////////////////////////////////////////////////////////////////// Constructor = Setting all Parameters and auctioneerAddress as well
    constructor (uint _bidInterval,
                     uint _revealInterval,
                     uint _verifyInterval,
					 uint _checkoutInterval,
                     uint _maxBiddersCount,
                     uint _fairnessFees,
                     uint[2] memory _auctioneerPublicKey,
                     bool _testing ) public payable {
        require(msg.value >= _fairnessFees);
        auctioneerAddress = msg.sender;
        bidEnd = block.number + _bidInterval;
        revealEnd = bidEnd + _revealInterval;
        verifyEnd = revealEnd + _verifyInterval;
		checkoutEnd = verifyEnd + _checkoutInterval;
        maxBiddersCount = _maxBiddersCount;
        fairnessFees = _fairnessFees;
        auctioneerPublicKey = _auctioneerPublicKey;
		auctioneerDeposit = msg.value;		
        testing = _testing; 
        blockedDeposit = 0;
        guiltyNumber = 0;
    }
    /////////////////////////////////////////////////////////////////// biding
    
    function Bid(uint[2]memory commit , uint[2]memory pubKey) inBidInterval fainnessFeePaid public payable {
        require(indexs.length < maxBiddersCount ); //available slot    
        require(bidders[msg.sender].existing == false );
            bidders[msg.sender] = Bidder(commit , 0  , false , true , false , pubKey , msg.value);
            indexs.push(msg.sender);
    }
    
    function changeBid(uint[2]memory commit , uint[2]memory pubKey) inBidInterval public payable {
        require(bidders[msg.sender].existing == true );// a bidder can fix her bid
            bidders[msg.sender].commit = commit;
            bidders[msg.sender].pubKey = pubKey;
    }
    
    function Reveal(uint  cipher , uint[2]memory a , uint[2][2]memory b , uint[2]memory c , uint[8]memory input) inRevealInterval public {
        require(bidders[msg.sender].existing); //existing bidder
        require(bidders[msg.sender].revealed == false); // hasn't revealed before
        bidders[msg.sender].revealed = true;// she can't reveal again
        verifierCipher = VerifierCipher(0x89f3b997061682B5db303f0A3407915edc5f56fC);// not necessary anymore. this line can be removed
        require(input[0] == auctioneerPublicKey[0] && input[1] == auctioneerPublicKey[1]);//publick inputs of zkp are consistenet with data stored in smart contract
        require(input[2] == bidders[msg.sender].pubKey[0] && input[3] == bidders[msg.sender].pubKey[1]);//check if publick inputs of zkp are consistenet with data stored in smart contract
        require(input[4] == bidders[msg.sender].commit[0] && input[5] == bidders[msg.sender].commit[1]);//check if publick inputs of zkp are consistenet with data stored in smart contract
        require(input[6] == cipher );//publick inputs of zkp are consistenet with data stored in smart contract
        require(input[7] == 1);//check if publick inputs of zkp are consistenet with data stored in smart contract
        require((verifierCipher.verifyTx(a , b , c , input)));
        bidders[msg.sender].cipher = cipher;// if proof is right the cipher is saved
        // if her proof was wrong she would be recignized as one who hasn't revealed in the next phase becausethe cipher that has been saved for her is 0 by default in Bid()function
    }
    
    /////////////////////////////////////////////////////////////////// voting
	function checkIfAllBiddersRevealed() inVerifyInterval public{
		require(state !=  AuctionState.AllBiddersRevealed );//  this function just be called once
		for (uint i = 0; i < indexs.length ; i++) {
			if ( bidders[indexs[i]].cipher == 0 ){// this bidder hasn't revealed before
				bidders[indexs[i]].paidBack = true;
				bidders[indexs[i]].commit[0] = 0x00000000000000000000000000000000f5a5fd42d16a20302798ef6ed309979b; // hash of zero
				bidders[indexs[i]].commit[1] = 0x0000000000000000000000000000000043003d2320d9f0e8ea9831a92759fb4b;	
				blockedDeposit = blockedDeposit + bidders[indexs[i]].deposit;
			    guiltyNumber = guiltyNumber + 1;
			}
		}
		state = AuctionState.AllBiddersRevealed;
	}
  
	/*
    function AnnounceWinner( bytes32 _random , bytes32 _highestBid , address _winner)
    inVerifyInterval onlyAuctioneer thisStatePassed(AuctionState.AllBiddersRevealed) public{
		require(!bidders[_winner].paidBack);// winner shouldn't be guilty >> we dont need it because if the winner is guilty her commitment is zero and max cant be zero
        highestBid = uint(_highestBid);
        winner = _winner;
        bytes32 winnerCommit = sha256(_random , _highestBid);//<<consideration>> bid should be 32 bytes32
        bytes16[2] memory y = [bytes16(0), 0];
        assembly {
            mstore(y, winnerCommit)
            mstore(add(y, 16), winnerCommit)
        }
        if(!(uint(y[0]) == bidders[_winner].commit0 && uint(y[1]) == bidders[_winner].commit1)){
            auctioneerPaidBack = true;
            state = AuctionState.cheaterAuctioneer;
            revert("winner commitment isn't right");
        }
        state = AuctionState.WinnerAnnonced;
        
    }
    */
    
    function VerifyWinner( uint[2] memory a,
        uint[2][2]memory b,
        uint[2]memory c,
        uint[9]memory input,
        uint _highestBid,
        address _winnerAddress)
        inVerifyInterval onlyAuctioneer thisStatePassed(AuctionState.AllBiddersRevealed) public{
        highestBid = _highestBid;
        winner = _winnerAddress;
        //check if publick inputs of zkp are consistenet with data stored in smart contract
        if(!(input[0] == highestBid) || input[2] != bidders[winner].commit[0] || input[3] != bidders[winner].commit[1] || input[8] != 1){
            auctioneerPaidBack = true;
            state = AuctionState.cheaterAuctioneer;
            revert("proof isn't correct");
        }
        uint j = 0;
        for (uint i = 0; i < indexs.length ; i++) {// check if the auctioneer has sent correct commits
            if(indexs[i] != winner){
                if(!(bidders[indexs[i]].commit[0] == input[2 * j + 4]) || !(bidders[indexs[i]].commit[1] == input[2 * j + 5])){
                    auctioneerPaidBack = true;
                    state = AuctionState.cheaterAuctioneer;
                    revert("proof isn't correct");
                }
        
            j++;
            }
        }
        verifierWinner = VerifierWinner(0x91389e0d8309De52fdAAf33Cc0C216A7C5E19e83);
        if(!(verifierWinner.verifyTx(a , b , c  , input))){// auctioneer proff wasn't correct so she must be penalized
            auctioneerPaidBack = true;
            state = AuctionState.cheaterAuctioneer;
            //blockedDeposit = blockedDeposit + auctioneerDeposit;
            //guiltyNumber = guiltyNumber + 1;
            revert("proof isn't correct");
        }// if it isn't satisfied the auctioneer should be penalized and auction ends           
        state = AuctionState.Verified;
    }
    /////////////////////////////////////////////////////////////////// checkout
    
    uint extraDeposit; // blockedDeposit / guilty Number that should be given to honest bidders
    bool extraDepositCalculated;
    event WinnerPaid(string s);
    
    function Withdraw() inCheckoutInterval public {
        if(!extraDepositCalculated){// if extra deposit hasn't calculated before we must calculate it once
            if(state == AuctionState.Verified || state == AuctionState.cheaterAuctioneer){
                extraDeposit = blockedDeposit / (indexs.length + 1  - guiltyNumber);//calculate blockedDeposit divided by number of all bidders and auctioneer to distribute this blocked mobey to all honest bidders
            }
            else{// int his case auctioneer hasn't called checkIfAllBiddersRevealed() function or both checkIfAllBiddersRevealed() and verifyWinner() function or maybe her proof to verifuWinner wasn't verified correctly so we must add 1 to guilty number
                extraDeposit = (blockedDeposit + auctioneerDeposit) / (indexs.length + 1  - (guiltyNumber + 1));//calculate blockedDeposit divided by number of all bidders and auctioneer to distribute this blocked mobey to all honest bidders
            }
            extraDepositCalculated = false;// we don't need to calculate it more that once
        }
        
		if ( msg.sender == auctioneerAddress ){
			require( !auctioneerPaidBack );//hasn't be paid back before and isn't guilty
			require( state == AuctionState.Verified );//check that auctioneer has gone throuth the protocol compeletely and corectly
			require(withdrawLock == false);
			withdrawLock = true;
			msg.sender.transfer(auctioneerDeposit + extraDeposit);
			auctioneerPaidBack = true;
			withdrawLock = false;	
		}
		else{
		    require( bidders[msg.sender].existing && msg.sender != winner );
		    require( !bidders[msg.sender].paidBack );//hasn't be paid back before and isn't guilty
		    require(withdrawLock == false);
			withdrawLock = true;
			msg.sender.transfer(bidders[msg.sender].deposit + extraDeposit);
			bidders[msg.sender].paidBack = true;
			withdrawLock = false;
		}
    }
	
    function WinnerPay() inCheckoutInterval public payable {
        require(msg.sender == winner && bidders[msg.sender].existing);
        require(bidders[msg.sender].paidBack == false);
        if (state != AuctionState.Verified){//auctioneer hasn't claimed the winner correctly so the winner must be paid back
			require(withdrawLock == false);
			withdrawLock = true;
			msg.sender.transfer(bidders[msg.sender].deposit + extraDeposit);
			bidders[msg.sender].paidBack = true;
			withdrawLock = false;
			}
		else{
		    if(bidders[winner].deposit > highestBid){// in this case winner must give back some part of her deposit
			    require(withdrawLock == false);
			    withdrawLock = true;
			    emit WinnerPaid("winner paid successfully");
			    msg.sender.transfer(bidders[msg.sender].deposit + extraDeposit - highestBid);
			    bidders[msg.sender].paidBack = true;
			    withdrawLock = false;
			   
		    }
		    else if (bidders[winner].deposit <= highestBid){// in this case the winner must pay remaining money
		        if( msg.value >= highestBid - bidders[winner].deposit ){
		            emit WinnerPaid("winner paid successfully");
		        }
		        else{
		            revert();
		        }
		    }
		    
		}
        
    }
    
    function printfunc(uint index)public view returns(address , uint , uint , uint, bool , bool, uint , uint , bool , uint , uint ){
        Bidder memory bidder = bidders[indexs[index]];
        return (indexs[index]  ,
                bidder.commit[0] ,
                bidder.commit[1] ,
                bidder.cipher ,
                bidder.paidBack , 
                bidder.revealed , 
                bidder.deposit , 
                blockedDeposit,
                auctioneerPaidBack,
                guiltyNumber,
                extraDeposit);
    }
    

  


}
