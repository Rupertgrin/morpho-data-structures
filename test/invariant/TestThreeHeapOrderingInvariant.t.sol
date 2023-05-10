// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {ThreeHeapOrderingMock} from "../mocks/ThreeHeapOrderingMock.sol";
import {ThreeHeapOrdering} from "src/ThreeHeapOrdering.sol";

contract Heap is ThreeHeapOrderingMock {
    using ThreeHeapOrdering for ThreeHeapOrdering.HeapArray;

    uint256 public MAX_SORTED_USERS = 16;

    /// @dev Function to fuzz
    function updateCorrect(address id, uint96 newValue) public {
        uint256 oldValue = heap.getValueOf(id);
        if (oldValue != 0 || newValue != 0) {
            heap.update(id, heap.getValueOf(id), newValue, MAX_SORTED_USERS);
        }
    }
}

contract TestThreeHeapOrderingInvariant is Test {
    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    Heap public heap;

    function setUp() public {
        heap = new Heap();
    }

    // Target specific selectors for invariant testing
    function targetSelectors() public view returns (FuzzSelector[] memory) {
        FuzzSelector[] memory targets = new FuzzSelector[](1);
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Heap.updateCorrect.selector;
        targets[0] = FuzzSelector(address(heap), selectors);
        return targets;
    }

    // Rule:
    // For all i in [[0, size]],
    // value[i] >= value[3i + 1] and value[i] >= value[3i + 2] and value[i] >= value[3i + 3]
    function invariantHeap() public {
        uint256 length = heap.length();

        for (uint256 i; i < length; ++i) {
            assertTrue((i * 3 + 1 >= length || i * 3 + 1 >= heap.size() || heap.accountsValue(i) >= heap.accountsValue(i * 3 + 1)));// forgefmt: disable-line
            assertTrue((i * 3 + 2 >= length || i * 3 + 2 >= heap.size() || heap.accountsValue(i) >= heap.accountsValue(i * 3 + 2)));// forgefmt: disable-line
            assertTrue((i * 3 + 3 >= length || i * 3 + 3 >= heap.size() || heap.accountsValue(i) >= heap.accountsValue(i * 3 + 3)));// forgefmt: disable-line
        }
    }

    // Rule:
    // For all i in [[0, length]], indexOf(account.id[i]) == i
    function invariantIndexOf() public {
        uint256 length = heap.length();

        for (uint256 i; i < length; ++i) {
            assertTrue(heap.indexOf(heap.accountsId(i)) == i);
        }
    }

    // Rule:
    // size <= 3 * MAX_SORTED_USERS
    function invariantSize() public {
        assertTrue(heap.size() <= 3 * heap.MAX_SORTED_USERS());
    }
}
