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
    address[] reghospitaladdrs;
    
    mapping(address => lib.Offer) periodoffers;
    
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
        calculatedPremium=500;
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

    function payPatientPartion(address PatAddr, uint index) public payable returns (bool paystatus) {
        paystatus = false;
        uint trnx = registeredpatients[PatAddr].patrecordids[index];
        
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].patientamount;
            
            if(!allrecords[trnx].doespatientpay){
                if(msg.value >= amount){
                    allrecords[trnx].doespatientpay = true;
                    
                    paystatus = true;
                }else throw;
            }else throw;
        }else throw;

    }

    function payHospitalThePrice(address PatAddr, uint index) returns (bool paystatus) {
        paystatus = false;
        uint trnx = registeredpatients[PatAddr].patrecordids[index];
        
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].price;
            
            if(!allrecords[trnx].ishospitalpaid && allrecords[trnx].doespatientpay){
                if(amount == 100) hsptAddr.send(100 ether);
                if(amount == 200) hsptAddr.send(200 ether);
                if(amount == 300) hsptAddr.send(300 ether);
                if(amount == 400) hsptAddr.send(400 ether);
                if(amount == 500) hsptAddr.send(500 ether);
                if(amount == 600) hsptAddr.send(600 ether);
                if(amount == 700) hsptAddr.send(700 ether);
                if(amount == 800) hsptAddr.send(800 ether);
                if(amount == 900) hsptAddr.send(900 ether);
                if(amount == 1000) hsptAddr.send(1000 ether);
                
                allrecords[trnx].ishospitalpaid = true;
                
                paystatus = true;
            }else throw;
        }else throw;
    }
    
    function payHospitalTheSubscription(address PatAddr, uint index) returns (bool paystatus) {
        paystatus = false;
        uint trnx = registeredpatients[PatAddr].patrecordids[index];
        
        if(allrecords[trnx].isactive){
            address hsptAddr = allrecords[trnx].hospitaladdress;
            address patAddr = allrecords[trnx].patientaddress;
            uint amount = allrecords[trnx].subscriptionamount;
             
            if(!allrecords[trnx].issubspaid && allrecords[trnx].ishospitalpaid && allrecords[trnx].doespatientpay){
                if(amount == 2) hsptAddr.send(2 ether);
                if(amount == 4) hsptAddr.send(4 ether);
                if(amount == 6) hsptAddr.send(6 ether);
                if(amount == 8) hsptAddr.send(8 ether);
                if(amount == 10) hsptAddr.send(10);
                if(amount == 12) hsptAddr.send(12 ether);
                if(amount == 14) hsptAddr.send(14 ether);
                if(amount == 16) hsptAddr.send(16 ether);
                if(amount == 18) hsptAddr.send(18 ether);
                if(amount == 20) hsptAddr.send(20 ether);
                
                allrecords[trnx].issubspaid = true;
            }else throw;
            
            if(allrecords[trnx].doespatientpay && allrecords[trnx].ishospitalpaid && allrecords[trnx].issubspaid){
                allrecords[trnx].isactive = false;
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
            myHospital.recordcount = 0;
            
            registerstatus = true;
            
            reghospitaladdrs.push(HospitalAdd);
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
            myHospital.hospitaloffer.covercount = 0;
            myHospital.hasoffer = true;
            
            periodoffers[HospitalAdd].hospitalname = hospitalname;
            periodoffers[HospitalAdd].hospitaladdress = HospitalAdd;
            periodoffers[HospitalAdd].offerdesc = hospitaldesc;
            periodoffers[HospitalAdd].covercount = 0;
            
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
            myHospital.hospitaloffer.covercount = myHospital.hospitaloffer.covercount + 1;

            periodoffers[HospitalAdd].coveragedepts.push(covdep);
            periodoffers[HospitalAdd].prices.push(covprice);
            periodoffers[HospitalAdd].percentages.push(covperc);
            periodoffers[HospitalAdd].covercount = periodoffers[HospitalAdd].covercount + 1;
            
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
    
    function startRecord(address HospitalAdd, address PatientAdd, string deptName) returns (bool coveragestatus) {
        uint price = getPriceofDeptofHos(HospitalAdd,deptName);
        uint coverage = getPercofDeptofHos(HospitalAdd,deptName);
        
        lib.Record myRecordAll = allrecords[trnxIdCount];

        myRecordAll.hospitaladdress = HospitalAdd;
        
        myRecordAll.patientaddress = PatientAdd;
        
        myRecordAll.date = now;
        
        myRecordAll.department = deptName;

        myRecordAll.price = price;
        
        myRecordAll.coverage = coverage;
        
        myRecordAll.insuredamount = price * coverage / 100;

        myRecordAll.patientamount =  price - (price * coverage / 100);
        
        myRecordAll.subscriptionamount = price * registeredhospitals[HospitalAdd].subspercentage / 100;
        
        if(myRecordAll.patientamount == 0){
            myRecordAll.doespatientpay = true;
        }else{
            myRecordAll.doespatientpay = false;
        }
        
        myRecordAll.ispatapproved = false;
        
        myRecordAll.ishospitalpaid = false;
        
        myRecordAll.issubspaid = false;
        
        myRecordAll.isactive = true;
        
        registeredhospitals[HospitalAdd].hosprecordids.push(trnxIdCount);
        registeredhospitals[HospitalAdd].recordcount ++;
        
        registeredpatients[PatientAdd].patrecordids.push(trnxIdCount);
        registeredpatients[PatientAdd].recordcount ++;
        
        trnxIdCount = trnxIdCount + 1;
    }
    

////////////////////////////////////////////////////////////////////////////////////////////
    function displayThePeriod () constant returns(uint periodnum){
        periodnum = periodno;
    }
    
    function displayTheMaxTrnxNum () constant returns(uint trnxNum){
        trnxNum = trnxIdCount -1;
    }
    
    function getHospNameofOffer (address HospitalAdd) constant returns(string offerhospname){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        offerhospname = theOffer.hospitalname;

    }
    
    function getDescofOffer (address HospitalAdd) constant returns(string offerdesc){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        offerdesc = theOffer.offerdesc;

    }
    
    function getCoverCountofOffer (address HospitalAdd) constant returns(uint covercount){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        covercount = theOffer.covercount;
    }
    
    function getDescofCoverage (address HospitalAdd, uint index) constant returns(string coverdesc){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        coverdesc = theOffer.coveragedepts[index];
    }
    
    function getPricecofCoverage (address HospitalAdd, uint index) constant returns(uint coverprice){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        coverprice = theOffer.prices[index];
    }
    
    function getPerccofCoverage (address HospitalAdd, uint index) constant returns(uint coverperc){
        lib.Offer theOffer = registeredhospitals[HospitalAdd].hospitaloffer;
        coverperc = theOffer.percentages[index];
    }
    
    function getHospStatus (address HospitalAdd) constant returns(string hospstatus){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        if (theHospital.isinvotestage)  hospstatus = "ISINVOTE";
        else{
            if(theHospital.isactive) hospstatus = "ACTIVE";
            else hospstatus = "PASSIVE";
        }
    }
    
    function getHosRecordCount (address HospitalAdd) constant returns(uint reccount){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        reccount = theHospital.recordcount;
    }
    
    function getRecordPatAddr (address HospitalAdd, uint index) constant returns(address pataddr){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        uint recID = theHospital.hosprecordids[index];
        pataddr = allrecords[recID].patientaddress;
    }
    
    function getRecordDepartment (address HospitalAdd, uint index) constant returns(string deptname){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        uint recID = theHospital.hosprecordids[index];
        deptname = allrecords[recID].department;
    }
    
    function getRecordPatPayStat (address HospitalAdd, uint index) constant returns(bool status){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        uint recID = theHospital.hosprecordids[index];
        status = allrecords[recID].doespatientpay;
    }
    
    function getRecordHosPaidStat (address HospitalAdd, uint index) constant returns(bool status){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        uint recID = theHospital.hosprecordids[index];
        status = allrecords[recID].ishospitalpaid;
    }
    
    function getRecordSubscPaidStat (address HospitalAdd, uint index) constant returns(bool status){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        uint recID = theHospital.hosprecordids[index];
        status = allrecords[recID].issubspaid;
    }
    
    function getPatRecordCount (address PatientAdd) constant returns(uint reccount){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        reccount = thePatient.recordcount;
    }
    
    function getPatRecordHosAddr (address PatientAdd, uint index) constant returns(address hosaddr){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        hosaddr = allrecords[recID].hospitaladdress;
    }
    
    function getPatRecordDepartment (address PatientAdd, uint index) constant returns(string deptname){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        deptname = allrecords[recID].department;
    }
    
    function getPatRecordPatPayStat (address PatientAdd, uint index) constant returns(bool status){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        status = allrecords[recID].doespatientpay;
    }
    
    function getPatRecordInsrAmnt (address PatientAdd, uint index) constant returns(uint insamnt){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        insamnt = allrecords[recID].insuredamount;
    }
    
    function getPatRecordPatAmnt (address PatientAdd, uint index) constant returns(uint patamnt){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        patamnt = allrecords[recID].patientamount;
    }
    
    function getPatRecordApprStat (address PatientAdd, uint index) constant returns(bool patappstat){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        patappstat = allrecords[recID].ispatapproved;
    }
    
    function approvePatRecord (address PatientAdd, uint index) returns(bool patstat){
        lib.Patient thePatient = registeredpatients[PatientAdd];
        uint recID = thePatient.patrecordids[index];
        
        allrecords[recID].ispatapproved = true;
        patstat = true;
    }
    
    function getPriceofDeptofHos (address HospitalAdd, string deptname) constant returns(uint price){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        lib.Offer theOffer = theHospital.hospitaloffer;
        
        price = 0;
        for(uint i=0; i<theOffer.coveragedepts.length; i++){
            string tempdept = theOffer.coveragedepts[i];
            if(stringsEqual(tempdept, deptname))
                price = theOffer.prices[i];
        }
    }
    
    function getPercofDeptofHos (address HospitalAdd, string deptname) constant returns(uint perc){
        lib.Hospital theHospital = registeredhospitals[HospitalAdd];
        lib.Offer theOffer = theHospital.hospitaloffer;
        
        perc = 0;
        for(uint i=0; i<theOffer.coveragedepts.length; i++){
            string tempdept = theOffer.coveragedepts[i];
            if(stringsEqual(tempdept, deptname))
                perc = theOffer.percentages[i];
        }
    }
    
    function getTheNumberofHos () constant returns(uint count){
        count = reghospitaladdrs.length;
    }
    
    function getTheAddrofHos (uint indexval) constant returns(address hospAddr){
        hospAddr = reghospitaladdrs[0];
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
    
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}

    function frAddresstoString(address x)  returns(string){
     bytes memory b = new bytes(20);
     for (uint i = 0; i < 20; i++)
        b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
     return string(b);
    }


//////////////FOR TESTING IN POPULUS////////////

    function getRegisteredPerson(address a) constant returns (address, uint, bool){
        lib.Patient test=registeredpatients[a];
        return (test.patientaddress,test.premium, test.premiumpaid);

    }
    function getPremiumPaid(address a) constant returns (address, uint){

        return (a,paidpremium[a]);

    }
    function getRegisteredHospital(address a) constant returns (address, uint, bool){
        lib.Hospital test=registeredhospitals[a];
        return (test.hospitaladdress,test.subspercentage, test.isregistered);

    }
    function getRegisteredHospitalOffer(address a) constant returns (address, string, string){
        lib.Hospital test = registeredhospitals[a];
        lib.Offer testoffer = test.hospitaloffer;
        return (testoffer.hospitaladdress,testoffer.hospitalname,testoffer.offerdesc);
    }
    function getRegisteredHospitalOfferAfterCoverage(address a) constant returns (string, uint, uint,string,uint,uint){
        lib.Hospital test = registeredhospitals[a];
        lib.Offer testoffer = test.hospitaloffer;
        return (testoffer.coveragedepts[0],testoffer.prices[0],testoffer.percentages[0],testoffer.coveragedepts[1],testoffer.prices[1],testoffer.percentages[1]);
    }
    function getPatientAmount(uint trnx) constant returns (uint){
        uint amount = allrecords[trnx].patientamount;
        return amount;
    }
    function getHospitalAmount(uint trnx) constant returns (uint){
        uint amount = allrecords[trnx].price;
        return amount;
    }
    function getHospitalSubscription(uint trnx) constant returns (uint){
        uint subs = allrecords[trnx].subscriptionamount;
        return subs;
    }

}