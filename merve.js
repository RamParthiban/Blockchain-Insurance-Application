var Tx = require('ethereumjs-tx')
var Web3 = require('web3');
var web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

if(!web3.isConnected()) {
    console.log("not connected");
}

var Tx = require('ethereumjs-tx');
var privateKey = new Buffer('8c285341c3b8193206afeb3289591db9d1ed6a904283d515a1b7a2b8be1d5b89', 'hex')

web3.eth.defaultAccount=web3.eth.accounts[0]

var rawTx = {
  nonce: '0x9',
  gas: '0x5208',
  gasPrice: '0x4a',
  to: '0x0000000000000000000000000000000000000000',
  value: '0x00',
  data: '0x7f7465737432000000000000000000000000000000000000000000000000000000600057'
}

rawTx.nonce = web3.eth.getTransactionCount("0x71d86900335b93560d4e71f752d89582a01ac1f4") ; 

var tx = new Tx(rawTx);
tx.sign(privateKey);

var serializedTx = tx.serialize();

console.log(serializedTx.toString('hex'));

web3.eth.sendRawTransaction("0x"+serializedTx.toString('hex'))
