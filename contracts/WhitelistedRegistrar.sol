// SPDX-License-Identifier: MIT
pragma solidity ~0.8.17;

import "@ensdomains/ens-contracts/contracts/ethregistrar/ETHRegistrarController.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WhitelistedRegistrar is Ownable, ReentrancyGuard {
    ETHRegistrarController public ethRegistrarController;

    mapping(address => bool) public whitelist;
    bool public whitelistDisabled = false;
    uint256 public phase = 0;

    mapping(uint256 => uint256) public phaseLimits;
    uint256 public whitelistedCount = 0;

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
        phaseLimits[0] = 50; 
        phaseLimits[1] = 100;
        phaseLimits[2] = 200;
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
        require(!whitelist[account], "Already whitelisted");
        require(canAddToWhitelist(), "Whitelist limit reached for current phase");

        whitelist[account] = true;
        whitelistedCount++;
        emit AddressWhitelisted(account);
    }

    /**
     * @dev Removes an address from the whitelist.
     * @param account The address to be removed from the whitelist.
     */
    function removeAddressFromWhitelist(address account) external onlyOwner {
        require(whitelist[account], "Not in whitelist");

        delete whitelist[account];
        whitelistedCount--;
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
     * @dev Checks if more addresses can be added to the whitelist based on the current phase.
     * @return True if more addresses can be added, false otherwise.
     */
    function canAddToWhitelist() public view returns (bool) {
        if (whitelistDisabled) {
            return true;
        }
        uint256 limit = phaseLimits[phase];
        return whitelistedCount < limit;
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
    ) public payable onlyWhitelisted nonReentrant {
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