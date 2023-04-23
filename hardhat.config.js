require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.0", settings: {} },
      { version: "0.6.0", settings: {} },
    ],
  },
};
