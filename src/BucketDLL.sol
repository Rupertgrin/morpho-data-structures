// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

library BucketDLL {
    /* STRUCTS */

    struct Account {
        address prev;
        address next;
    }

    struct List {
        mapping(address => Account) accounts;
    }

    /* INTERNAL */

    /// @notice Returns the address at the head of the `list`.
    /// @param list The list from which to get the head.
    /// @return The address of the head.
    function getHead(List storage list) internal view returns (address) {
        return list.accounts[address(0)].next;
    }

    /// @notice Returns the address at the tail of the `list`.
    /// @param list The list from which to get the tail.
    /// @return The address of the tail.
    function getTail(List storage list) internal view returns (address) {
        return list.accounts[address(0)].prev;
    }

    /// @notice Returns the next id address from the current `id`.
    /// @param list The list to search in.
    /// @param id The address of the current account.
    /// @return The address of the next account.
    function getNext(List storage list, address id) internal view returns (address) {
        return list.accounts[id].next;
    }

    /// @notice Returns the previous id address from the current `id`.
    /// @param list The list to search in.
    /// @param id The address of the current account.
    /// @return The address of the previous account.
    function getPrev(List storage list, address id) internal view returns (address) {
        return list.accounts[id].prev;
    }

    /// @notice Removes an account of the `list`.
    /// @dev This function should not be called with `id` equal to address 0.
    /// @param list The list to search in.
    /// @param id The address of the account.
    /// @return Whether the bucket is empty after removal.
    function remove(List storage list, address id) internal returns (bool) {
        Account memory account = list.accounts[id];
        address prev = account.prev;
        address next = account.next;

        list.accounts[prev].next = next;
        list.accounts[next].prev = prev;

        delete list.accounts[id];

        return (prev == address(0) && next == address(0));
    }

    /// @notice Inserts an account in the `list`.
    /// @dev This function should not be called with `id` equal to address 0.
    /// @param list The list to search in.
    /// @param id The address of the account.
    /// @param head Tells whether to insert at the head or at the tail of the list.
    /// @return Whether the bucket was empty before insertion.
    function insert(
        List storage list,
        address id,
        bool head
    ) internal returns (bool) {
        if (head) {
            address head = list.accounts[address(0)].next;
            list.accounts[address(0)].next = id;
            list.accounts[head].prev = id;
            list.accounts[id].next = head;
            return head == address(0);
        } else {
            address tail = list.accounts[address(0)].prev;
            list.accounts[address(0)].prev = id;
            list.accounts[tail].next = id;
            list.accounts[id].prev = tail;
            return tail == address(0);
        }
    }
}
