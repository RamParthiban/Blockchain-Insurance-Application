pragma solidity ^0.4.7;

library lib{

    struct Patient{
        bool premiumpaid;
        address patientaddress;
        uint premium;
        mapping(address=>uint) votinglist;

        uint recordcount;
        uint[] patrecordids;
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
        
        bool hasoffer;
        uint recordcount;
        
        uint[] hosprecordids;
        
        Offer hospitaloffer;
    }
    
    struct Offer{
        string hospitalname;
        address hospitaladdress;
        string offerdesc;
        uint covercount;
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
        
        bool ispatapproved;
        bool doespatientpay;
        bool ishospitalpaid; 
        bool issubspaid;
        
        bool isactive;
    }


   
}
