# ENS Name Minting and Whitelisted Registrar Contracts

This repository contains two smart contracts designed for blockchain applications: `ENSMinting` and `WhitelistedRegistrar`. The `ENSMinting` contract manages the minting and resolution of names within a decentralized namespace, while the `WhitelistedRegistrar` contract controls the registration of names, allowing only specific users to register names based on a whitelist.

## Contract Overview

### 1. ENSMinting

The `ENSMinting` contract is responsible for minting names within a decentralized naming system. It interacts with the Name Registry, Public Resolver, and Reverse Registrar to ensure that names are properly registered, forward resolved, and reverse resolved.

**Key Functions**:
- `mintENSName(bytes32 node, string calldata name, address owner)`: Mints a new name in the decentralized namespace.
- `forwardResolve(address addr)`: Resolves a blockchain address to the associated name.
- `reverseResolve(string calldata name)`: Resolves a name to the associated blockchain address.

**Constructor Parameters**:
- `_ensRegistry`: Address of the Name Registry contract.
- `_publicResolver`: Address of the Public Resolver contract.
- `_reverseRegistrar`: Address of the Reverse Registrar contract.

### 2. WhitelistedRegistrar

The `WhitelistedRegistrar` contract extends the functionality of a traditional registrar by introducing a whitelisting mechanism. This contract restricts name registration to a specific set of addresses, allowing phased registration to control who can register names at different stages.

**Key Features**:
- **Phased Whitelisting**: Controls who can mint names during different phases of registration.
- **Whitelist Management**: Admins have the ability to add or remove addresses from the whitelist.
- **Disabling Whitelist**: Admins can disable the whitelist entirely, allowing all addresses to mint names.

**Constructor Parameters**:
- `_base`: Address of the Base Registrar Implementation contract.
- `_prices`: Address of the Price Oracle contract.
- `_minCommitmentAge`: Minimum age of a commitment.
- `_maxCommitmentAge`: Maximum age of a commitment.
- `_reverseRegistrar`: Address of the Reverse Registrar contract.
- `_nameWrapper`: Address of the Name Wrapper contract.
- `_ens`: Address of the Name Registry contract.

**Key Functions**:
- `addAddressToWhitelist(address account)`: Adds an address to the whitelist, allowing it to register names.
- `removeAddressFromWhitelist(address account)`: Removes an address from the whitelist, preventing it from registering names.
- `disableWhitelist()`: Disables the whitelist, allowing all addresses to register names.
- `canMint(address account)`: Checks if a given address is allowed to mint a name.

## Deployment

### Prerequisites

1. **Node.js and npm**: Ensure that Node.js and npm are installed on your machine.
2. **Hardhat**: Install Hardhat by running `npm install --save-dev hardhat`.
3. **Alchemy Account**: Obtain an Alchemy API key to fork the Ethereum mainnet.

## Setting Up Environment Variables

Create a `.env` file in the root directory of your project. This file will store the addresses required for deploying the contracts.

**Example `.env` file:**

```plaintext
ENS_REGISTRY_ADDRESS=your_actual_ENSRegistry_address  
PUBLIC_RESOLVER_ADDRESS=your_actual_PublicResolver_address  
REVERSE_REGISTRAR_ADDRESS=your_actual_ReverseRegistrar_address  
ETH_REGISTRAR_CONTROLLER_ADDRESS=your_actual_ETHRegistrarController_address
```

Make sure to replace the placeholders (`your_actual_*`) with the actual contract addresses you are using.

## Environment Setup Commands

1. **Create the `.env` file from the example file:**

   If you have an example environment file (`.env.example`), you can quickly create your `.env` file by running:

   ```bash
   cp .env.example .env
   ```

2. **Update the `.env` file with your actual contract addresses:**

   Open the `.env` file and replace the placeholder values with the actual addresses of the contracts you're working with.

## Forking Ethereum Mainnet

Before deploying the contracts, you need to fork the Ethereum mainnet. Forking the mainnet allows you to interact with real-world data and existing contracts, providing a more accurate deployment environment.

1. **Start a Hardhat node with a forked Ethereum mainnet:**

   Use the following command to start a Hardhat node that forks from the Ethereum mainnet:

   ```bash
   npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY
   ```

   Replace `YOUR_ALCHEMY_API_KEY` with your actual Alchemy API key. This command will start a local Ethereum node that simulates the state of the mainnet, allowing you to deploy and test your contracts as if you were on the mainnet.

## Deploying the Contracts

Once your Hardhat node is running with the forked mainnet, you can deploy the contracts using the following commands.

### Deploying ENSMinting Contract

1. **Run the deployment script for `ENSMinting`:**

   ```bash
   npx hardhat run scripts/01_deploy_ENSMinting.ts --network localhost
   ```

   This script will deploy the `ENSMinting` contract to your locally forked mainnet.

### Deploying WhitelistedRegistrar Contract

1. **Run the deployment script for `WhitelistedRegistrar`:**

   ```bash
   npx hardhat run scripts/02_deploy_WhitelistedRegistrar.ts --network localhost
   ```

   This script will deploy the `WhitelistedRegistrar` contract to your locally forked mainnet.

## Running Tests (Not Implemented yet)

After deploying the contracts, you can run the tests to ensure everything is working as expected.

1. **Run the tests:**

   ```bash
   npx hardhat test --network localhost
   ```

   This command will execute the test suite against the deployed contracts on your locally forked mainnet.

## Note

- The command `npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY` is used to start a Hardhat node with a forked Ethereum mainnet. Ensure you replace `YOUR_ALCHEMY_API_KEY` with your actual Alchemy API key.
- The `.env` file should never be committed to version control as it contains sensitive information like contract addresses and API keys.
- For more details on ENS deployments, refer to the [ENS documentation](https://docs.ens.domains/learn/deployments).
