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

    constructor(
        ETHRegistrarController _ethRegistrarController
    ) {
        ethRegistrarController = _ethRegistrarController;
    }

    modifier onlyOwner() {
        // Implement ownership logic here
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelistDisabled || whitelist[msg.sender], "Not whitelisted");
        _;
    }

    function addAddressToWhitelist(address account) external onlyOwner {
        whitelist[account] = true;
        emit AddressWhitelisted(account);
    }

    function removeAddressFromWhitelist(address account) external onlyOwner {
        whitelist[account] = false;
        emit AddressRemovedFromWhitelist(account);
    }

    function disableWhitelist() external onlyOwner {
        whitelistDisabled = true;
        emit WhitelistDisabled();
    }

    function setPhase(uint256 newPhase) external onlyOwner {
        require(newPhase > phase, "Cannot revert to previous phase");
        phase = newPhase;
        emit PhaseChanged(newPhase);
    }

    function canMint(address account) external view returns (bool) {
        if (whitelistDisabled) {
            return true;
        }
        return whitelist[account];
    }

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
