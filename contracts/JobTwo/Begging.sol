// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title Begging - 募捐合约
 * @dev 允许用户捐赠ETH，仅合约所有者可提取资金
 * @notice 此合约用于接受以太坊捐赠，并记录每个捐赠者的捐赠金额
 */
contract Begging {
    /// @dev 合约所有者地址
    address public owner;

    /// @dev 捐赠者地址到捐赠总额的映射
    mapping(address => uint256) public bids;

    /**
     * @dev 构造函数，设置合约部署者为所有者
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev 仅所有者修饰器
     * @notice 限制只有合约所有者才能调用特定函数
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev 捐赠事件
     * @param from 捐赠者地址
     * @param amount 捐赠金额
     */
    event Bid(address indexed from, uint256 amount);

    /**
     * @dev 捐赠函数
     * @notice 接受用户捐赠并记录捐赠金额
     * @return 总是返回true表示操作成功
     * @custom:requirement 捐赠金额必须大于0
     */
    function donate() external payable returns (bool) {
        require(msg.value > 0, "Amount must be greater than 0");

        // 累加捐赠者的捐赠总额
        bids[msg.sender] += msg.value;

        // 触发捐赠事件
        emit Bid(msg.sender, msg.value);
        return true;
    }

    /**
     * @dev 提取合约资金
     * @notice 仅合约所有者可以调用，提取合约中的所有ETH
     * @return 总是返回true表示操作成功
     * @custom:permission 仅合约所有者
     */
    function withdraw() external onlyOwner returns (bool) {
        payable(msg.sender).transfer(address(this).balance);
        return true;
    }

    /**
     * @dev 查询捐赠金额
     * @notice 查询指定地址的累计捐赠金额
     * @param bidder 要查询的捐赠者地址
     * @return 该地址的累计捐赠金额
     */
    function getDonation(address bidder) external view returns (uint256) {
        return bids[bidder];
    }

    /**
     * @dev 接收ETH的回退函数
     * @notice 禁止直接向合约转账，必须通过donate()函数捐赠
     * @custom:revert 总是回退并提示使用donate()函数
     */
    receive() external payable {
        revert("Please use donate() function");
    }
}
