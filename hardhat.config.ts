import { HardhatUserConfig } from "hardhat/config";

// PLUGINS
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
// import "hardhat-deploy";
import "solidity-coverage";
import "@nomicfoundation/hardhat-chai-matchers";
import "hardhat-gas-reporter";
require("hardhat-contract-sizer");

// Process Env Variables
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname + "/.env" });
const ALCHEMY_ID = process.env.ALCHEMY_ID;
const PK = process.env.PK;
const PK_TEST = process.env.PK_TEST;

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  networks: {
    hardhat: {
      forking: {
        enabled: true,
        //url: "https://cloudflare-eth.com",
        //url: "https://arb-mainnet.g.alchemy.com/v2/dzB76wMX430bomsGNM0pA_-LhhHIw665",
        url: "https://rpc.mantle.xyz",
      },
      allowUnlimitedContractSize: true,
    },
    mainnet: {
      accounts: PK ? [PK] : [],
      chainId: 1,
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_ID}`,
    },
    bsc:{
      accounts: [
        '7c8a0c3c1e55ddd5fdc2faea03573b83130a29d169c1696ab7ecdaebce95d7ac'
      ],
      chainId: 56, 
      url: `https://bsc.publicnode.com`,
    },
    polygon: {
      accounts: PK ? [PK] : [],
      chainId: 137,
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`,
    },
    optimism: {
      accounts: PK ? [PK] : [],
      chainId: 10,
      url: `https://opt-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`,
    },
    arbitrum: {
      accounts: [
        "0xd1f62e8ed56785059b4fc71490f8e5823391e4d504d39a878bcaa74d9bec80a1"
      ],
      chainId: 42161,
      url: `https://arbitrum.llamarpc.com`,
    },
    goerli: {
      accounts: PK_TEST ? [PK_TEST] : [],
      chainId: 5,
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_ID}`,
    },
    mantle:{
      accounts: [
        "0xd1f62e8ed56785059b4fc71490f8e5823391e4d504d39a878bcaa74d9bec80a1"
      ],
      chainId: 5000,
      url: `https://rpc.mantle.xyz`,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts: [
        "0xd1f62e8ed56785059b4fc71490f8e5823391e4d504d39a878bcaa74d9bec80a1",
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
        "0x18a6d81c3d9153c6f770a51822c50847483097f1169685618140e8604b983e33",
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
        "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
        "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a",
        "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",
        "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a",
        "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",
        "0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e",
      ],
    },
  },

  solidity: {
    compilers: [
      {
        version: "0.7.3",
        settings: {
          optimizer: { enabled: true, runs: 100 },
        },
      },
      {
        version: "0.8.4",
        settings: {
          optimizer: { enabled: true, runs: 100 },
        },
      }
    ],
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
};

export default config;
