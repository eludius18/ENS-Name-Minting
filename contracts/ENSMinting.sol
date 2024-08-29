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
        // Step 1: Ensure the ENS name has not already been minted
        // The function checks if the node (which represents the ENS name) already has an owner.
        // If the name has already been minted (i.e., if the owner is not address(0)), the transaction is reverted.
        require(ensRegistry.owner(node) == address(0), "Name already minted");

        // Step 2: Assign the ownership of the subnode to the specified owner
        // The ENS registry is updated to assign ownership of the 'node' (subdomain) to the specified 'owner'.
        // The 'bytes32(0)' represents the root node, meaning the new node is a direct subdomain.
        ensRegistry.setSubnodeOwner(bytes32(0), node, owner);

        // Step 3: Set the resolver for the node
        // The ENS registry is updated to set the resolver for the node. The resolver is the smart contract
        // responsible for resolving the node (i.e., mapping it to an address or other resources).
        ensRegistry.setResolver(node, address(publicResolver));

        // Step 4: Set the address that the node should resolve to
        // The public resolver is instructed to map the node to the owner's address. This means that when someone
        // queries the ENS system for this node, they will receive the owner's address in return.
        publicResolver.setAddr(node, owner);

        // Step 5: Set the reverse resolution record
        // The public resolver is instructed to map the owner's address back to the ENS name, enabling reverse
        // resolution (resolving an address back to a name).
        publicResolver.setName(node, name);
        
        // Step 6: Set up the reverse record in the Reverse Registrar
        // The reverse registrar is used to set up a reverse resolution record, ensuring that the owner's address
        // can be resolved back to the ENS name.
        reverseRegistrar.setName(name);        reverseRegistrar.setName(name);

        // Step 7: Emit an event indicating that the ENS name has been minted
        // An event is emitted to log that the ENS name has been successfully minted. The event records the node,
        // the name, and the owner's address.
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
