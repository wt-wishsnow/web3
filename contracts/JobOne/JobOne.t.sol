// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "./JobOne.sol";

contract JobOneTest is Test {
    JobOne public jobOne;
    address public owner = address(0x123);
    address public user1 = address(0x456);
    address public user2 = address(0x789);
    address public candidate1 = address(0x111);
    address public candidate2 = address(0x222);
    address public candidate3 = address(0x333);

    function setUp() public {
        vm.prank(owner);
        jobOne = new JobOne();
    }

    /// @dev 测试构造函数
    function test_Constructor() public view {
        assertEq(jobOne.owner(), owner);
    }

    /// @dev 测试投票功能
    function test_Vote() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        assertEq(jobOne.getCandidateVotes(candidate1), 1);
        assertEq(jobOne.getCandidateCount(), 1);
    }

    /// @dev 测试多次投票给同一个候选人
    function test_MultipleVotes() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        vm.prank(user2);
        jobOne.vote(candidate1);

        assertEq(jobOne.getCandidateVotes(candidate1), 2);
        assertEq(jobOne.getCandidateCount(), 1);
    }

    /// @dev 测试投票给多个候选人
    function test_VoteMultipleCandidates() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        vm.prank(user1);
        jobOne.vote(candidate2);

        assertEq(jobOne.getCandidateVotes(candidate1), 1);
        assertEq(jobOne.getCandidateVotes(candidate2), 1);
        assertEq(jobOne.getCandidateCount(), 2);
    }

    /// @dev 测试重置投票 - 只有owner可以调用
    function test_ResetVotes() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        vm.prank(user2);
        jobOne.vote(candidate2);

        assertEq(jobOne.getCandidateCount(), 2);

        vm.prank(owner);
        jobOne.resetVotes();

        assertEq(jobOne.getCandidateCount(), 0);
        assertEq(jobOne.getCandidateVotes(candidate1), 0);
        assertEq(jobOne.getCandidateVotes(candidate2), 0);
    }

    /// @dev 测试非owner不能重置投票
    function test_ResetVotesNotOwner() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        vm.prank(user1);
        vm.expectRevert("Only owner can call this function");
        jobOne.resetVotes();
    }

    /// @dev 测试字符串反转
    function test_ReverseString() public view {
        string memory result = jobOne.reverseString("abcde");
        assertEq(result, "edcba");

        result = jobOne.reverseString("hello");
        assertEq(result, "olleh");

        result = jobOne.reverseString("");
        assertEq(result, "");

        result = jobOne.reverseString("a");
        assertEq(result, "a");
    }

    /// @dev 测试整数转罗马数字
    function test_Int2Roman() public view {
        assertEq(jobOne.int2Roman(1), "I");
        assertEq(jobOne.int2Roman(4), "IV");
        assertEq(jobOne.int2Roman(9), "IX");
        assertEq(jobOne.int2Roman(58), "LVIII");
        assertEq(jobOne.int2Roman(1994), "MCMXCIV");

        assertEq(jobOne.int2Roman(0), "");
        assertEq(jobOne.int2Roman(4000), "");
    }

    /// @dev 测试罗马数字转整数
    function test_Roman2Int() public view {
        assertEq(jobOne.roman2Int("I"), 1);
        assertEq(jobOne.roman2Int("IV"), 4);
        assertEq(jobOne.roman2Int("IX"), 9);
        assertEq(jobOne.roman2Int("LVIII"), 58);
        assertEq(jobOne.roman2Int("MCMXCIV"), 1994);

        assertEq(jobOne.roman2Int("CM"), 900);
        assertEq(jobOne.roman2Int("CD"), 400);
        assertEq(jobOne.roman2Int("XC"), 90);
        assertEq(jobOne.roman2Int("XL"), 40);
    }

    /// @dev 测试罗马数字和整数的双向转换
    function test_RomanIntRoundTrip() public view {
        int16[] memory testNumbers = new int16[](6);
        testNumbers[0] = 1;
        testNumbers[1] = 4;
        testNumbers[2] = 9;
        testNumbers[3] = 49;
        testNumbers[4] = 99;
        testNumbers[5] = 499;

        for (uint i = 0; i < testNumbers.length; i++) {
            string memory roman = jobOne.int2Roman(testNumbers[i]);
            int16 convertedBack = jobOne.roman2Int(roman);
            assertEq(convertedBack, testNumbers[i]);
        }
    }

    /// @dev 测试合并有序数组
    function test_MergeSortedArrays() public view {
        uint256[] memory arr1 = new uint256[](3);
        arr1[0] = 1;
        arr1[1] = 3;
        arr1[2] = 5;

        uint256[] memory arr2 = new uint256[](3);
        arr2[0] = 2;
        arr2[1] = 4;
        arr2[2] = 6;

        uint256[] memory result = jobOne.mergeSortedArrays(arr1, arr2);

        uint256[] memory expected = new uint256[](6);
        expected[0] = 1;
        expected[1] = 2;
        expected[2] = 3;
        expected[3] = 4;
        expected[4] = 5;
        expected[5] = 6;

        for (uint i = 0; i < expected.length; i++) {
            assertEq(result[i], expected[i]);
        }
    }

    /// @dev 测试合并空数组
    function test_MergeEmptyArrays() public view {
        uint256[] memory empty = new uint256[](0);
        uint256[] memory arr = new uint256[](2);
        arr[0] = 1;
        arr[1] = 2;

        uint256[] memory result1 = jobOne.mergeSortedArrays(empty, arr);
        assertEq(result1.length, 2);
        assertEq(result1[0], 1);
        assertEq(result1[1], 2);

        uint256[] memory result2 = jobOne.mergeSortedArrays(arr, empty);
        assertEq(result2.length, 2);
        assertEq(result2[0], 1);
        assertEq(result2[1], 2);

        uint256[] memory result3 = jobOne.mergeSortedArrays(empty, empty);
        assertEq(result3.length, 0);
    }

    /// @dev 测试二分查找
    function test_BinarySearch() public view {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 1;
        arr[1] = 3;
        arr[2] = 5;
        arr[3] = 7;
        arr[4] = 9;

        assertEq(jobOne.binarySearch(arr, 1), 0);
        assertEq(jobOne.binarySearch(arr, 5), 2);
        assertEq(jobOne.binarySearch(arr, 9), 4);

        assertEq(jobOne.binarySearch(arr, 0), -1);
        assertEq(jobOne.binarySearch(arr, 4), -1);
        assertEq(jobOne.binarySearch(arr, 10), -1);
    }

    /// @dev 测试二分查找空数组
    function test_BinarySearchEmptyArray() public view {
        uint256[] memory empty = new uint256[](0);
        assertEq(jobOne.binarySearch(empty, 1), -1);
    }

    /// @dev 测试候选人列表管理
    function test_CandidateListManagement() public {
        vm.prank(user1);
        jobOne.vote(candidate1);

        vm.prank(user2);
        jobOne.vote(candidate2);

        vm.prank(user1);
        jobOne.vote(candidate3);

        assertEq(jobOne.getCandidateCount(), 3);
        assertEq(jobOne.getCandidateVotes(candidate1), 1);
        assertEq(jobOne.getCandidateVotes(candidate2), 1);
        assertEq(jobOne.getCandidateVotes(candidate3), 1);
    }
}
