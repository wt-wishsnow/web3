// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract JobOne {
    address public owner;
    mapping(address => uint256) public votes;
    address[] public candidates;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /// @notice 允许用户投票给某个候选人
    /// @param candidate 候选人地址
    function vote(address candidate) public {
        if (votes[candidate] == 0) {
            candidates.push(candidate);
        }
        votes[candidate] += 1;
    }

    /// @notice 返回某个候选人得票数
    /// @param candidate 候选人地址
    /// @return 得票数
    function getCandidateVotes(
        address candidate
    ) public view returns (uint256) {
        return votes[candidate];
    }

    /// @notice 重置所有候选人得票数
    function resetVotes() public onlyOwner {
        for (uint i = 0; i < candidates.length; i++) {
            delete votes[candidates[i]];
        }
        delete candidates;
    }

    /// @notice 获取候选人数量
    /// @return 候选人数量
    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    /// @notice 反转字符串
    /// @param _str 输入字符串
    /// @return 反转后的字符串
    function reverseString(
        string memory _str
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory reversed = new bytes(strBytes.length);

        for (uint i = 0; i < strBytes.length; i++) {
            reversed[i] = strBytes[strBytes.length - 1 - i];
        }

        return string(reversed);
    }

    /// @notice 整数转罗马数字
    /// @param num 输入整数
    /// @return 罗马数字字符串
    function int2Roman(int256 num) public pure returns (string memory) {
        if (num == 0 || num >= 4000) {
            return "";
        }

        string[4] memory thousands = ["", "M", "MM", "MMM"];
        string[10] memory hundreds = [
            "",
            "C",
            "CC",
            "CCC",
            "CD",
            "D",
            "DC",
            "DCC",
            "DCCC",
            "CM"
        ];
        string[10] memory tens = [
            "",
            "X",
            "XX",
            "XXX",
            "XL",
            "L",
            "LX",
            "LXX",
            "LXXX",
            "XC"
        ];
        string[10] memory ones = [
            "",
            "I",
            "II",
            "III",
            "IV",
            "V",
            "VI",
            "VII",
            "VIII",
            "IX"
        ];

        string memory thousandsStr = thousands[uint256(num) / 1000];
        string memory hundredsStr = hundreds[(uint256(num) % 1000) / 100];
        string memory tensStr = tens[(uint256(num) % 100) / 10];
        string memory onesStr = ones[uint256(num) % 10];

        return
            string(
                abi.encodePacked(thousandsStr, hundredsStr, tensStr, onesStr)
            );
    }

    /// @notice 罗马数字转整数
    /// @param roman 罗马数字字符串
    /// @return num 对应的整数值
    function roman2Int(string memory roman) public pure returns (int16 num) {
        bytes memory romanBytes = bytes(roman);
        uint16 total = 0;

        for (uint256 i = 0; i < romanBytes.length; i++) {
            uint16 current = getRomanValue(romanBytes[i]);
            uint16 next = (i + 1 < romanBytes.length)
                ? getRomanValue(romanBytes[i + 1])
                : 0;

            if (current < next) {
                total += (next - current);
                i++;
            } else {
                total += current;
            }
        }

        return int16(total);
    }

    /// @notice 获取罗马字符对应的数值
    /// @param romanChar 罗马字符
    /// @return 对应的数值
    function getRomanValue(bytes1 romanChar) private pure returns (uint16) {
        if (romanChar == "I") return 1;
        if (romanChar == "V") return 5;
        if (romanChar == "X") return 10;
        if (romanChar == "L") return 50;
        if (romanChar == "C") return 100;
        if (romanChar == "D") return 500;
        if (romanChar == "M") return 1000;
        return 0;
    }

    /// @notice 合并两个有序数组
    /// @param arr1 第一个有序数组
    /// @param arr2 第二个有序数组
    /// @return 合并后的有序数组
    function mergeSortedArrays(
        uint256[] memory arr1,
        uint256[] memory arr2
    ) public pure returns (uint256[] memory) {
        uint256 len1 = arr1.length;
        uint256 len2 = arr2.length;
        uint256[] memory result = new uint256[](len1 + len2);

        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;

        while (i < len1 && j < len2) {
            if (arr1[i] <= arr2[j]) {
                result[k] = arr1[i];
                i++;
            } else {
                result[k] = arr2[j];
                j++;
            }
            k++;
        }

        while (i < len1) {
            result[k] = arr1[i];
            i++;
            k++;
        }

        while (j < len2) {
            result[k] = arr2[j];
            j++;
            k++;
        }

        return result;
    }

    /// @notice 二分查找
    /// @param arr 有序数组
    /// @param target 目标值
    /// @return 目标值索引，未找到返回-1
    function binarySearch(
        uint256[] memory arr,
        uint256 target
    ) public pure returns (int256) {
        uint256 left = 0;
        uint256 right = arr.length;

        while (left < right) {
            uint256 mid = left + (right - left) / 2;

            if (arr[mid] == target) {
                return int256(mid);
            } else if (arr[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return -1;
    }
}
