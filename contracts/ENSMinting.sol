// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistryWithFallback.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/PublicResolver.sol";
import "@ensdomains/ens-contracts/contracts/reverseRegistrar/ReverseRegistrar.sol" as ENSReverseRegistrar;

contract ENSMinting {
    ENS private ensRegistry;
    PublicResolver private publicResolver;
    ENSReverseRegistrar.ReverseRegistrar private reverseRegistrar;

    constructor(address _ensRegistry, address _publicResolver, address _reverseRegistrar) {
        ensRegistry = ENS(_ensRegistry);
        publicResolver = PublicResolver(_publicResolver);
        reverseRegistrar = ENSReverseRegistrar.ReverseRegistrar(_reverseRegistrar);
    }

    function mintENSName(bytes32 node, string calldata name, address owner) external {
        ensRegistry.setSubnodeOwner(bytes32(0), node, owner);
        ensRegistry.setResolver(node, address(publicResolver));
        publicResolver.setAddr(node, owner);
        publicResolver.setName(node, name);
        
        // Set up reverse record for reverse resolution
        reverseRegistrar.setName(name);
    }

    function forwardResolve(address addr) external view returns (string memory) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(reverseRegistrar.node(addr)))));
        return publicResolver.name(node);
    }

    function reverseResolve(string calldata name) external view returns (address) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(name))));
        return publicResolver.addr(node);
    }
}
