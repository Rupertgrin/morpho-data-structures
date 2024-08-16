// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

/// @title Double Linked List
/// @author Morpho Labs
/// @custom:contact security@morpho.xyz
/// @notice Modified double linked list with capped sorting insertion.
library DoubleLinkedList {
    /* STRUCTS */

    struct Account {
        address prev;
        address next;
        uint256 value;
    }

    struct List {
        mapping(address => Account) accounts;
        address head;
        address tail;
    }

    /* ERRORS */

    /// @notice Thrown when the account is already inserted in the double linked list.
    error AccountAlreadyInserted();

    /// @notice Thrown when the account to remove does not exist.
    error AccountDoesNotExist();

    /// @notice Thrown when the address is zero at insertion.
    error AddressIsZero();

    /// @notice Thrown when the value is zero at insertion.
    error ValueIsZero();

    /* INTERNAL */

    /// @notice Returns the value of the account linked to the given address.
    /// @param list The list to search in.
    /// @param id The address of the account.
    /// @return The value of the account.
    function getValueOf(List storage list, address id) internal view returns (uint256) {
        return list.accounts[id].value;
    }

    /// @notice Returns the address at the head of the list.
    /// @param list The list to get the head.
    /// @return The address of the head.
    function getHead(List storage list) internal view returns (address) {
        return list.head;
    }

    /// @notice Returns the address at the tail of the list.
    /// @param list The list to get the tail.
    /// @return The address of the tail.
    function getTail(List storage list) internal view returns (address) {
        return list.tail;
    }

    /// @notice Returns the address of the next account from the given address.
    /// @param list The list to search in.
    /// @param id The address of the account.
    /// @return The address of the next account.
    function getNext(List storage list, address id) internal view returns (address) {
        return list.accounts[id].next;
    }

    /// @notice Returns the address of the previous account from the given address.
    /// @param list The list to search in.
    /// @param id The address of the account.
    /// @return The address of the previous account.
    function getPrev(List storage list, address id) internal view returns (address) {
        return list.accounts[id].prev;
    }

    /// @notice Removes an account from the list.
    /// @param list The list to modify.
    /// @param id The address of the account to remove.
    function remove(List storage list, address id) internal {
        Account storage account = list.accounts[id];
        if (account.value == 0) revert AccountDoesNotExist();

        // Update the links of the neighboring accounts
        if (account.prev != address(0)) list.accounts[account.prev].next = account.next;
        else list.head = account.next;
        if (account.next != address(0)) list.accounts[account.next].prev = account.prev;
        else list.tail = account.prev;

        // Clear the account entry
        delete list.accounts[id];
    }

    /// @notice Inserts an account in the list in sorted order based on its value.
    /// @param list The list to modify.
    /// @param id The address of the account to insert.
    /// @param value The value of the account.
    /// @param maxIterations The maximum number of iterations to find the correct position.
    function insertSorted(List storage list, address id, uint256 value, uint256 maxIterations) internal {
        if (value == 0) revert ValueIsZero();
        if (id == address(0)) revert AddressIsZero();
        if (list.accounts[id].value != 0) revert AccountAlreadyInserted();

        uint256 iterations;
        address next = list.head;

        while (iterations < maxIterations && next != address(0) && list.accounts[next].value >= value) {
            next = list.accounts[next].next;
            unchecked {
                ++iterations;
            }
        }

        if (iterations < maxIterations && next != address(0)) {
            // Insert before the current 'next'
            address prev = list.accounts[next].prev;
            list.accounts[id] = Account({prev: prev, next: next, value: value});
            list.accounts[prev].next = id;
            list.accounts[next].prev = id;
        } else {
            // Insert at the end or in an empty list
            if (list.head == address(0)) {
                // List is empty
                list.accounts[id] = Account({prev: address(0), next: address(0), value: value});
                list.head = id;
                list.tail = id;
            } else {
                // Append to the tail
                address tail = list.tail;
                list.accounts[id] = Account({prev: tail, next: address(0), value: value});
                list.accounts[tail].next = id;
                list.tail = id;
            }
        }
    }
}
