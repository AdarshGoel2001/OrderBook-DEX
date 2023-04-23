// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const Grid = await hre.ethers.getContractFactory("Grid");
  const grid = await Grid.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  await grid.deployed();

  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy(
    grid.address(),
    "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8"
  );
  await router.deployed();

  const txn = await grid.setRouter(router.address);
  txn.wait();

  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
