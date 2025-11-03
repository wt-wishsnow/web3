// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title SimpleERC20
 * @dev 简易ERC20代币合约，支持代币增发
 */

contract SimpleERC20 {
    /// @title SimpleERC20 Token Contract
    /// @author wishsnow

    /// @notice 代币名称
    string public name;
    /// @notice 代币符号
    string public symbol;
    /// @notice 小数位数
    uint8 public decimals;
    /// @notice 总供应量
    uint256 public totalSupply;

    /// @notice 合约所有者地址
    address public owner;

    /// @dev 账户余额存储映射
    mapping(address => uint256) private _balances;

    /// @dev 授权额度存储映射
    mapping(address => mapping(address => uint256)) private _allowances;

    /// @notice 当代币转账时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice 当代币授权时触发
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    /// @notice 当代币增发时触发
    event Mint(address indexed to, uint256 value);

    /// @dev 限制只有合约所有者可调用的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev 代币合约初始化
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 精度位数
     * @param _initialSupply 初始发行量
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        // 初始代币分配给部署者
        _mint(msg.sender, _initialSupply * (10 ** decimals));
    }

    /**
     * @dev 查询账户余额
     * @param account 查询地址
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 代币转账
     * @param to 接收地址
     * @param value 转账数量
     */
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev 授权额度
     * @param spender 被授权地址
     * @param value 授权数量
     */
    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev 查询授权额度
     * @param _owner 授权方
     * @param _spender 被授权方
     */
    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    /**
     * @dev 授权转账（第三方操作）
     * @param from 付款地址
     * @param to 收款地址
     * @param value 转账数量
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(
            currentAllowance >= value,
            "ERC20: transfer amount exceeds allowance"
        );

        unchecked {
            _approve(from, msg.sender, currentAllowance - value);
        }

        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev 增发代币（仅管理员）
     * @param to 接收地址
     * @param value 增发数量
     */
    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }

    /**
     * @dev 内部转账逻辑
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[from] >= value,
            "ERC20: transfer amount exceeds balance"
        );

        unchecked {
            _balances[from] -= value;
            _balances[to] += value;
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev 内部授权逻辑
     */
    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    /**
     * @dev 内部增发逻辑
     */
    function _mint(address to, uint256 value) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        totalSupply += value;
        unchecked {
            _balances[to] += value;
        }

        emit Transfer(address(0), to, value);
        emit Mint(to, value);
    }

    /**
     * @dev 转移管理员权限
     * @param newOwner 新管理员地址
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}
