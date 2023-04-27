// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {BasicHeap} from "src/Heap.sol";
import {ConcreteHeap} from "./helpers/ConcreteHeap.sol";

contract Heap is ConcreteHeap {
    address[] internal accountsUsed;

    function accountsValue(uint256 _index) external view returns (uint256) {
        return BasicHeap.computeValue(heap.accounts[_index].randomStruct);
    }

    function accountsId(uint256 _index) external view returns (address) {
        return heap.accounts[_index].id;
    }

    function indexOf(address _id) external view returns (uint256) {
        return heap.indexOf[_id];
    }

    /// Functions to fuzz ///

    function insertCorrect(address account, BasicHeap.RandomStruct memory randomStruct) external {
        insert(account, randomStruct);
        accountsUsed.push(account);
    }

    function increaseCorrect(uint256 index, BasicHeap.RandomStruct memory randomStruct) external {
        if (accountsUsed.length == 0) {
            return;
        }
        index %= accountsUsed.length;
        address account = accountsUsed[index];
        uint256 accountValue = getValueOf(account);
        if (accountValue == type(uint256).max) {
            return;
        }
        if (BasicHeap.computeValue(randomStruct) > accountValue) {
            increase(account, randomStruct);
        }
    }

    function decreaseCorrect(uint256 index, BasicHeap.RandomStruct memory randomStruct) external {
        if (accountsUsed.length == 0) {
            return;
        }
        index %= accountsUsed.length;
        address account = accountsUsed[index];
        uint256 accountValue = getValueOf(account);
        if (accountValue == 0) {
            return;
        }
        if (BasicHeap.computeValue(randomStruct) < accountValue) {
            decrease(account, randomStruct);
        }
    }

    function removeCorrect(uint256 index) external {
        if (accountsUsed.length == 0) {
            return;
        }
        index %= accountsUsed.length;
        remove(accountsUsed[index]);
        accountsUsed[index] = accountsUsed[accountsUsed.length - 1];
        accountsUsed.pop();
    }
}

contract TestHeapInvariant is Test {
    Heap public heap;

    function setUp() public {
        heap = new Heap();
    }

    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    // Target specific selectors for invariant testing
    function targetSelectors() public view returns (FuzzSelector[] memory) {
        FuzzSelector[] memory targets = new FuzzSelector[](1);
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = Heap.insertCorrect.selector;
        selectors[1] = Heap.insertCorrect.selector; // more insertions that removals
        selectors[2] = Heap.increaseCorrect.selector;
        selectors[3] = Heap.decreaseCorrect.selector;
        selectors[4] = Heap.removeCorrect.selector;
        targets[0] = FuzzSelector(address(heap), selectors);
        return targets;
    }

    // Rule:
    // For all i in [[0, size]],
    // value[i] >= value[2i + 1] and value[i] >= value[2i + 2]
    function invariantHeap() public {
        uint256 size = heap.getSize();

        for (uint256 i; i < size; ++i) {
            address account = heap.accountsId(i);
            assertEq(heap.accountsValue(i), heap.getValueOf(account));
            if (i > 0) {
                uint256 parentIndex = (i - 1) / 2;
                assertTrue(heap.accountsValue(i) <= heap.accountsValue(parentIndex));
                assertEq(heap.getParent(account), heap.accountsId(parentIndex));
            } else {
                assertEq(heap.getParent(account), address(0));
            }

            uint256 leftChildIndex = 2 * i + 1;
            uint256 rightChildIndex = 2 * i + 2;
            if (leftChildIndex < size) {
                assertTrue(heap.accountsValue(i) >= heap.accountsValue(leftChildIndex));
                assertEq(heap.getLeftChild(account), heap.accountsId(leftChildIndex));
            } else {
                assertEq(heap.getLeftChild(account), address(0));
            }

            if (rightChildIndex < size) {
                assertTrue(heap.accountsValue(i) >= heap.accountsValue(rightChildIndex));
                assertEq(heap.getRightChild(account), heap.accountsId(rightChildIndex));
            } else {
                assertEq(heap.getRightChild(account), address(0));
            }
        }
    }

    // Rule:
    // For all i in [[0, length]], indexOf(account.id[i]) == i
    function invariantIndexOf() public {
        uint256 size = heap.getSize();

        for (uint256 i; i < size; ++i) {
            assertTrue(heap.indexOf(heap.accountsId(i)) == i);
        }
    }
}
