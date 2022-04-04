const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CroToken ", function () {
  it("Private Sale test", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const CroToken = await ethers.getContractFactory("CroToken");
    const croToken = await CroToken.deploy();
    await croToken.deployed();
    const listingPrice = ethers.utils.parseUnits('750000', 'ether');
    await croToken.setPrivateWhiteList([owner.address, addr1.address], [listingPrice, listingPrice]);
    await croToken.setPrivateTgeTime('121234');
    console.log(await croToken.private_locks(owner.address));    
    console.log(await croToken.private_released(owner.address));    
    await croToken.connect(owner).privateClaim();
    console.log(await croToken.balanceOf(owner.address));  
    console.log(croToken.address);

    // private sale



    // expect(await greeter.greet()).to.equal("Hello, world!");

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
