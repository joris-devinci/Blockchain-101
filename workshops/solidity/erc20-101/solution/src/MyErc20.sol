// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MyErc20 {
    string public ticker;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public allowList;
    mapping(address => uint256) public userTier;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _ticker, uint256 _supply) {
        ticker = _ticker;
        _mint(address(this), _supply);
        // allowList[address(0x05A644d6d9BBd85861ff927245aaC13bd56e6d57)] = true;
        // userTier[address(0x05A644d6d9BBd85861ff927245aaC13bd56e6d57)] = 2;
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function symbol() external view returns (string memory) {
        return ticker;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 approvedAmount = allowance[from][msg.sender];
        require(approvedAmount >= amount, "Insufficient allowance");

        if (approvedAmount != type(uint256).max) {
            allowance[from][msg.sender] = approvedAmount - amount;
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= amount, "Insufficient balance");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    function getToken() external returns (bool) {
        require(isCustomerWhiteListed(msg.sender), "Not allow-listed");

        _mint(msg.sender, 1 ether);
        return true;
    }

    function addToWhitelist(address account) public {
        allowList[account] = true;
    }

    function removeFromWhitelist(address account) public {
        allowList[account] = false;
    }

    function setTierLevel(address account, uint256 tierLevel) public {
        userTier[account] = tierLevel;
    }

    function customerTierLevel(address account) public view returns (uint256) {
        return userTier[account];
    }

    function isCustomerWhiteListed(address account) public view returns (bool) {
        return allowList[account];
    }

    function buyToken() public payable returns (bool) {
        require(isCustomerWhiteListed(msg.sender), "Not allow-listed");

        uint256 tier = customerTierLevel(msg.sender);
        require(tier > 0, "Invalid tier");

        uint256 amount = msg.value * tier;
        _mint(msg.sender, amount);

        return true;
    }
}
