// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const MockERC20 = await ethers.getContractFactory("MockERC20");
  const padToken = await MockERC20.deploy();

  await padToken.deployed();

  console.log("padToken deployed to:", padToken.address);

  const StakingContract = await ethers.getContractFactory("Staking");
  const staking = await StakingContract.deploy(padToken.address);

  await staking.deployed();

  console.log("Staking contract deployed to: ", staking.address);

  padToken.transfer(staking.address, ethers.utils.parseEther('10000'));

  console.log('contract volume: ', await padToken.balanceOf(staking.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
