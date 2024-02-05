// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/*
 * ERC-20 Token Smart Contract by Ansh Bahl
 */

contract ERC20 {
    string public tokenName;
    string public symbol;
    uint256 public totalSupply;

    constructor(string memory _tokenName, string memory _symbol, uint256 _totalSupply) {
        tokenName = _tokenName;
        symbol = _symbol;
        totalSupply = _totalSupply;
        storeBalance[msg.sender] = _totalSupply;
    }

    mapping(address => uint256) public storeBalance;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address _reciever,uint256 amount);
    event Approve(address _spender,uint256 amount);
    event TransferFrom(address from,address to,uint256 amount);

    function checkBalance() public view returns (uint256) {
        return storeBalance[msg.sender];
    }

    function transfer(address _receiver, uint256 _amount) public {
        require(storeBalance[msg.sender] >= _amount, "Insufficient balance");
        require(_receiver != address(0), "Invalid receiver address");

        storeBalance[msg.sender] -= _amount;
        storeBalance[_receiver] += _amount;

        emit Transfer(msg.sender,_amount);
    }

    function approve(address _spender, uint256 _amount) public {
        allowances[msg.sender][_spender] = _amount;
        emit Approve(_spender,_amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public {
        require(storeBalance[_from] >= _amount, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _amount, "Allowance exceeded");
        require(_to != address(0), "Invalid receiver address");

        storeBalance[_from] -= _amount;
        storeBalance[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;
        emit TransferFrom(_from,_to,_amount);
    }
}
