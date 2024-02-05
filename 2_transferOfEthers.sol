// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract TransferEther {

    modifier nonReentrant() {
        require(!reentrantGuard, "Reentrant call detected");
        reentrantGuard = true;
        _;
        reentrantGuard = false;
    }

    bool private reentrantGuard = false;

    function sendEthers(uint256 amount, address payable to) public payable nonReentrant {
        require(amount > 0, "Send some amount");
        require(to != address(0), "Address should not be 0");
        require(amount <= msg.sender.balance, "Insufficient balance");

        to.transfer(amount);
    }
}
