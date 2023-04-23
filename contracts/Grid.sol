// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

// import "solidity-linked-list/contracts/StructuredLinkedList.sol";
import "./interfaces/Structs.sol";
import "./interfaces/IERC20.sol";
import "./HitchensOrderStatisticsTreeLib.sol";

contract Grid {
    IGridStructs.Tree buyTree;
    IGridStructs.Tree sellTree;
    mapping(address => uint256) exe;
    mapping(address => uint256) nextDayExe;
    mapping(address => bool) whitelisted;
    address[] whitelists;
    address router;
    address admin;
    uint256 daystart;
    address timeOracle;

    constructor(address _timeOracle) {
        admin = msg.sender;
        timeOracle = _timeOracle;
    }

    modifier onlyRouter() {
        require(
            msg.sender == router,
            "You are not authorized to place orders directly"
        );
        _;
    }

    function updateTimeStamp(uint256 _daystart) public {
        require(
            msg.sender == timeOracle,
            "You are not authorized to place orders directly"
        );
        daystart = _daystart;
    }

    function updateAllEXEbalances() public {
        require(block.timestamp >= daystart, "still time left");
        for (uint256 i = 0; i < whitelists.length; i++) {
            exe[whitelists[i]] = nextDayExe[whitelists[i]];
            nextDayExe[whitelists[i]] = 0;
        }
    }

    function setRouter(address _router) public {
        require(msg.sender == admin, "You are not authorized");
        router = _router;
    }

    function whitelist(address _user) public onlyRouter {
        whitelisted[_user] = true;
        whitelists.push(_user);
    }

    function getExe(address _user) public view returns (uint256) {
        return exe[_user];
    }

    function _exists(
        bool isBuy,
        uint value
    ) internal view returns (bool exists) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        if (value == EMPTY) return false;
        if (value == self.root) return true;
        if (self.nodes[value].parent != EMPTY) return true;
        return false;
    }

    function _keyExists(
        bool isBuy,
        bytes32 key,
        uint value
    ) internal view returns (bool exists) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        if (!_exists(isBuy, value)) return false;
        return self.nodes[value].keys[self.nodes[value].keyMap[key]] == key;
    }

    function _getNode(
        bool isBuy,
        uint value
    ) internal view returns (IGridStructs.LL memory ll) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        require(
            _exists(isBuy, value),
            "OrderStatisticsTree(403) - Value does not exist."
        );
        IGridStructs.Node storage gn = self.nodes[value];
        return gn.ll;
    }

    function _getNodeCount(
        bool isBuy,
        uint value
    ) internal view returns (uint count) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        IGridStructs.Node storage gn = self.nodes[value];
        return gn.keys.length + gn.count;
    }

    function _valueKeyAtIndex(
        bool isBuy,
        uint value,
        uint index
    ) internal view returns (bytes32 _key) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        require(
            _exists(isBuy, value),
            "OrderStatisticsTree(404) - Value does not exist."
        );
        return self.nodes[value].keys[index];
    }

    function _count(bool isBuy) internal view returns (uint count) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        return _getNodeCount(isBuy, self.root);
    }

    function _insert(bool isBuy, bytes32 key, uint value) internal {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        require(
            value != EMPTY,
            "OrderStatisticsTree(405) - Value to insert cannot be zero"
        );
        require(
            !_keyExists(isBuy, key, value),
            "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again."
        );
        uint cursor;
        uint probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (value < probe) {
                probe = self.nodes[probe].left;
            } else if (value > probe) {
                probe = self.nodes[probe].right;
            } else if (value == probe) {
                // self.nodes[probe].keyMap[key] =
                //     self.nodes[probe].keys.push(key) -
                //     uint(1);
                return;
            }
            self.nodes[cursor].count++;
        }
        IGridStructs.Node storage nValue = self.nodes[value];
        // nValue.ll = ;
        nValue.parent = cursor;
        nValue.left = EMPTY;
        nValue.right = EMPTY;
        nValue.red = true;
        // nValue.keyMap[key] = nValue.keys.push(key) - uint(1);
        if (cursor == EMPTY) {
            self.root = value;
        } else if (value < cursor) {
            self.nodes[cursor].left = value;
        } else {
            self.nodes[cursor].right = value;
        }
        _insertFixup(isBuy, value);
    }

    function _remove(bool isBuy, bytes32 key, uint value) internal {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        require(
            value != EMPTY,
            "OrderStatisticsTree(407) - Value to delete cannot be zero"
        );
        require(
            _keyExists(isBuy, key, value),
            "OrderStatisticsTree(408) - Value to delete does not exist."
        );
        IGridStructs.Node storage nValue = self.nodes[value];
        uint rowToDelete = nValue.keyMap[key];
        nValue.keys[rowToDelete] = nValue.keys[nValue.keys.length - uint(1)];
        nValue.keyMap[key] = rowToDelete;
        // nValue.keys.length--;
        uint probe;
        uint cursor;
        if (nValue.keys.length == 0) {
            if (
                self.nodes[value].left == EMPTY ||
                self.nodes[value].right == EMPTY
            ) {
                cursor = value;
            } else {
                cursor = self.nodes[value].right;
                while (self.nodes[cursor].left != EMPTY) {
                    cursor = self.nodes[cursor].left;
                }
            }
            if (self.nodes[cursor].left != EMPTY) {
                probe = self.nodes[cursor].left;
            } else {
                probe = self.nodes[cursor].right;
            }
            uint cursorParent = self.nodes[cursor].parent;
            self.nodes[probe].parent = cursorParent;
            if (cursorParent != EMPTY) {
                if (cursor == self.nodes[cursorParent].left) {
                    self.nodes[cursorParent].left = probe;
                } else {
                    self.nodes[cursorParent].right = probe;
                }
            } else {
                self.root = probe;
            }
            bool doFixup = !self.nodes[cursor].red;
            if (cursor != value) {
                _replaceParent(isBuy, cursor, value);
                self.nodes[cursor].left = self.nodes[value].left;
                self.nodes[self.nodes[cursor].left].parent = cursor;
                self.nodes[cursor].right = self.nodes[value].right;
                self.nodes[self.nodes[cursor].right].parent = cursor;
                self.nodes[cursor].red = self.nodes[value].red;
                (cursor, value) = (value, cursor);
                _fixCountRecurse(isBuy, value);
            }
            if (doFixup) {
                _removeFixup(isBuy, probe);
            }
            _fixCountRecurse(isBuy, cursorParent);
            delete self.nodes[cursor];
        }
    }

    function _fixCountRecurse(bool isBuy, uint value) private {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        while (value != EMPTY) {
            self.nodes[value].count =
                _getNodeCount(isBuy, self.nodes[value].left) +
                _getNodeCount(isBuy, self.nodes[value].right);
            value = self.nodes[value].parent;
        }
    }

    function _treeMinimum(bool isBuy) public view returns (uint price) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint value = self.root;
        while (self.nodes[value].left != EMPTY) {
            value = self.nodes[value].left;
        }
        return value;
    }

    function _treeMaximum(bool isBuy) public view returns (uint price) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint value = self.root;
        while (self.nodes[value].right != EMPTY) {
            value = self.nodes[value].right;
        }
        return value;
    }

    function _rotateLeft(bool isBuy, uint value) private {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint cursor = self.nodes[value].right;
        uint parent = self.nodes[value].parent;
        uint cursorLeft = self.nodes[cursor].left;
        self.nodes[value].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].left) {
            self.nodes[parent].left = cursor;
        } else {
            self.nodes[parent].right = cursor;
        }
        self.nodes[cursor].left = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count =
            _getNodeCount(isBuy, self.nodes[value].left) +
            _getNodeCount(isBuy, self.nodes[value].right);
        self.nodes[cursor].count =
            _getNodeCount(isBuy, self.nodes[cursor].left) +
            _getNodeCount(isBuy, self.nodes[cursor].right);
    }

    function _rotateRight(bool isBuy, uint value) private {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint cursor = self.nodes[value].left;
        uint parent = self.nodes[value].parent;
        uint cursorRight = self.nodes[cursor].right;
        self.nodes[value].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].right) {
            self.nodes[parent].right = cursor;
        } else {
            self.nodes[parent].left = cursor;
        }
        self.nodes[cursor].right = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count =
            _getNodeCount(isBuy, self.nodes[value].left) +
            _getNodeCount(isBuy, self.nodes[value].right);
        self.nodes[cursor].count =
            _getNodeCount(isBuy, self.nodes[cursor].left) +
            _getNodeCount(isBuy, self.nodes[cursor].right);
    }

    function _insertFixup(bool isBuy, uint value) internal returns (uint) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint cursor;
        while (value != self.root && self.nodes[self.nodes[value].parent].red) {
            uint valueParent = self.nodes[value].parent;
            if (
                valueParent == self.nodes[self.nodes[valueParent].parent].left
            ) {
                cursor = self.nodes[self.nodes[valueParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].right) {
                        value = valueParent;
                        _rotateLeft(isBuy, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    _rotateRight(isBuy, self.nodes[valueParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[valueParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].left) {
                        value = valueParent;
                        _rotateRight(isBuy, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    _rotateLeft(isBuy, self.nodes[valueParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
        return self.root;
    }

    function _replaceParent(bool isBuy, uint a, uint b) private {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function _removeFixup(bool isBuy, uint value) internal returns (uint) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint cursor;
        while (value != self.root && !self.nodes[value].red) {
            uint valueParent = self.nodes[value].parent;
            if (value == self.nodes[valueParent].left) {
                cursor = self.nodes[valueParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    _rotateLeft(isBuy, valueParent);
                    cursor = self.nodes[valueParent].right;
                }
                if (
                    !self.nodes[self.nodes[cursor].left].red &&
                    !self.nodes[self.nodes[cursor].right].red
                ) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        _rotateRight(isBuy, cursor);
                        cursor = self.nodes[valueParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    _rotateLeft(isBuy, valueParent);
                    value = self.root;
                }
            } else {
                cursor = self.nodes[valueParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    _rotateRight(isBuy, valueParent);
                    cursor = self.nodes[valueParent].left;
                }
                if (
                    !self.nodes[self.nodes[cursor].right].red &&
                    !self.nodes[self.nodes[cursor].left].red
                ) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        _rotateLeft(isBuy, cursor);
                        cursor = self.nodes[valueParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    _rotateRight(isBuy, valueParent);
                    value = self.root;
                }
            }
        }
        self.nodes[value].red = false;

        return self.root;
    }

    uint private EMPTY = 0;

    mapping(bytes32 => IGridStructs.Order) public orders;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;

    // struct Node {
    //         uint parent;
    //         uint left;
    //         uint right;
    //         bool red;
    //         bytes32[] keys;
    //         mapping(bytes32 => uint) keyMap;
    //         uint count;
    //     }

    // function addOrderToLL(Order memory order, LL ll) public returns (bool){
    //     if(ll==0){

    //     }
    //     bytes32 id = sha3(object.number,object.name,now,length);
    //     objects[id] = object;
    //     head = id;
    //     length = length+1;
    //     AddEntry(head,object.number,object.name,object.next);
    // }

    // Function to add an order to the order book
    function addOrder(IGridStructs.Order memory order, bytes32 id) external {
        // Choose the correct tree based on whether the order is a buy or sell
        IGridStructs.Tree storage tree = order.isBuy ? buyTree : sellTree;

        orders[id] = order;
        // If the tree is empty, create a new node for the order
        if (tree.root == 0) {
            _insert(order.isBuy, 0x0, order.price);
            IGridStructs.LL memory _ll = IGridStructs.LL({
                head: order,
                tail: order,
                size: 1
            });
            tree.nodes[tree.root].ll = _ll;
        } else {
            // Find the node corresponding to the order price or create a new node if it doesn't exist
            IGridStructs.LL memory ll = _getNode(order.isBuy, order.price);

            if (ll.size == 0) {
                _insert(order.isBuy, 0x0, order.price);
                IGridStructs.LL memory _ll = IGridStructs.LL({
                    head: order,
                    tail: order,
                    size: 1
                });
                tree.nodes[tree.root].ll = _ll;
            } else {
                ll.tail.next = id;
                ll.tail = order;
                ll.size++;
            }

            // Add the order to the linked list at the node
            // order.next = node.head;
            // node.head = order;
        }

        // Rebalance the tree
        tree.root = _insertFixup(order.isBuy, order.price);
        // if (order.isBuy) {
        //     orderBook.rootBuy = root;
        // } else {
        //     orderBook.rootSell = root;
        // }

        matchOrders();
    }

    function getOrderByID(
        bytes32 id
    ) public view returns (IGridStructs.Order memory) {
        return orders[id];
    }

    function getCurrentPrice(bool isBuy) public view returns (uint) {
        if (isBuy) {
            return _treeMaximum(isBuy);
        }
        return _treeMinimum(isBuy);
    }

    // Function to delete an order from the order book
    function deleteOrder(bytes32 id) public onlyRouter {
        // Choose the correct tree based on whether the order is a buy or sell
        IGridStructs.Tree storage tree = orders[id].isBuy ? buyTree : sellTree;

        // Find the node corresponding to the order price
        IGridStructs.LL memory ll = _getNode(
            orders[id].isBuy,
            orders[id].price
        );
        // require(ll != 0, "Order not found");

        if (ll.size == 1) {
            _remove(orders[id].isBuy, 0x0, orders[id].price);
            delete orders[id]; // remove from map
        }
        // Find and remove the order from the linked list at the node
        IGridStructs.Order memory curr = ll.head;
        IGridStructs.Order memory prev;
        while (curr.quantity != 0 && curr.id != id) {
            prev = curr;
            curr = orders[curr.next];
        }
        // require(curr != 0, "Order not found");
        if (prev.quantity == 0) {
            ll.head = orders[curr.next];
        } else if (curr.next == 0) {
            prev.next = curr.next;
            ll.tail = prev;
        } else {
            prev.next = curr.next;
        }
        delete curr;
        ll.size--;
        // If the linked list is now empty, delete the node from the tree

        // Rebalance the tree
        tree.root = _removeFixup(orders[id].isBuy, orders[id].price);
        if (orders[id].isTaker) {
            IERC20(usdc).transfer(
                orders[id].trader,
                orders[id].quantity * getCurrentPrice(orders[id].isBuy)
            );
        } else {
            IERC20(usdc).transfer(
                orders[id].trader,
                orders[id].quantity * orders[id].price
            );
        }
        delete orders[id]; // remove from map

        // if (order.isBuy) {
        //     orderBook.rootBuy = root;
        // } else {
        //     orderBook.rootSell = root;
        // }
        matchOrders();
    }

    // pragma solidity ^0.8.0;

    // // Order struct to represent a single order
    // struct Order {
    //     address user;
    //     uint256 amount;
    //     uint256 price;
    //     bool isBuy;
    // }

    // // Node struct to represent a single node in the AVL tree
    // struct Node {
    //     uint256 price;
    //     int256 balanceFactor;
    //     Node left;
    //     Node right;
    //     Order[] orders;
    // }

    // // Buy and sell trees
    // Node buyTree;
    // Node sellTree;

    // Get a node with the given price, or create one if it doesn't exist
    // function getNode(Node tree, uint256 price) internal returns (Node storage) {
    //     if (tree.price == price) {
    //         return tree;
    //     } else if (tree.price > price) {
    //         if (tree.left.price == 0) {
    //             tree.left.price = price;
    //         }
    //         return getNode(tree.left, price);
    //     } else {
    //         if (tree.right.price == 0) {
    //             tree.right.price = price;
    //         }
    //         return getNode(tree.right, price);
    //     }
    // }

    // Insert an order into the tree
    // function insertNode(Node tree, Order memory order) internal {
    //     Node storage node = getNode(tree, order.price);
    //     node.orders.push(order);
    //     balanceNode(node);
    // }

    // Balances a node in the AVL tree
    // function balanceNode(Node storage node) internal {
    //     int256 balance = getBalanceFactor(node);
    //     if (balance > 1) {
    //         if (getBalanceFactor(node.left) < 0) {
    //             rotateLeft(node.left);
    //         }
    //         rotateRight(node);
    //     } else if (balance < -1) {
    //         if (getBalanceFactor(node.right) > 0) {
    //             rotateRight(node.right);
    //         }
    //         rotateLeft(node);
    //     }
    // }

    // Rotates a node to the right
    // function rotateRight(Node storage node) internal {
    //     Node storage newParent = node.left;
    //     node.left = newParent.right;
    //     newParent.right = node;
    //     node.balanceFactor = getBalanceFactor(node);
    //     newParent.balanceFactor = getBalanceFactor(newParent);
    //     node = newParent;
    // }

    // // Rotates a node to the left
    // function rotateLeft(Node storage node) internal {
    //     Node storage newParent = node.right;
    //     node.right = newParent.left;
    //     newParent.left = node;
    //     node.balanceFactor = getBalanceFactor(node);
    //     newParent.balanceFactor = getBalanceFactor(newParent);
    //     node = newParent;
    // }

    // // Gets the balance factor of a node in the AVL tree
    // function getBalanceFactor(
    //     Node storage node
    // ) internal view returns (int256) {
    //     return int256(height(node.left)) - int256(height(node.right));
    // }

    // Gets the height of a node in the AVL tree
    // function height(Node storage node) internal view returns (uint256) {
    //     if (node.price == 0) {
    //         return 0;
    //     } else {
    //         uint256 leftHeight = height(node.left);
    //         uint256 rightHeight = height(node.right);
    //         if (leftHeight > rightHeight) {
    //             return leftHeight + 1;
    //         } else {
    //             return rightHeight + 1;
    //         }
    //     }
    // }

    // function deleteNode(
    //     uint256 price,
    //     bool orderType,
    //     OrderBook storage orderBook
    // ) public returns (bool) {
    //     Node storage root = orderType ? orderBook.rootBuy : orderBook.rootSell;

    //     Node storage node = getNode(root, price);
    //     if (node.price != price) {
    //         return false; // Node not found
    //     }

    //     // Case 1: Node has no children
    //     if (node.left == 0 && node.right == 0) {
    //         if (node.parent == 0) {
    //             root = 0; // Root node
    //         } else if (node.parent.left == node) {
    //             node.parent.left = 0; // Left child
    //         } else {
    //             node.parent.right = 0; // Right child
    //         }
    //         balanceNode(node.parent);
    //         return true;
    //     }

    //     // Case 2: Node has one child
    //     if (node.left == 0 || node.right == 0) {
    //         Node storage child = node.left != 0 ? node.left : node.right;
    //         child.parent = node.parent;
    //         if (node.parent == 0) {
    //             root[orderType] = child; // Root node
    //         } else if (node.parent.left == node) {
    //             node.parent.left = child; // Left child
    //         } else {
    //             node.parent.right = child; // Right child
    //         }
    //         balanceNode(child);
    //         return true;
    //     }

    //     // Case 3: Node has two children
    //     Node storage successor = getSuccessor(node);
    //     node.price = successor.price;
    //     node.orders = successor.orders;
    //     deleteNode(successor.price, orderType, orderBook);
    //     return true;
    // }

    // function getSuccessor(
    //     Node storage node
    // ) internal view returns (Node storage) {
    //     if (node.right != 0) {
    //         // If the node has a right child, its successor is the leftmost node of its right subtree.
    //         node = node.right;
    //         while (node.left != 0) {
    //             node = node.left;
    //         }
    //         return node;
    //     } else {
    //         // If the node does not have a right child, its successor is the nearest ancestor whose left child is also an ancestor of the node.
    //         Node storage parent = node.parent;
    //         while (parent != 0 && node == parent.right) {
    //             node = parent;
    //             parent = node.parent;
    //         }
    //         return parent;
    //     }
    // }

    // function findMinPrice(Node memory node) internal view returns (uint256) {
    //     if (node.left != 0) {
    //         return findMinPrice(node.left);
    //     }
    //     return node.price;
    // }

    // function findMaxPrice(Node memory node) internal view returns (uint256) {
    //     if (node.right != 0) {
    //         return findMaxPrice(node.right);
    //     }
    //     return node.price;
    // }

    function matchOrders() internal {
        IGridStructs.LL memory sellNodeLL = _getNode(
            false,
            _treeMinimum(false)
        );
        IGridStructs.LL memory buyNodeLL = _getNode(true, _treeMaximum(true));
        // while (sellNode != 0 && buyNode != 0) {
        while (sellNodeLL.head.price <= buyNodeLL.head.price) {
            // If the sell price is less than or equal to the buy price, we have a match.
            IGridStructs.Order memory sellOrder = sellNodeLL.head;
            IGridStructs.Order memory buyOrder = buyNodeLL.head;
            uint lastSell;
            uint lastBuy;
            if (sellOrder.quantity != 0 && buyOrder.quantity != 0) {
                if (sellOrder.quantity <= buyOrder.quantity) {
                    // If the sell order quantity is less than or equal to the buy order quantity, the sell order is fully matched.
                    // emit Trade(sellOrder.user, buyOrder.user, sellOrder.quantity, sellNode.key);
                    buyOrder.quantity -= sellOrder.quantity;
                    IERC20(usdc).transfer(
                        sellOrder.trader,
                        2 * sellOrder.quantity * buyOrder.price
                    );
                    nextDayExe[buyOrder.trader] += sellOrder.quantity;
                    deleteOrder(sellOrder.id);
                    sellOrder = sellNodeLL.head;
                } else {
                    // Otherwise, the sell order is partially matched.
                    // emit Trade(sellOrder.user, buyOrder.user, buyOrder.quantity, sellNode.key);
                    sellOrder.quantity -= buyOrder.quantity;
                    IERC20(usdc).transfer(
                        sellOrder.trader,
                        2 * buyOrder.quantity * buyOrder.price
                    );
                    nextDayExe[buyOrder.trader] += buyOrder.quantity;
                    deleteOrder(buyOrder.id);
                    buyOrder = buyNodeLL.head;
                }
            }
            if (sellNodeLL.head.quantity == 0) {
                // If all sell orders at this price have been matched, remove the node from the sell tree.
                _remove(false, 0x0, lastSell);
            }
            if (buyNodeLL.head.quantity == 0) {
                _remove(true, 0x0, lastBuy);
            }
        }
        // }
    }
}
