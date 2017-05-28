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
    

    myContract.transact().checkifPersonRegistered(accounts[0])
    res1 = myContract.call().getRegisteredPerson(accounts[0])
    print res1
   
    
    myContract.transact().checkifPremiumPaid(accounts[0])
    res1 = myContract.call().getPremiumPaid(accounts[0])
    print res1
  

    res1 = myContract.call().calculatePremium(accounts[0]);
    print res1
    
    prebalance = web3.eth.getBalance(accounts[0])
    print prebalance
    myContract.transact({"from": accounts[0], "value": res1}).payPremiumToRegister();
    myContract.transact().checkifPremiumPaid(accounts[0])
    res1 = myContract.call().getPremiumPaid(accounts[0])
    print res1
    postbalance = web3.eth.getBalance(accounts[0])
    print postbalance

    myContract.transact().registerPersontoPeriod(accounts[0])
    myContract.transact().checkifPersonRegistered(accounts[0])
    res1 = myContract.call().getRegisteredPerson(accounts[0])
    print res1


    myContract.transact().checkifHospitalRegistered(accounts[1])
    res1 = myContract.call().getRegisteredHospital(accounts[1])
    print res1

    res1 = myContract.call().calculateSubscription(accounts[1])
    print res1

    myContract.transact().registerHospitaltoPeriod(accounts[1],res1)
    myContract.transact().checkifHospitalRegistered(accounts[1])
    res1 = myContract.call().getRegisteredHospital(accounts[1])
    print res1

    myContract.transact().addOfferOfHospital(accounts[1],"Acibadem","TestDescription")
    res1 = myContract.call().getRegisteredHospitalOffer(accounts[1])
    print res1

    myContract.transact().addOfferCoverageOfHospital(accounts[1],"KBB",100,80)
    myContract.transact().addOfferCoverageOfHospital(accounts[1],"Goz",50,10)
    res1 = myContract.call().getRegisteredHospitalOfferAfterCoverage(accounts[1])
    print res1
    
    offer = myContract.call().displayOffersOfHospital(accounts[1])
    print offer

    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
    print vote
    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
    print vote1
    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
    print vote2

    myContract.transact().voteTheHospitalForPeriod(accounts[0],accounts[1],1)
    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
    print vote
    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
    print vote1
    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
    print vote2

#   Below throws as expected, since patient gave the vote to this hospital. Checked.
#    myContract.transact().voteTheHospitalForPeriod(accounts[0],accounts[1],2)
#    vote = myContract.call().displayTheVote(accounts[0],accounts[1])
#    print vote
#    vote1 = myContract.call().displayTheVoteCount1(accounts[1])
#    print vote1
#    vote2 = myContract.call().displayTheVoteCount2(accounts[1])
#    print vote2

    myContract.transact().startRecord(accounts[1],accounts[0],"KBB",100,80)
    prebalance = web3.eth.getBalance(accounts[0])
    print prebalance
    amount = myContract.call().getPatientAmount(1)
    print amount
    myContract.transact({"from": accounts[0], "value": amount}).payPatientPartion(1)
    postbalance = web3.eth.getBalance(accounts[0])
    print postbalance
    
    detail = myContract.call().displayRecordDetails(1)
    print detail

    prebalancehosp = web3.eth.getBalance(accounts[1])
    print prebalancehosp
    amount = myContract.call().getHospitalAmount(1)
    print amount
    subs = myContract.call().getHospitalSubscription(1)
    print subs
    myContract.transact().payHospitalThePrice(1)
    postbalance = web3.eth.getBalance(accounts[1])
    print postbalance

    prebalancehosp = web3.eth.getBalance(accounts[1])
    print prebalancehosp
    amount = myContract.call().getHospitalAmount(1)
    print amount
    subs = myContract.call().getHospitalSubscription(1)
    print subs
    myContract.transact().payHospitalTheSubscription(1)
    postbalance = web3.eth.getBalance(accounts[1])
    print postbalance

    maxtrnxnum = myContract.call().displayTheMaxTrnxNum()
    print maxtrnxnum

    periodno = myContract.call().displayThePeriod()
    print periodno




