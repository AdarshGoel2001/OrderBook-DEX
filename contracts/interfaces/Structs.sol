// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IGridStructs {
    struct Order {
        address trader;
        uint256 quantity;
        bool isTaker;
        uint256 price;
        bool isBuy;
        bytes32 next; // Linked list pointer
    }
    struct LL {
        bytes32 head;
        bytes32 tail;
        uint256 size;
    }
}
