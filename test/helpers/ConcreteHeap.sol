// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {BasicHeap} from "src/Heap.sol";

contract ConcreteHeap {
    using BasicHeap for BasicHeap.Heap;

    BasicHeap.Heap internal heap;

    function insert(address _id, BasicHeap.RandomStruct memory randomStruct) public {
        heap.insert(_id, randomStruct);
    }

    function decrease(address _id, BasicHeap.RandomStruct memory randomStruct) public {
        heap.decrease(_id, randomStruct);
    }

    function increase(address _id, BasicHeap.RandomStruct memory randomStruct) public {
        heap.increase(_id, randomStruct);
    }

    function remove(address _id) public {
        heap.remove(_id);
    }

    function getSize() public view returns (uint256) {
        return heap.getSize();
    }

    function containsAccount(address _id) public view returns (bool) {
        return heap.containsAccount(_id);
    }

    function getValueOf(address _id) public view returns (uint256) {
        return heap.getValueOf(_id);
    }

    function getRoot() public view returns (address) {
        return heap.getRoot();
    }

    function getParent(address _id) public view returns (address) {
        return heap.getParent(_id);
    }

    function getLeftChild(address _id) public view returns (address) {
        return heap.getLeftChild(_id);
    }

    function getRightChild(address _id) public view returns (address) {
        return heap.getRightChild(_id);
    }
}
