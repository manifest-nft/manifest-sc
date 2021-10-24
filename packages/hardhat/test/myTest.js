const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("Manifest", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("Manifest");

      myContract = await YourContract.deploy();
    });
  });
});
