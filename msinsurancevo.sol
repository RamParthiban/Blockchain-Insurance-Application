pragma solidity ^0.4.7;
import "./lib.sol";

contract msinsurancevo{
    using lib for lib.Patient;
    using lib for lib.Hospital;
    using lib for lib.Offer;
    using lib for lib.Record;

    //Patient Patient;
    uint public periodno;
    uint public startperiod; 
    uint public endperiod;
    uint public trnxIdCount ;
    
    mapping (address => uint) public paidpremium ;
    
    mapping (address => lib.Patient) registeredpatients ;
    mapping (uint => mapping(address => lib.Patient)) historypatient;
    
    mapping (address => lib.Hospital) registeredhospitals;
    mapping (uint => mapping(address => lib.Hospital)) historyhospital;
    
    mapping(address => lib.Offer) periodoffers;
    
    mapping(address => lib.Record) recordbypatient;
    mapping(address => lib.Record) recordbyhospital;
    mapping(uint => lib.Record) allrecords;
    
    mapping(uint => mapping(address=>lib.Record)) historytransbypatient;
    mapping(uint => mapping(address=>lib.Record)) historytransbyhospital;

    /* this runs when the contract is executed */
    function msinsurancevo() { 
        periodno = 1; 
        startperiod = now;
        endperiod = startperiod + 365;
        trnxIdCount = 1;
/*
        lib.Patient myPatient = registeredpatients[msg.sender];

        myPatient.premiumpaid = true;
        myPatient.patientaddress = msg.sender;
        myPatient.premium = 1;
        paidpremium[msg.sender] = 500;

        lib.Hospital myHospital = registeredhospitals[msg.sender];

        myHospital.hospitaladdress = msg.sender;
        myHospital.subspercentage = 2;
        myHospital.isregistered = true;
        myHospital.isactive = false;
        myHospital.isinvotestage = true;
        myHospital.votecount1 = 0;
        myHospital.votecount2 = 0;
        myHospital.votestartdate = now;
        myHospital.voteenddate = now + 365;

*/
    }

    function calculatePremium(address PersonAdd) constant returns(uint calculatedPremium){
        //to be filled, ins.
        calculatedPremium=10;
    }
    
    function calculateSubscription(address HospitalAdd) constant returns(uint subspercentage){
        //to be filled, ins.
        subspercentage=2;
    }
    
    function checkifPersonRegistered(address PersonAdd) constant returns (bool isregistered){
        if(registeredpatients[PersonAdd].premiumpaid){
            isregistered=true;
        }else{
            isregistered = false;
        }
        
    }
    
    function checkifHospitalRegistered(address HospitalAdd) constant returns (bool isregistered){
        if(registeredhospitals[HospitalAdd].isregistered)
            isregistered = true;
       else
            isregistered = false;            
    }
    
    function checkifPremiumPaid(address PersonAdd) constant returns (bool ispremiumpaid){
        ispremiumpaid=false;
        if(paidpremium[PersonAdd] != 0)
            ispremiumpaid=true;        
    }

            
    function payPremiumToRegister() public payable returns (bool paystatus){
        paidpremium[msg.sender] = msg.value;
        paystatus = true;
    }

    function payPatientPartion(uint trnx) public payable returns (bool paystatus) {
        paystatus = false;
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].patientamount;
            
            if(!allrecords[trnx].doespatientpay){
                if(msg.value >= amount){
                    allrecords[trnx].doespatientpay = true;
                    recordbyhospital[hsptAddr].doespatientpay = true;
                    recordbypatient[patAddr].doespatientpay = true;
                    
                    paystatus = true;
                }else throw;
            }else throw;
        }else throw;

    }

    function payHospitalThePrice(uint trnx) returns (bool paystatus) {
        paystatus = false;
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].price;
            
            if(!allrecords[trnx].ishospitalpaid && allrecords[trnx].doespatientpay){
                hsptAddr.send(amount);
                
                allrecords[trnx].ishospitalpaid = true;
                recordbyhospital[hsptAddr].ishospitalpaid = true;
                recordbypatient[patAddr].ishospitalpaid = true;
                
                paystatus = true;
            }else throw;
        }else throw;
    }
    
    function payHospitalTheSubscription(uint trnx) returns (bool paystatus) {
        paystatus = false;
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].subscriptionamount;
             
            if(!allrecords[trnx].issubspaid && allrecords[trnx].ishospitalpaid && allrecords[trnx].doespatientpay){
                hsptAddr.send(amount);
                
                allrecords[trnx].issubspaid = true;
                recordbyhospital[hsptAddr].issubspaid = true;
                recordbypatient[patAddr].issubspaid = true;
            }else throw;
            
            if(allrecords[trnx].doespatientpay && allrecords[trnx].ishospitalpaid && allrecords[trnx].issubspaid){
                allrecords[trnx].isactive = false;
                recordbyhospital[hsptAddr].isactive = false;
                recordbypatient[patAddr].isactive = false;
            }
            
            paystatus = true;
        }else throw;
    }

    
    function registerHospitaltoPeriod(address HospitalAdd, uint percentage) returns (bool registerstatus) {
        registerstatus = false;
        if(!checkifHospitalRegistered(HospitalAdd)){
          lib.Hospital myHospital = registeredhospitals[HospitalAdd];

            myHospital.isregistered = true;
            myHospital.hospitaladdress = HospitalAdd;
            myHospital.subspercentage = percentage;
            myHospital.isinvotestage = true;
            myHospital.isactive = false;
            myHospital.votecount1 = 0;
            myHospital.votecount2 = 0;
            myHospital.votestartdate = now;
            myHospital.voteenddate = myHospital.votestartdate + 7 days;
            myHospital.hasoffer = false;
            
            registerstatus = true;
        }
    }

    function registerPersontoPeriod(address PersonAdd) returns(bool registerstatus) {
        registerstatus = false;
        if(!checkifPersonRegistered(PersonAdd)){
            if(checkifPremiumPaid(PersonAdd)){
                 lib.Patient myPatient = registeredpatients[PersonAdd];
                myPatient.premiumpaid = true;
                myPatient.patientaddress = PersonAdd;
                myPatient.premium = paidpremium[PersonAdd];
                
                registerstatus = true;
            }
        }
    }
    
     function addOfferOfHospital(address HospitalAdd, string hospitalname, string hospitaldesc) returns (bool offerstatus)  {
        offerstatus = false;
         if(checkifHospitalRegistered(HospitalAdd)){  
          lib.Hospital myHospital = registeredhospitals[HospitalAdd];
            myHospital.hospitaloffer.hospitalname = hospitalname;
            myHospital.hospitaloffer.hospitaladdress = HospitalAdd;
            myHospital.hospitaloffer.offerdesc = hospitaldesc;
            myHospital.hasoffer = true;
            
            periodoffers[HospitalAdd].hospitalname = hospitalname;
            periodoffers[HospitalAdd].hospitaladdress = HospitalAdd;
            periodoffers[HospitalAdd].offerdesc = hospitaldesc;
            
            
            offerstatus = true;
         }else{
             throw;
         }
    }
    
    function addOfferCoverageOfHospital(address HospitalAdd, string covdep, uint covprice, uint covperc) returns (bool coveragestatus) {
        coveragestatus = false;
        if(checkifHospitalRegistered(HospitalAdd)){
            lib.Hospital myHospital = registeredhospitals[HospitalAdd];
            myHospital.hospitaloffer.coveragedepts.push(covdep);
            myHospital.hospitaloffer.prices.push(covprice);
            myHospital.hospitaloffer.percentages.push(covperc);

            periodoffers[HospitalAdd].coveragedepts.push(covdep);
            periodoffers[HospitalAdd].prices.push(covprice);
            periodoffers[HospitalAdd].percentages.push(covperc);
            
            coveragestatus = true;
        }else
            throw;
    }
    
    function voteTheHospitalForPeriod(address VoterAdd, address HospitalAdd, uint vote) returns (bool votestatus){
        votestatus = false;
        if(checkifPersonRegistered(VoterAdd) && checkifHospitalRegistered(HospitalAdd) && registeredhospitals[HospitalAdd].isinvotestage){
            if(registeredhospitals[HospitalAdd].voteenddate >= now){
                if(registeredpatients[VoterAdd].votinglist[HospitalAdd] != 1 && registeredpatients[VoterAdd].votinglist[HospitalAdd] != 2 ){
                    registeredpatients[VoterAdd].votinglist[HospitalAdd] = vote;
                    if(vote == 1)  registeredhospitals[HospitalAdd].votecount1 += 1;
                    else if(vote == 2)  registeredhospitals[HospitalAdd].votecount2 += 1;
                    votestatus = true;
                }
                else{
                    throw;
                }
            }else{
                registeredhospitals[HospitalAdd].isinvotestage = false;
                if(registeredhospitals[HospitalAdd].votecount1 >= registeredhospitals[HospitalAdd].votecount2){
                    registeredhospitals[HospitalAdd].isactive = true;
                }else{
                    registeredhospitals[HospitalAdd].isactive = false;
                }
            }
        }else {
            throw;
        }
    }
    
    function startRecord(address HospitalAdd, address PatientAdd, string deptName, uint price, uint coverage) returns (bool coveragestatus) {
        lib.Record myRecord = recordbyhospital[HospitalAdd];
        lib.Record myRecordP = recordbypatient[PatientAdd];
        lib.Record myRecordAll = allrecords[trnxIdCount];

        myRecordP.hospitaladdress = HospitalAdd;
        myRecord.hospitaladdress = HospitalAdd;
        myRecordAll.hospitaladdress = HospitalAdd;
        
        myRecordP.patientaddress = PatientAdd;
        myRecord.patientaddress = PatientAdd;
        myRecordAll.patientaddress = PatientAdd;
        
        myRecordP.date = now;
        myRecord.date = now;
        myRecordAll.date = now;
        
        myRecordP.department = deptName;
        myRecord.department = deptName;
        myRecordAll.department = deptName;
        
        myRecordP.price = price;
        myRecord.price = price;
        myRecordAll.price = price;
        
        myRecordP.coverage = coverage;
        myRecord.coverage = coverage;
        myRecordAll.coverage = coverage;
        
        myRecordP.insuredamount = price * coverage / 100;
        myRecord.insuredamount = price * coverage / 100;
        myRecordAll.insuredamount = price * coverage / 100;
        
        myRecordP.patientamount = price - (price * coverage / 100 );
        myRecord.patientamount =  price - (price * coverage / 100);
        myRecordAll.patientamount =  price - (price * coverage / 100);
        
        myRecordP.subscriptionamount = price * registeredhospitals[HospitalAdd].subspercentage / 100;
        myRecord.subscriptionamount = price * registeredhospitals[HospitalAdd].subspercentage / 100;
        myRecordAll.subscriptionamount = price * registeredhospitals[HospitalAdd].subspercentage / 100;
        
        if(myRecordAll.patientamount == 0){
            myRecordP.doespatientpay = true;
            myRecord.doespatientpay = true;
            myRecordAll.doespatientpay = true;
        }else{
            myRecordP.doespatientpay = false;
            myRecord.doespatientpay = false;
            myRecordAll.doespatientpay = false;
        }
        
        myRecordP.ishospitalpaid = false;
        myRecord.ishospitalpaid = false;
        myRecordAll.ishospitalpaid = false;
        
        myRecordP.issubspaid = false;
        myRecord.issubspaid = false;
        myRecordAll.issubspaid = false;
        
        myRecordP.isactive = true;
        myRecord.isactive = true;
        myRecordAll.isactive = true;
        
        trnxIdCount = trnxIdCount + 1;
    }
    

////////////////////////////////////////////////////////////////////////////////////////////
    function displayThePeriod () constant returns(uint periodnum){
        periodnum = periodno;
    }
    
    function displayTheMaxTrnxNum () constant returns(uint trnxNum){
        trnxNum = trnxIdCount -1;
    }
    
    function displayRecordDetails (uint recId) constant returns(string recdetails){
        lib.Record rec = allrecords[recId];
        recdetails = "";

        
        if(rec.doespatientpay) recdetails = strConcat(recdetails, "DoesPatientPay:", "TRUE", "--");
        else recdetails = strConcat(recdetails, "DoesPatientPay:", "FALSE", "--");
        
        if(rec.ishospitalpaid) recdetails = strConcat(recdetails, "IsHospitalPaid:", "TRUE", "--");
        else recdetails = strConcat(recdetails, "IsHospitalPaid:", "FALSE", "--");
        
        if(rec.issubspaid) recdetails = strConcat(recdetails, "IsSubsPaid:", "TRUE", "--");
        else recdetails = strConcat(recdetails, "IsSubsPaid:", "FALSE", "--");
        
        if(rec.isactive) recdetails = strConcat(recdetails, "IsActive:", "TRUE", "--");
        else recdetails = strConcat(recdetails, "IsActive:", "FALSE", "--");
       return recdetails;
    }
    
    function displayOffersOfHospital (address HospitalAdd) constant returns(string offerdetails){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        offerdetails = strConcat(theOffer.hospitalname, theOffer.offerdesc, "--");
        
        for(uint i = 0; i < theOffer.coveragedepts.length; i++){
            offerdetails = strConcat(offerdetails, theOffer.coveragedepts[i], "--");
            offerdetails = strConcat(offerdetails, frUintToString(theOffer.prices[i]), "--");
            offerdetails = strConcat(offerdetails, frUintToString(theOffer.percentages[i]), "--");
        }

    }

    function displayTheVote (address PersonAdd, address HospitalAdd) constant returns(uint vote){
        vote = registeredpatients[PersonAdd].votinglist[HospitalAdd];
    }
    
    function displayTheVoteCount1 (address HospitalAdd) constant returns(uint votecount){
        votecount = registeredhospitals[HospitalAdd].votecount1;
    }
    
    function displayTheVoteCount2 (address HospitalAdd) constant returns(uint votecount){
        votecount = registeredhospitals[HospitalAdd].votecount2;
    }
    
    function checkOffersOfHospital (address HospitalAdd) constant returns(bool offerstatus){
        offerstatus = registeredhospitals[HospitalAdd].hasoffer;
    }
    
    //

    function frAddresstoString(address x)  returns(string){
     bytes memory b = new bytes(20);
     for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
     return string(b);
    }
    
    
    function frUintToString(uint v) constant returns (string) {
          bytes32 ret;
            if (v == 0) {
                 ret = '0';
            }
            else {
                 while (v > 0) {
                      ret = bytes32(uint(ret) / (2 ** 8));
                      ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                      v /= 10;
                 }
            }

            bytes memory bytesString = new bytes(32);
            for (uint j=0; j<32; j++) {
                 byte char = byte(bytes32(uint(ret) * 2 ** (8 * j)));
                 if (char != 0) {
                      bytesString[j] = char;
                 }
            }

            return string(bytesString);
      }

   function strConcat(string _a, string _b, string _c, string _d, string _e) returns (string){
       uint str_addr = lib.strConcat(_a, _b, _c, _d, _e);
        string str;
        assembly{ str := str_addr }
        return str;

    }

    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    } 

//////////////FOR TESTING IN POPULUS////////////

    function getRegisteredPerson(address a) returns (address, uint, bool){
        lib.Patient test=registeredpatients[a];
        return (test.patientaddress,test.premium, test.premiumpaid);

    }
    function getPremiumPaid(address a) returns (address, uint){

        return (a,paidpremium[a]);

    }
    function getRegisteredHospital(address a) returns (address, uint, bool){
        lib.Hospital test=registeredhospitals[a];
        return (test.hospitaladdress,test.subspercentage, test.isregistered);

    }
    function getRegisteredHospitalOffer(address a) returns (address, string, string){
        lib.Hospital test = registeredhospitals[a];
        lib.Offer testoffer = test.hospitaloffer;
        return (testoffer.hospitaladdress,testoffer.hospitalname,testoffer.offerdesc);
    }
    function getRegisteredHospitalOfferAfterCoverage(address a) returns (string, uint, uint,string,uint,uint){
        lib.Hospital test = registeredhospitals[a];
        lib.Offer testoffer = test.hospitaloffer;
        return (testoffer.coveragedepts[0],testoffer.prices[0],testoffer.percentages[0],testoffer.coveragedepts[1],testoffer.prices[1],testoffer.percentages[1]);
    }
    function getPatientAmount(uint trnx) returns (uint){
        uint amount = allrecords[trnx].patientamount;
        return amount;
    }
    function getHospitalAmount(uint trnx) returns (uint){
        uint amount = allrecords[trnx].price;
        return amount;
    }
    function getHospitalSubscription(uint trnx) returns (uint){
        uint subs = allrecords[trnx].subscriptionamount;
        return subs;
    }

}