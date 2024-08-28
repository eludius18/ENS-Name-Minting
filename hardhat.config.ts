require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: `https://eth-mainnet.g.alchemy.com/v2/hBRZG8vSut80Su2-nlB2s4k8rPecABqT`,
      },
    },
  },
};
