require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      forking: {
        url: "https://arb-mainnet.g.alchemy.com/v2/jVB6yPEql3cT5SNZ13FsZRDy5plSmMfQ",
        blockNumber: 61217000,
      },
    },
    localhost: {
      allowUnlimitedContractSize: true,
      url: "http://127.0.0.1:8545/",
    },
  },
  solidity: {
    compilers: [
      { version: "0.8.0", settings: {} },
      { version: "0.6.0", settings: {} },
    ],
  },
};
