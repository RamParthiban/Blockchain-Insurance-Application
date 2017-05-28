pragma solidity ^0.4.7;
import "./msinsurancevo.sol";

library lib{

    struct Patient{
        bool premiumpaid;
        address patientaddress;
        uint premium;
        mapping(address=>uint) votinglist;

    }

    struct Hospital{
        address hospitaladdress;
        uint subspercentage;
        bool isregistered;
        bool isactive;

        bool isinvotestage;
        uint votecount1;
        uint votecount2;
        uint votestartdate;
        uint voteenddate;
        
        Offer hospitaloffer;
    }
    
    struct Offer{
        string hospitalname;
        address hospitaladdress;
        string offerdesc;
        string[] coveragedepts;
        uint[] prices;
        uint[] percentages;
    }
    
    struct Record{
        uint trnxId;
        address hospitaladdress;
        address patientaddress;
        uint date;
        string department;
        
        uint price;
        uint coverage;
        
        uint insuredamount;
        uint patientamount;
        uint subscriptionamount;
        
        bool doespatientpay;
        bool ishospitalpaid; 
        bool issubspaid;
        
        bool isactive;
    }


   function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (uint){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

	   abcde = string(babcde);

	   uint str_addr;
	   assembly { str_addr := abcde }	   
	   return str_addr;
    }

   
}
