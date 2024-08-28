// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistryWithFallback.sol";
import "@ensdomains/ens-contracts/contracts/resolvers/PublicResolver.sol";
import "@ensdomains/ens-contracts/contracts/reverseRegistrar/ReverseRegistrar.sol" as ENSReverseRegistrar;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ENSMinting is Ownable, ReentrancyGuard {
    ENS private ensRegistry;
    PublicResolver private publicResolver;
    ENSReverseRegistrar.ReverseRegistrar private reverseRegistrar;

    /**
     * @dev Constructor to initialize the ENSMinting contract.
     * @param _ensRegistry The address of the ENS registry contract.
     * @param _publicResolver The address of the public resolver contract.
     * @param _reverseRegistrar The address of the reverse registrar contract.
     */
    constructor(address _ensRegistry, address _publicResolver, address _reverseRegistrar) {
        ensRegistry = ENS(_ensRegistry);
        publicResolver = PublicResolver(_publicResolver);
        reverseRegistrar = ENSReverseRegistrar.ReverseRegistrar(_reverseRegistrar);
    }

    event ENSNameMinted(bytes32 indexed node, string name, address indexed owner);

    /**
     * @dev Mints a new ENS name.
     * @param node The node representing the ENS name.
     * @param name The ENS name to be minted.
     * @param owner The address of the new owner of the ENS name.
     */
    function mintENSName(bytes32 node, string calldata name, address owner) external nonReentrant {
        require(ensRegistry.owner(node) == address(0), "Name already minted");
        
        ensRegistry.setSubnodeOwner(bytes32(0), node, owner);
        ensRegistry.setResolver(node, address(publicResolver));
        publicResolver.setAddr(node, owner);
        publicResolver.setName(node, name);
        
        // Set up reverse record for reverse resolution
        reverseRegistrar.setName(name);
        emit ENSNameMinted(node, name, owner);
    }

    /**
     * @dev Resolves an address to its ENS name.
     * @param addr The address to be resolved.
     * @return The ENS name associated with the address.
     */
    function forwardResolve(address addr) external view returns (string memory) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(reverseRegistrar.node(addr)))));
        return publicResolver.name(node);
    }

    /**
     * @dev Resolves an ENS name to its associated address.
     * @param name The ENS name to be resolved.
     * @return The address associated with the ENS name.
     */
    function reverseResolve(string calldata name) external view returns (address) {
        bytes32 node = keccak256(abi.encodePacked(bytes32(0), keccak256(abi.encodePacked(name))));
        return publicResolver.addr(node);
    }
}
