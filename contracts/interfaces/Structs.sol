// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

interface IGridStructs {
    struct Order {
        bytes32 id;
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
        uint quantity;
    }
    struct Node {
        uint parent;
        uint left;
        IGridStructs.LL ll;
        uint right;
        bool red;
        bytes32[] keys;
        mapping(bytes32 => uint) keyMap;
        uint count;
    }
    struct Tree {
        uint root;
        mapping(uint => Node) nodes;
        uint count;
    }
}
