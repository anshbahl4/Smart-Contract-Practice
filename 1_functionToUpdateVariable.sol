// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract UpdateVariable {
    address public owner;
    uint256 public variable = 5;
    uint256 public contractBalance;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier nonReentrant() {
        require(!reentrantGuard, "Reentrant call detected");
        reentrantGuard = true;
        _;
        reentrantGuard = false;
    }

    bool private reentrantGuard = false;

    event Trade(
        uint256 date,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Withdrawal(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function update(uint256 x, address to, uint256 amount) public onlyOwner {
        variable = x;
        emit Trade(block.timestamp, msg.sender, to, amount);
    }

    function toCheck() public view returns (uint256) {
        return variable;
    }

    function withdraw(uint256 amount) public onlyOwner nonReentrant {
        require(amount <= contractBalance, "Insufficient balance");
        contractBalance -= amount;
        payable(owner).transfer(amount);
        emit Withdrawal(owner, amount);
    }

    receive() external payable {
        contractBalance += msg.value;
    }
}
