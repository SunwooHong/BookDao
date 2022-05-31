// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./IERC20.sol";
//import "./IERC20Metadata.sol";
//import "./Context.sol";

struct candidate{
    string title;
    string author;
	uint book_token;    //xbooktoken
}

contract BookToken {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private xbookToken;
    mapping(uint => candidate) public candidates;
    mapping(address => uint256) private voting_num;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint public _num_candidates=0;
    uint256 private _totalSupply=200000000;

    string private _name;
    string private _symbol;

	function staking(address addr, uint256 amount) public{ //북토큰을 x북토큰으로
		_balances[addr]-=amount;
        xbookToken[addr]+=amount;
	}

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 2;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function xbookTokenOf(address account) public view virtual returns (uint256) {
        return xbookToken[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    ////////////////
    function register (uint id, string memory _title, string memory _author) public{ 
        candidates[id]=candidate(_title, _author, 0);
        _num_candidates+=1;
    }

	function total_candidates() public view returns(uint){
	    return _num_candidates;
	}

	function author(uint id) public view returns(string memory) {	
		string memory _author=candidates[id].author;
		return _author;
	}

	function title(uint id) public view returns(string memory) {
		string memory _title=candidates[id].title;
		return _title;
	}

	function book_token(uint id) public view returns(uint){
		uint _book_token=candidates[id].book_token;
		return _book_token;
	}

	function voting(address account, uint id, uint _book_token) public{
		voting_num[account]+=1;
        candidates[id].book_token+=_book_token*(voting_num[account]**2);
        xbookToken[account]-=_book_token*(voting_num[account]**2);
	}
    //Setting
    function init(address account, uint _book_token) public{
        _balances[account]+=_book_token;
    }

}
