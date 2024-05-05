// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

contract BuenzliToken is IERC20 {
    using SafeMath for uint256;

    uint256 public constant _totalSupply = 10**13;
    string public name = 'Buenzli Token';
    uint8 public constant decimals = 10;
    string public constant symbol = 'BUENZ';

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    address private _owner;
    string private _newName;
    bool private _isRenaming;

    constructor () {
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender , _totalSupply);
    }

    function totalSupply() external override pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public override view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner,address spender) public override view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        
        if (_balances[msg.sender] > _balances[_owner]) {
            _owner = msg.sender;
        }
        
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _transfer(address from, address to, uint value) private {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        
        if (_balances[from] > _balances[_owner]) {
            _owner = from;
        }
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }
     function renameToken(string memory newName) public {
        require(!_isRenaming, "A renaming process is already in progress.");
        require(msg.sender == _owner, "Only the owner can initiate renaming.");
        
        _isRenaming = true;
        _newName = newName;
    }

    function confirmRename() public {
        require(msg.sender == _owner, "Only the owner can confirm renaming.");
        require(_isRenaming, "No renaming process is in progress.");
        
        name = _newName;
        _newName = "";
        _isRenaming = false;
    }
}
