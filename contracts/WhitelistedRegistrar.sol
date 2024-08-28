// SPDX-License-Identifier: MIT
pragma solidity ~0.8.17;

import "@ensdomains/ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";

contract WhitelistedRegistrar {
    ETHRegistrarController public ethRegistrarController;

    mapping(address => bool) public whitelist;
    bool public whitelistDisabled = false;
    uint256 public phase = 0;

    event PhaseChanged(uint256 newPhase);
    event WhitelistDisabled();
    event AddressWhitelisted(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);

    /**
     * @dev Constructor to initialize the contract with the ETHRegistrarController.
     * @param _ethRegistrarController The address of the ETHRegistrarController contract.
     */
    constructor(
        ETHRegistrarController _ethRegistrarController
    ) {
        ethRegistrarController = _ethRegistrarController;
    }

    /**
     * @dev Modifier to restrict access to only the owner.
     */
    modifier onlyOwner() {
        // Implement ownership logic here
        _;
    }

    /**
     * @dev Modifier to restrict access to only whitelisted addresses or if whitelist is disabled.
     */
    modifier onlyWhitelisted() {
        require(whitelistDisabled || whitelist[msg.sender], "Not whitelisted");
        _;
    }

    /**
     * @dev Adds an address to the whitelist.
     * @param account The address to be added to the whitelist.
     */    
    function addAddressToWhitelist(address account) external onlyOwner {
        whitelist[account] = true;
        emit AddressWhitelisted(account);
    }

    /**
     * @dev Removes an address from the whitelist.
     * @param account The address to be removed from the whitelist.
     */
    function removeAddressFromWhitelist(address account) external onlyOwner {
        whitelist[account] = false;
        emit AddressRemovedFromWhitelist(account);
    }

    /**
     * @dev Disables the whitelist, allowing all addresses to interact.
     */
    function disableWhitelist() external onlyOwner {
        whitelistDisabled = true;
        emit WhitelistDisabled();
    }

    /**
     * @dev Sets the current phase of the contract.
     * @param newPhase The new phase to be set.
     */
    function setPhase(uint256 newPhase) external onlyOwner {
        require(newPhase > phase, "Cannot revert to previous phase");
        phase = newPhase;
        emit PhaseChanged(newPhase);
    }

    /**
     * @dev Checks if an address can mint.
     * @param account The address to be checked.
     * @return True if the address can mint, false otherwise.
     */
    function canMint(address account) external view returns (bool) {
        if (whitelistDisabled) {
            return true;
        }
        return whitelist[account];
    }

    /**
     * @dev Registers a new ENS name.
     * @param name The name to be registered.
     * @param owner The address of the new owner of the name.
     * @param duration The duration for which the name is registered.
     * @param secret The secret used for the registration.
     * @param resolver The resolver address for the name.
     * @param data Additional data for the resolver.
     * @param reverseRecord Whether to set a reverse record.
     * @param ownerControlledFuses The fuses controlled by the owner.
     */
    function register(
        string calldata name,
        address owner,
        uint256 duration,
        bytes32 secret,
        address resolver,
        bytes[] calldata data,
        bool reverseRecord,
        uint16 ownerControlledFuses
    ) public payable onlyWhitelisted {
        ethRegistrarController.register{value: msg.value}(
            name,
            owner,
            duration,
            secret,
            resolver,
            data,
            reverseRecord,
            ownerControlledFuses
        );
    }
}
