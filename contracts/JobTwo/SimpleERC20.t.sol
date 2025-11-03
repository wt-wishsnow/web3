// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "./SimpleERC20.sol";

/**
 * @title SimpleERC20测试合约
 * @dev 使用Hardhat + Forge Std对SimpleERC20代币进行测试
 */
contract SimpleERC20Test is Test {
    SimpleERC20 public token;

    /// @dev 测试账户地址
    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public spender = makeAddr("spender");

    /// @dev  代币常量
    uint256 constant INITIAL_SUPPLY = 1000000;
    uint8 constant DECIMALS = 18;
    string constant NAME = "Test Token";
    string constant SYMBOL = "TEST";

    /// @dev  重新声明事件以便在测试中使用
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(address indexed to, uint256 value);

    /**
     * @dev 每个测试前运行的设置函数
     */
    function setUp() public {
        // 使用owner地址部署合约
        vm.startPrank(owner);
        token = new SimpleERC20(NAME, SYMBOL, DECIMALS, INITIAL_SUPPLY);
        vm.stopPrank();
    }

    // =============================================
    // 构造函数测试
    // =============================================

    /**
     * @dev 测试构造函数初始化
     */
    function test_ConstructorInitialization() public view {
        // 验证代币基本信息
        assertEq(token.name(), NAME, "Token name should match");
        assertEq(token.symbol(), SYMBOL, "Token symbol should match");
        assertEq(token.decimals(), DECIMALS, "Decimals should match");

        // 验证供应量和所有权
        assertEq(
            token.totalSupply(),
            INITIAL_SUPPLY * (10 ** DECIMALS),
            "Total supply should be correct"
        );
        assertEq(token.owner(), owner, "Contract owner should be correct");
        assertEq(
            token.balanceOf(owner),
            INITIAL_SUPPLY * (10 ** DECIMALS),
            "Initial tokens should be allocated to deployer"
        );
    }

    // =============================================
    // 转账功能测试
    // =============================================

    /**
     * @dev 测试用户间正常转账
     */
    function test_Transfer() public {
        uint256 transferAmount = 1000 * (10 ** DECIMALS);

        // 执行转账
        vm.prank(owner);
        token.transfer(user1, transferAmount);

        // 验证余额变化
        assertEq(
            token.balanceOf(owner),
            (INITIAL_SUPPLY - 1000) * (10 ** DECIMALS),
            "Sender balance should decrease"
        );
        assertEq(
            token.balanceOf(user1),
            transferAmount,
            "Receiver balance should increase"
        );
    }

    /**
     * @dev 测试转账事件触发
     */
    function test_TransferEvent() public {
        uint256 transferAmount = 500 * (10 ** DECIMALS);

        // 期望Transfer事件
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, transferAmount);

        // 执行转账
        vm.prank(owner);
        token.transfer(user1, transferAmount);
    }

    /**
     * @dev 测试余额不足的转账
     */
    function test_TransferInsufficientBalance() public {
        uint256 excessiveAmount = (INITIAL_SUPPLY + 1000) * (10 ** DECIMALS);

        // 期望交易回滚
        vm.prank(owner);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(user1, excessiveAmount);
    }

    /**
     * @dev 测试向零地址转账
     */
    function test_TransferToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), 1000);
    }

    // =============================================
    // 授权功能测试
    // =============================================

    /**
     * @dev 测试授权功能
     */
    function test_Approve() public {
        uint256 approveAmount = 5000 * (10 ** DECIMALS);

        // 执行授权
        vm.prank(owner);
        token.approve(spender, approveAmount);

        // 验证授权额度
        assertEq(
            token.allowance(owner, spender),
            approveAmount,
            "Allowance should be set correctly"
        );
    }

    /**
     * @dev 测试授权事件触发
     */
    function test_ApproveEvent() public {
        uint256 approveAmount = 3000 * (10 ** DECIMALS);

        // 期望Approval事件
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, approveAmount);

        // 执行授权
        vm.prank(owner);
        token.approve(spender, approveAmount);
    }

    /**
     * @dev 测试transferFrom功能
     */
    function test_TransferFrom() public {
        uint256 approveAmount = 2000 * (10 ** DECIMALS);
        uint256 transferAmount = 1500 * (10 ** DECIMALS);

        // 步骤1: 授权
        vm.prank(owner);
        token.approve(spender, approveAmount);

        // 步骤2: 从授权中转账
        vm.prank(spender);
        token.transferFrom(owner, user1, transferAmount);

        // 验证结果
        assertEq(
            token.balanceOf(owner),
            (INITIAL_SUPPLY - 1500) * (10 ** DECIMALS),
            "Owner balance should decrease"
        );
        assertEq(
            token.balanceOf(user1),
            transferAmount,
            "Receiver balance should increase"
        );
        assertEq(
            token.allowance(owner, spender),
            approveAmount - transferAmount,
            "Allowance should decrease"
        );
    }

    /**
     * @dev 测试授权额度不足的transferFrom
     */
    function test_TransferFromInsufficientAllowance() public {
        uint256 approveAmount = 1000 * (10 ** DECIMALS);
        uint256 transferAmount = 1500 * (10 ** DECIMALS);

        // 设置授权
        vm.prank(owner);
        token.approve(spender, approveAmount);

        // 期望交易回滚
        vm.prank(spender);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(owner, user1, transferAmount);
    }

    // =============================================
    // 铸币功能测试
    // =============================================

    /**
     * @dev 测试所有者铸币功能
     */
    function test_Mint() public {
        uint256 mintAmount = 50000 * (10 ** DECIMALS);

        // 执行铸币
        vm.prank(owner);
        token.mint(user1, mintAmount);

        // 验证铸币结果
        assertEq(
            token.balanceOf(user1),
            mintAmount,
            "Receiver should receive minted tokens"
        );
        assertEq(
            token.totalSupply(),
            (INITIAL_SUPPLY + 50000) * (10 ** DECIMALS),
            "Total supply should increase"
        );
    }

    /**
     * @dev 测试铸币事件触发
     */
    function test_MintEvent() public {
        uint256 mintAmount = 10000 * (10 ** DECIMALS);

        // 期望Transfer事件（从零地址）
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, mintAmount);

        // 期望Mint事件
        vm.expectEmit(true, false, false, true);
        emit Mint(user1, mintAmount);

        // 执行铸币
        vm.prank(owner);
        token.mint(user1, mintAmount);
    }

    /**
     * @dev 测试非所有者铸币
     */
    function test_MintNotOwner() public {
        uint256 mintAmount = 1000 * (10 ** DECIMALS);

        // 期望交易回滚（权限拒绝）
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        token.mint(user1, mintAmount);
    }

    /**
     * @dev 测试向零地址铸币
     */
    function test_MintToZeroAddress() public {
        uint256 mintAmount = 1000 * (10 ** DECIMALS);

        vm.prank(owner);
        vm.expectRevert("ERC20: mint to the zero address");
        token.mint(address(0), mintAmount);
    }

    // =============================================
    // 所有权管理测试
    // =============================================

    /**
     * @dev 测试所有权转移
     */
    function test_TransferOwnership() public {
        vm.prank(owner);
        token.transferOwnership(user1);

        assertEq(
            token.owner(),
            user1,
            "New owner address should be set correctly"
        );
    }

    /**
     * @dev 测试非所有者进行所有权转移
     */
    function test_TransferOwnershipNotOwner() public {
        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        token.transferOwnership(user2);
    }

    /**
     * @dev 测试向零地址转移所有权
     */
    function test_TransferOwnershipToZero() public {
        vm.prank(owner);
        vm.expectRevert("New owner is the zero address");
        token.transferOwnership(address(0));
    }

    // =============================================
    // 集成测试
    // =============================================

    /**
     * @dev 测试完整的授权工作流程
     */
    function test_CompleteAllowanceFlow() public {
        uint256 initialBalance = token.balanceOf(owner);
        uint256 approveAmount = 5000 * (10 ** DECIMALS);
        uint256 transfer1 = 2000 * (10 ** DECIMALS);
        uint256 transfer2 = 1500 * (10 ** DECIMALS);

        // 步骤1: 授权
        vm.prank(owner);
        token.approve(spender, approveAmount);

        // 步骤2: 第一次transferFrom
        vm.prank(spender);
        token.transferFrom(owner, user1, transfer1);

        // 验证第一次转账后的状态
        assertEq(
            token.balanceOf(user1),
            transfer1,
            "First transfer receiver balance should be correct"
        );
        assertEq(
            token.allowance(owner, spender),
            approveAmount - transfer1,
            "Allowance should decrease after first transfer"
        );

        // 步骤3: 第二次transferFrom
        vm.prank(spender);
        token.transferFrom(owner, user2, transfer2);

        // 最终状态验证
        assertEq(
            token.balanceOf(user2),
            transfer2,
            "Second transfer receiver balance should be correct"
        );
        assertEq(
            token.balanceOf(owner),
            initialBalance - transfer1 - transfer2,
            "Final owner balance should be correct"
        );
        assertEq(
            token.allowance(owner, spender),
            approveAmount - transfer1 - transfer2,
            "Final allowance should be correct"
        );
    }

    /**
     * @dev 测试批量转账场景
     */
    function test_BatchTransfers() public {
        uint256 singleTransfer = 100 * (10 ** DECIMALS);
        uint256 batchCount = 5; // 减少数量以避免 gas 限制

        // 准备测试资金
        vm.prank(owner);
        token.transfer(user1, singleTransfer * batchCount);

        // 执行批量转账
        for (uint256 i = 0; i < batchCount; i++) {
            // 生成不同的接收者地址
            address recipient = address(
                uint160(uint256(keccak256(abi.encodePacked(i))))
            );

            vm.prank(user1);
            token.transfer(recipient, singleTransfer);

            // 验证每笔转账
            assertEq(
                token.balanceOf(recipient),
                singleTransfer,
                "Each recipient should receive correct amount"
            );
        }

        // 验证发送者余额为零
        assertEq(token.balanceOf(user1), 0, "Sender balance should be zero");
    }

    // =============================================
    // 模糊测试
    // =============================================

    /**
     * @dev 转账功能的模糊测试
     * @param amount 随机生成的转账金额
     */
    function test_FuzzTransfer(uint256 amount) public {
        // 约束测试范围：金额必须 > 0 且 <= 初始供应量
        vm.assume(amount > 0 && amount <= INITIAL_SUPPLY * (10 ** DECIMALS));

        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialUser1Balance = token.balanceOf(user1);

        // 执行转账
        vm.prank(owner);
        token.transfer(user1, amount);

        // 验证余额变化
        assertEq(
            token.balanceOf(owner),
            initialOwnerBalance - amount,
            "Sender balance should decrease"
        );
        assertEq(
            token.balanceOf(user1),
            initialUser1Balance + amount,
            "Receiver balance should increase"
        );
    }
}
