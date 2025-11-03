// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "./Begging.sol";

/**
 * @title Begging合约测试套件
 * @dev 测试Begging合约的所有功能
 */
contract BeggingTest is Test {
    Begging public begging;

    address public beggingOwner = makeAddr("beggingOwner");
    address public bidder1 = makeAddr("bidder1");
    address public bidder2 = makeAddr("bidder2");
    address public bidder3 = makeAddr("bidder3");
    address public stranger = makeAddr("stranger");

    event Bid(address indexed from, uint256 value);

    /// @dev 测试前置设置
    function setUp() public {
        vm.prank(beggingOwner);
        begging = new Begging();
        vm.deal(bidder1, 1 ether);
        vm.deal(bidder2, 1 ether);
    }

    // ========== 构造函数测试 ==========

    /// @dev 测试合约初始化
    function test_ConstructorInitialization() public view {
        assertEq(
            begging.owner(),
            beggingOwner,
            "Contract owner should be set correctly"
        );
    }

    // ========== 捐赠功能测试 ==========

    /// @dev 测试正常捐赠流程
    function test_Donate() public {
        vm.prank(bidder1);
        begging.donate{value: 1000}();
        assertEq(
            begging.bids(bidder1),
            1000,
            "First donation should be recorded correctly"
        );

        vm.prank(bidder1);
        begging.donate{value: 1000}();
        assertEq(begging.bids(bidder1), 2000, "Donations should be cumulative");

        vm.prank(bidder2);
        begging.donate{value: 700}();
        assertEq(
            begging.bids(bidder2),
            700,
            "Second bidder donation should be recorded"
        );
        assertEq(
            begging.bids(bidder1),
            2000,
            "First bidder amount should remain unchanged"
        );
    }

    /// @dev 测试零金额捐赠应回退
    function test_DonateZeroAmountReverts() public {
        vm.prank(bidder3);
        vm.expectRevert("Amount must be greater than 0");
        begging.donate{value: 0}();
    }

    /// @dev 测试捐赠事件发射
    function test_DonateEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Bid(bidder1, 500);

        vm.prank(bidder1);
        begging.donate{value: 500}();
    }

    /// @dev 测试捐赠返回值
    function test_DonateReturnValue() public {
        vm.prank(bidder1);
        bool success = begging.donate{value: 100}();
        assertTrue(success, "Donate function should return true");
    }

    // ========== 提现功能测试 ==========

    /// @dev 测试所有者提现
    function test_WithdrawByOwner() public {
        vm.prank(bidder1);
        begging.donate{value: 1000}();

        uint256 initialBalance = beggingOwner.balance;
        uint256 contractBalance = address(begging).balance;

        vm.prank(beggingOwner);
        begging.withdraw();

        assertEq(
            address(begging).balance,
            0,
            "Contract balance should be zero after withdrawal"
        );
        assertEq(
            beggingOwner.balance,
            initialBalance + contractBalance,
            "Owner should receive the contract balance"
        );
    }

    /// @dev 测试非所有者提现应回退
    function test_WithdrawByNonOwnerReverts() public {
        vm.prank(bidder1);
        begging.donate{value: 1000}();

        vm.prank(stranger);
        vm.expectRevert("Only owner can call this function");
        begging.withdraw();
    }

    /// @dev 测试零余额提现
    function test_WithdrawZeroBalance() public {
        uint256 initialBalance = beggingOwner.balance;

        vm.prank(beggingOwner);
        begging.withdraw();

        assertEq(
            address(begging).balance,
            0,
            "Contract balance should remain zero"
        );
        assertEq(
            beggingOwner.balance,
            initialBalance,
            "Owner balance should not change with zero balance withdrawal"
        );
    }

    // ========== 查询功能测试 ==========

    /// @dev 测试查询捐赠金额
    function test_GetDonation() public {
        vm.prank(bidder1);
        begging.donate{value: 1500}();

        uint256 donation = begging.getDonation(bidder1);
        assertEq(donation, 1500, "Should return correct donation amount");
    }

    /// @dev 测试查询非捐赠者
    function test_GetDonationNonDonor() public view {
        uint256 donation = begging.getDonation(stranger);
        assertEq(donation, 0, "Should return zero for non-donor");
    }

    // ========== 接收函数测试 ==========

    /// @dev 测试直接转账应回退
    function test_ReceiveReverts() public {
        vm.prank(bidder1);
        vm.expectRevert("Please use donate() function");
        (bool success, ) = address(begging).call{value: 100}("");
        require(success, "Transfer failed");
    }

    // ========== 边界案例测试 ==========

    /// @dev 测试多地址多次捐赠
    function test_MultipleDonations() public {
        vm.prank(bidder1);
        begging.donate{value: 100}();
        vm.prank(bidder1);
        begging.donate{value: 200}();
        vm.prank(bidder1);
        begging.donate{value: 300}();

        vm.prank(bidder2);
        begging.donate{value: 500}();

        vm.deal(bidder3, 1 ether);
        vm.prank(bidder3);
        begging.donate{value: 1000}();

        assertEq(
            begging.bids(bidder1),
            600,
            "Bidder1 total should be sum of all donations"
        );
        assertEq(begging.bids(bidder2), 500, "Bidder2 total should be correct");
        assertEq(
            begging.bids(bidder3),
            1000,
            "Bidder3 total should be correct"
        );
        assertEq(
            address(begging).balance,
            2100,
            "Contract balance should equal total donations"
        );
    }

    /// @dev 测试大额捐赠
    function test_DonateLargeAmount() public {
        uint256 largeAmount = 1000 ether;
        vm.deal(bidder1, largeAmount);

        vm.prank(bidder1);
        begging.donate{value: largeAmount}();

        assertEq(
            begging.bids(bidder1),
            largeAmount,
            "Should handle large amounts correctly"
        );
        assertEq(
            address(begging).balance,
            largeAmount,
            "Contract should receive large amount"
        );
    }

    /// @dev 测试完整业务流程
    function test_CompleteFlow() public {
        vm.prank(bidder1);
        begging.donate{value: 1000}();
        vm.prank(bidder2);
        begging.donate{value: 2000}();

        assertEq(
            address(begging).balance,
            3000,
            "Contract should have correct balance after donations"
        );

        uint256 initialOwnerBalance = beggingOwner.balance;
        vm.prank(beggingOwner);
        begging.withdraw();

        assertEq(
            address(begging).balance,
            0,
            "Contract balance should be zero after withdrawal"
        );
        assertEq(
            beggingOwner.balance,
            initialOwnerBalance + 3000,
            "Owner should receive all contract funds"
        );

        vm.deal(bidder3, 1 ether);
        vm.prank(bidder3);
        begging.donate{value: 500}();

        assertEq(
            begging.bids(bidder3),
            500,
            "New donations should be recorded correctly after withdrawal"
        );
        assertEq(
            address(begging).balance,
            500,
            "Contract should accumulate new donations"
        );
    }

    /// @dev 测试提现后捐赠记录持久化
    function test_DonationMappingPersistsAfterWithdrawal() public {
        vm.prank(bidder1);
        begging.donate{value: 1000}();
        vm.prank(bidder2);
        begging.donate{value: 2000}();

        uint256 bidder1Before = begging.bids(bidder1);
        uint256 bidder2Before = begging.bids(bidder2);

        vm.prank(beggingOwner);
        begging.withdraw();

        assertEq(
            begging.bids(bidder1),
            bidder1Before,
            "Bidder1 donation record should persist after withdrawal"
        );
        assertEq(
            begging.bids(bidder2),
            bidder2Before,
            "Bidder2 donation record should persist after withdrawal"
        );
    }

    /// @dev 测试合约余额计算正确性
    function test_ContractBalance() public {
        uint256 amount1 = 1000;
        uint256 amount2 = 2000;

        vm.prank(bidder1);
        begging.donate{value: amount1}();

        assertEq(
            address(begging).balance,
            amount1,
            "Contract balance should match single donation"
        );

        vm.prank(bidder2);
        begging.donate{value: amount2}();

        assertEq(
            address(begging).balance,
            amount1 + amount2,
            "Contract balance should match total donations"
        );
    }
}
