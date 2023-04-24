// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, network } = require("hardhat");

async function main() {
  const usdcAddress = "0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8";

  const Grid = await ethers.getContractFactory("Grid");
  const grid = await Grid.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  await grid.deployed();
  console.log(grid.address);
  const trueRoot = await grid.getRootTree(true).then((res) => console.log(res));
  const falseRoot = await grid
    .getRootTree(false)
    .then((res) => console.log(res));
  // trueRoot.wait();
  // falseRoot.wait();
  // console.log("trueRoot", trueRoot);
  // console.log("falseRoot", falseRoot);

  const Router = await ethers.getContractFactory("Router");
  const router = await Router.deploy(grid.address, usdcAddress);
  await router.deployed();
  console.log(router.address);

  const txn = await grid.setRouter(router.address);
  txn.wait();

  const richUSDCGuy = "0x7B7B957c284C2C227C980d6E2F804311947b84d0";
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [richUSDCGuy],
  });
  const impersonatedSigner = await ethers.getSigner(richUSDCGuy);
  const usdcABI = [
    {
      constant: true,
      inputs: [],
      name: "name",
      outputs: [
        {
          name: "",
          type: "string",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: false,
      inputs: [
        {
          name: "_spender",
          type: "address",
        },
        {
          name: "_value",
          type: "uint256",
        },
      ],
      name: "approve",
      outputs: [
        {
          name: "",
          type: "bool",
        },
      ],
      payable: false,
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      constant: true,
      inputs: [],
      name: "totalSupply",
      outputs: [
        {
          name: "",
          type: "uint256",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: false,
      inputs: [
        {
          name: "_from",
          type: "address",
        },
        {
          name: "_to",
          type: "address",
        },
        {
          name: "_value",
          type: "uint256",
        },
      ],
      name: "transferFrom",
      outputs: [
        {
          name: "",
          type: "bool",
        },
      ],
      payable: false,
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      constant: true,
      inputs: [],
      name: "decimals",
      outputs: [
        {
          name: "",
          type: "uint8",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: true,
      inputs: [
        {
          name: "_owner",
          type: "address",
        },
      ],
      name: "balanceOf",
      outputs: [
        {
          name: "balance",
          type: "uint256",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: true,
      inputs: [],
      name: "symbol",
      outputs: [
        {
          name: "",
          type: "string",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      constant: false,
      inputs: [
        {
          name: "_to",
          type: "address",
        },
        {
          name: "_value",
          type: "uint256",
        },
      ],
      name: "transfer",
      outputs: [
        {
          name: "",
          type: "bool",
        },
      ],
      payable: false,
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      constant: true,
      inputs: [
        {
          name: "_owner",
          type: "address",
        },
        {
          name: "_spender",
          type: "address",
        },
      ],
      name: "allowance",
      outputs: [
        {
          name: "",
          type: "uint256",
        },
      ],
      payable: false,
      stateMutability: "view",
      type: "function",
    },
    {
      payable: true,
      stateMutability: "payable",
      type: "fallback",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          name: "owner",
          type: "address",
        },
        {
          indexed: true,
          name: "spender",
          type: "address",
        },
        {
          indexed: false,
          name: "value",
          type: "uint256",
        },
      ],
      name: "Approval",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          name: "from",
          type: "address",
        },
        {
          indexed: true,
          name: "to",
          type: "address",
        },
        {
          indexed: false,
          name: "value",
          type: "uint256",
        },
      ],
      name: "Transfer",
      type: "event",
    },
  ];

  let usdcContract = await new ethers.Contract(
    usdcAddress,
    usdcABI,
    impersonatedSigner
  );

  const txn2 = await usdcContract.transfer(
    "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    ethers.utils.parseUnits("100000", 6)
  );
  txn2.wait();

  console.log(
    usdcContract.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  );
  const txn3 = await usdcContract.transfer(
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    ethers.utils.parseUnits("100000", 6)
  );
  txn3.wait();

  console.log(
    usdcContract.balanceOf("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
  );
  const txn4 = await usdcContract.transfer(
    "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    ethers.utils.parseUnits("100000", 6)
  );
  txn4.wait();
  console.log(
    usdcContract.balanceOf("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC")
  );
  const txn5 = await usdcContract.transfer(
    "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    ethers.utils.parseUnits("100000", 6)
  );
  txn5.wait();
  console.log(
    usdcContract.balanceOf("0x90F79bf6EB2c4f870365E785982E1f101E93b906")
  );

  [deployer, account1, account2, account3] = await ethers.getSigners();

  const tumtum = await usdcContract
    .connect(deployer)
    .approve(router.address, ethers.utils.parseUnits("5000", 6));
  const txn6 = await router.placeOrder(100, false, 50, true);
  txn6.wait();
  const trueRoo = await grid
    .getAvCurrentPrice()
    .then((res) => console.log(res));
  const tamt = await usdcContract
    .connect(account1)
    .approve(router.address, ethers.utils.parseUnits("3000", 6));
  const txn7 = await router.connect(account1).placeOrder(50, false, 60, false);
  txn7.wait();
  const kh = await usdcContract
    .connect(account1)
    .approve(router.address, ethers.utils.parseUnits("3000", 6));
  const txyfn7 = await router
    .connect(account1)
    .placeOrder(50, false, 60, false);
  txyfn7.wait();
  const thvamt = await usdcContract
    .connect(account1)
    .approve(router.address, ethers.utils.parseUnits("3000", 6));
  const txkfn7 = await router
    .connect(account1)
    .placeOrder(50, false, 60, false);
  txkfn7.wait();
  const currr = await grid.getAvCurrentPrice().then((res) => console.log(res));

  const curr = await grid.getAvCurrentPrice().then((res) => res.toString());
  turr = curr.concat("00");
  const srgs = await usdcContract
    .connect(account2)
    .approve(router.address, ethers.utils.parseUnits(turr, 6));
  const txn8 = await router.connect(account2).placeOrder(100, true, 0, true);
  txn8.wait();
  const trueRo = await grid.getAvCurrentPrice().then((res) => console.log(res));

  // console.log(grid.getAvCurrentPrice());
  const nvinre = await usdcContract
    .connect(account3)
    .approve(router.address, ethers.utils.parseUnits("10500", 6));
  const txn9 = await router.connect(account3).placeOrder(150, false, 70, false);
  txn9.wait();
  const trueR = await grid.getAvCurrentPrice().then((res) => console.log(res));
  const nvinree = await usdcContract
    .connect(account3)
    .approve(router.address, ethers.utils.parseUnits("3000", 6));
  const txn9e = await router.connect(account3).placeOrder(50, false, 60, true);
  txn9.wait();
  const tru = await grid.getAvCurrentPrice().then((res) => console.log(res));

  console.log("aaaaannnnneeeee WAAALALALAL AHAIOAIAIAIIAA");

  const uvikv = await grid
    .getOrdersForAddress("0x70997970C51812dc3A010C7d01b50e0d17dc79C8")
    .then((res) => console.log(res));

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
