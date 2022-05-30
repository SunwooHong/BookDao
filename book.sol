// SPDX-License-Identifier: SNU
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

struct candidate{
    string title;
    string author;
	uint book_token;    //xbooktoken 수
}

contract BookToken is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private xbookToken; //스테이킹 양, 투표할 때 쓰임
    mapping(uint => candidate) public candidates;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint public _num_candidates;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

	function staking(address addr, uint256 amount) public{ //북토큰을 x북토큰으로
		_balances[addr]-=amount;
        xbookToken[addr]+=amount;
	}

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BookToken: transfer from the zero address");
        require(to != address(0), "BookToken: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BookToken: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BookToken: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    ////////////////
    function register (uint id, string memory _title, string memory _author) public{    //투표 후보 등록(작가와 책 제목)
        candidates[id]=candidate(_title, _author, 0);
        _num_candidates+=1;
    }

	function total_candidates() public view returns(uint){	//전체 후보 개수 가져오기
	    return _num_candidates;
	}

	function author(uint id) public view returns(string memory) {	//일단 작가랑 첵제목만, $BOOK은 나중에 추가할 것
		string memory _author=candidates[id].author;	//이거 동작하는지 확인해봐야함
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

	function voting(uint id, uint _book_token) public{	//voting 함수가 여기 있는게 맞나, 주의사항($book토큰 개수 처리를 어떻게 해야할지 헷갈림)
		candidates[id].book_token+=_book_token;
	}
	////////////////////
    //세팅하기
    function init(address account, uint _book_token) public{
        _balances[account]+=_book_token;
    }

}
/*
contract BookVoting{
    mapping(uint => cadidate) public candidates;

    function register(uint id, string memory title, string memory author){    //투표 후보 등록(작가와 책 제목)
        candidates[id]=candidate(title, author, 0);
    }

	function total_candidates(){	//전체 후보 개수 가져오기
		uint len=candidates.length;
		return len;
	}

	function author(uint id){	//일단 작가랑 첵제목만, $BOOK은 나중에 추가할 것
		string _author=candidates[id].author;	//이거 동작하는지 확인해봐야함
		return _author;
	}

	function title(uint id){
		string _title=candidates[id].title;
		return _title;
	}

	function book_token(uint id){
		uint _book_token=candidates[id].book_token;
		return _book_token;
	}

	function voting(uint id, uint book_token){	//voting 함수가 여기 있는게 맞나, 주의사항($book토큰 개수 처리를 어떻게 해야할지 헷갈림)
		candidates[id].book+=book_token;
	}
	//주소 지정

	
}
*/


// 권한이 가진 사람만 호출할 수 있도록
// OpenZepplin Owner
/*
	contract DAO_Treasury, Community Fund {
	// Owner 상속 받아서 검증된 사람만 할 수 있도록
	func Send(receiver) {
		Token_Contract.Send(self,receiver) 
	}
}
*/