// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

interface IGridStructs {
    struct Order {
        uint256 id;
        address trader;
        uint256 quantity;
        bool isTaker;
        uint256 price;
        bool isBuy;
        bytes32 next; // Linked list pointer
    }

    struct LL {
        Order head;
        Order tail;
        uint256 size;
    }
}
