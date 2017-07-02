import pytest
def test_greeter(chain):
    greeter, _ = chain.provider.get_or_deploy_contract('Greeter')

    greeting = greeter.call().greet()
    assert greeting == 'Hello'


def test_custom_greeting(chain, accounts, web3):
    greeter, _ = chain.provider.get_or_deploy_contract('Greeter')

    set_txn_hash = greeter.transact().setGreeting('Guten Tag')
    chain.wait.for_receipt(set_txn_hash)

    greeting = greeter.call().greet()
    assert greeting == 'Guten Tag' 

    
    myContract, _ = chain.provider.get_or_deploy_contract('msinsurancevo')
    print accounts
    
#Firstly, we check if a person registered or not;also we double check if the registeredperson list contains the person or not
    myContract.transact().checkifPersonRegistered(accounts[0]) 
    res1 = myContract.call().getRegisteredPerson(accounts[0]) #accessor
    print res1 #[u'0x0000000000000000000000000000000000000000', 0, False] ->means no, the person is not registered.
   
#Check if the person has paid or not
    myContract.transact().checkifPremiumPaid(accounts[0])
    res1 = myContract.call().getPremiumPaid(accounts[0])
    print res1 #[u'0x82a978b3f5962a5b0957d9ee9eef472ee55b42f1', 0] ->no, the person has not paid the premium.
  
#Calculate the premium amount
    res1 = myContract.call().calculatePremium(accounts[0]);
    print res1 #10 (for this test case)

#Firstly,we will see the balance of the person, then the person will pay, and we will check for premium payment status, 
#we also double check with the post balance of the person.
    prebalance = web3.eth.getBalance(accounts[0]) 
    print prebalance #1000030000000000000000000
    myContract.transact({"from": accounts[0], "value": res1}).payPremiumToRegister(); 
    myContract.transact().checkifPremiumPaid(accounts[0])
    res1 = myContract.call().getPremiumPaid(accounts[0])
    print res1 #[u'0x82a978b3f5962a5b0957d9ee9eef472ee55b42f1', 10] ->this address(person) has paid 10.
    postbalance = web3.eth.getBalance(accounts[0])
    print postbalance #1000039999999999999999990 ->see the decrease in the balance by 10.
    
#Now, we can register the person for this period, then we will check if she is registered or not.
    myContract.transact().registerPersontoPeriod(accounts[0])
    myContract.transact().checkifPersonRegistered(accounts[0])
    res1 = myContract.call().getRegisteredPerson(accounts[0])
    print res1 #[u'0x82a978b3f5962a5b0957d9ee9eef472ee55b42f1', 10, True] ->this person is registered and paid the premium of 10.

#Now this is the hospital part.We will check if the hospital is registered or not.
    myContract.transact().checkifHospitalRegistered(accounts[1])
    res1 = myContract.call().getRegisteredHospital(accounts[1])
    print res1 #[u'0x0000000000000000000000000000000000000000', 0, False] ->no it is not registered.
#Calculate the subscription amount we will pay
    res1 = myContract.call().calculateSubscription(accounts[1])
    print res1 #2 ->we will pay 2% subscription.
#Now, register hospital and check if it is registered.
    myContract.transact().registerHospitaltoPeriod(accounts[1],res1)
    myContract.transact().checkifHospitalRegistered(accounts[1])
    res1 = myContract.call().getRegisteredHospital(accounts[1])
    print res1 #[u'0x7d577a597b2742b498cb5cf0c26cdcd726d39e6e', 2, True] -> yes it is registered and we will pay 2% subs.
#Add Offer to hospital with a particular address, specify the name and description.
    myContract.transact().addOfferOfHospital(accounts[1],"Acibadem","TestDescription")
    res1 = myContract.call().getRegisteredHospitalOffer(accounts[1])
    print res1 #[u'0x7d577a597b2742b498cb5cf0c26cdcd726d39e6e', u'Acibadem', u'TestDescription'] -> This is offer's first part.
#Add Coverages and Prices to the offer of the hospital.
    myContract.transact().addOfferCoverageOfHospital(accounts[1],"KBB",100,80)
    myContract.transact().addOfferCoverageOfHospital(accounts[1],"Goz",50,10)
    res1 = myContract.call().getRegisteredHospitalOfferAfterCoverage(accounts[1])
    print res1 #[u'KBB', 100, 80, u'Goz', 50, 10]->KBB department's operations cost 100 eth and, 80% is covered.

#Now,display the vote of the person to this hospital. And also, display the hospital's 'yes' and 'no' votes.
#We do not expect see any votes, because we did not call vote function. And the results below is satisfactory.
    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
    print vote #0 ->no vote, yes will be 1 , no will be 2.
    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
    print vote1 #0 ->number of yes's
    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
    print vote2 #0 ->number of no's
    
#Now person will vote 'yes' to this hospital.
    myContract.transact().voteTheHospitalForPeriod(accounts[0],accounts[1],1)
    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
    print vote #1 ->yes
    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
    print vote1 #1 ->1 yes
    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
    print vote2 #0 -> 0 no
    
#   Below throws as expected, since patient gave the vote to this hospital. Checked.
#    myContract.transact().voteTheHospitalForPeriod(accounts[0],accounts[1],2)
#    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
#    print vote
#    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
#    print vote1
#    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
#    print vote2



#Now the patient will go to the hospital, and payments and claims will be done. 
    myContract.transact().startRecord(accounts[1],accounts[0],"KBB",100,80)
    prebalance = web3.eth.getBalance(accounts[0])
    print prebalance #1000089999999999999999990
    amount = myContract.call().getPatientAmount(1)
    print amount #20 -> calculated from the price and coverage.
    myContract.transact({"from": accounts[0], "value": amount}).payPatientPartion(1)
    postbalance = web3.eth.getBalance(accounts[0])
    print postbalance #1000094999999999999999970    ->decreased by 20, as expected.

    prebalancehosp = web3.eth.getBalance(accounts[1])
    print prebalancehosp
    amount = myContract.call().getHospitalAmount(1)
    print amount #100 ->price was 100
    myContract.transact().payHospitalThePrice(1)
    postbalance = web3.eth.getBalance(accounts[1])
    print postbalance

#Now we will pay the subscription amount to the hospital.
    prebalancehosp = web3.eth.getBalance(accounts[1])
    print prebalancehosp #1000000000000000000000000
    amount = myContract.call().getHospitalAmount(1)
    print amount #100 ->price was 100
    subs = myContract.call().getHospitalSubscription(1)
    print subs #2 ->2% of 100 is 2.
    myContract.transact().payHospitalTheSubscription(1)
    postbalance = web3.eth.getBalance(accounts[1])
    print postbalance #1000000000000000000000002 -> increased by 2, as expected.

#The number of records(patient goes to the hospital)We expect it to be 1.
    maxtrnxnum = myContract.call().displayTheMaxTrnxNum()
    print maxtrnxnum #1
#Period no, we're now in the first period, second period will start one year later.
    periodno = myContract.call().displayThePeriod()
    print periodno #1






