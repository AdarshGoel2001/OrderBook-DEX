// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, network } = require("hardhat");

async function main() {
  const Grid = await ethers.getContractFactory("Grid");
  const grid = await Grid.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  await grid.deployed();
  console.log(grid.address);

  [deployer, account1, account2, account3, account4, account5, account6] =
    await ethers.getSigners();

  const params = {
    from: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    to: grid.address,
    value: ethers.utils.parseEther("50"),
  };
  deployer.sendTransaction(params).then((transaction) => {
    console.log(transaction);
  });

  const Router = await ethers.getContractFactory("Router");
  const router = await Router.deploy(grid.address);
  await router.deployed();
  console.log(router.address);

  const txn = await grid.setRouter(router.address);
  txn.wait();

  const sdf = await router
    .whitelist("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
    .then((res) => console.log(""));
  const ba = await router
    .whitelist("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
    .then((res) => console.log("D"));
  const grsb = await router
    .whitelist("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")
    .then((res) => console.log("d"));
  const stb = await router
    .whitelist("0x90F79bf6EB2c4f870365E785982E1f101E93b906")
    .then((res) => console.log("v"));

  const txn6 = await router.connect(account1).placeOrder(
    // buy order for 10 units @ 5
    10,
    false,
    5,
    true,
    {
      value: ethers.utils.parseEther("50"),
    }
  );
  txn6.wait();

  const p21 = await grid
    .getAvCurrentPrice()
    .then((res) => console.log("current av price - ", res));
  const p22 = await grid
    .getCurrentPrice(true)
    .then((res) => console.log("current highest buy price - ", res));
  const p23 = await grid
    .getCurrentPrice(false)
    .then((res) => console.log("current lowest sell price - ", res));

  const txn7 = await router.connect(account1).placeOrder(
    // buy order for 10 units @ 6
    10,
    false,
    6,
    true,
    {
      value: ethers.utils.parseEther("60"),
    }
  );

  const p31 = await grid
    .getAvCurrentPrice()
    .then((res) => console.log("current av price - ", res));
  const p32 = await grid
    .getCurrentPrice(true)
    .then((res) => console.log("current highest buy price - ", res));
  const p33 = await grid
    .getCurrentPrice(false)
    .then((res) => console.log("current lowest sell price - ", res));

  const txn8 = await router.connect(account2).placeOrder(
    // sell order for 10 units @ 6
    10,
    false,
    6,
    false,
    {
      value: ethers.utils.parseEther("60"),
    }
  );
  const p41 = await grid
    .getAvCurrentPrice()
    .then((res) => console.log("current av price - ", res));
  const p42 = await grid
    .getCurrentPrice(true)
    .then((res) => console.log("current highest buy price - ", res));
  const p43 = await grid
    .getCurrentPrice(false)
    .then((res) => console.log("current lowest sell price - ", res));

  const txn90 = await router.connect(account1).placeOrder(
    // sell order for 10 units @ 8
    30,
    false,
    5,
    false,
    {
      value: ethers.utils.parseEther("150"),
    }
  );

  const txkfn7 = await router
    .connect(account1)
    .placeOrder(50, false, 60, false);
  txkfn7.wait();
  const currr = await grid.getAvCurrentPrice().then((res) => console.log(res));

  const curr = await grid.getAvCurrentPrice().then((res) => res.toString());
  turr = curr.concat("00");

  const p51 = await grid
    .getAvCurrentPrice()
    .then((res) => console.log("current av price - ", res));
  const p52 = await grid
    .getCurrentPrice(true)
    .then((res) => console.log("current highest buy price - ", res));
  const p53 = await grid
    .getCurrentPrice(false)
    .then((res) => console.log("current lowest sell price - ", res));

  // console.log(grid.getAvCurrentPrice());
  const txn9 = await router.connect(account3).placeOrder(150, false, 70, false);
  txn9.wait();

  const txn9e = await router.connect(account3).placeOrder(50, false, 60, true);
  txn9.wait();
  const tru = await grid.getAvCurrentPrice().then((res) => console.log(res));

  console.log("aaaaannnnneeeee WAAALALALAL AHAIOAIAIAIIAA");

  const uvikv = await grid
    .getOrdersForAddress("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
    .then((res) => console.log(res));

  const a1 = await grid
    .getNextExe("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
    .then((res) => console.log(res));
  const a12 = await grid
    .getNextExe("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
    .then((res) => console.log(res));
  const a122 = await grid
    .getNextExe("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")
    .then((res) => console.log(res));
  const a1222 = await grid
    .getNextExe("0x90F79bf6EB2c4f870365E785982E1f101E93b906")
    .then((res) => console.log(res));
  // console.log(grid.getAvCurrentPrice());
  const sufbvuwb = await grid
    .updateTimeStamp(168214915)
    .then((res) => console.log("wohoo"));
  const sr = await grid
    .updateAllEXEbalances()
    .then((res) => console.log("wohoo"));
  const ssss = await grid.inOrderSell().then((res) => console.log(res));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
