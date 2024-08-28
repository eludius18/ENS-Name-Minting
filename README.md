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
