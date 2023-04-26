// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;
import "hardhat/console.sol";
// import "solidity-linked-list/contracts/StructuredLinkedList.sol";
import "./interfaces/Structs.sol";

// import "./interfaces/IERC20.sol";
// import "./HitchensOrderStatisticsTreeLib.sol";

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
    mapping(address => bytes32[]) addressToOrder;
    uint takerFee = 9;
    uint makerFee = 6;

    uint maxBuy;
    uint prevMaxBuy;
    uint minSell = 1000000000000;
    uint prevMinSell;
    mapping(uint => uint) buyPtoQ;
    uint[] priceKeySetBuy;
    mapping(uint => uint) sellPtoQ;
    uint[] priceKeySetSell;

    function checkIfWhitelisted(address trader) public view returns (bool) {
        if (whitelisted[trader]) return true;
        return false;
    }

    constructor(address _timeOracle) {
        admin = msg.sender;
        timeOracle = _timeOracle;
    }

    function setMakerFee(uint _makerFee) public {
        require(msg.sender == admin, "You are not authorized");
        makerFee = _makerFee;
    }

    function setTakerFee(uint _takerFee) public {
        require(msg.sender == admin, "You are not authorized");
        takerFee = _takerFee;
    }

    function getRootTree(bool isBuy) public view returns (uint256) {
        return isBuy ? buyTree.root : sellTree.root;
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

    function getNextExe(address _user) public view returns (uint256) {
        return nextDayExe[_user];
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
        // require(
        //     _exists(isBuy, value),
        //     "OrderStatisticsTree(403) - Value does not exist."
        // );
        if (!_exists(isBuy, value))
            return
                IGridStructs.LL(
                    IGridStructs.Order(0, address(0), 0, false, 0, false, 0),
                    IGridStructs.Order(0, address(0), 0, false, 0, false, 0),
                    0,
                    0
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
        self.count++;
        require(
            value != EMPTY,
            "OrderStatisticsTree(405) - Value to insert cannot be zero"
        );
        // require(
        //     !_keyExists(isBuy, key, value),
        //     "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again."
        // );
        // if(self.count==1){
        //     self.root=value;
        // }
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
        }
        IGridStructs.Node storage nValue = self.nodes[value];
        // nValue.ll = ;
        nValue.parent = cursor;
        nValue.left = EMPTY;
        nValue.right = EMPTY;
        nValue.red = true;
        nValue.ll = IGridStructs.LL(
            IGridStructs.Order(0, address(0), 0, false, value, false, 0),
            IGridStructs.Order(0, address(0), 0, false, value, false, 0),
            0,
            0
        );
        nValue.count = 0;
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

    function _remove(bool isBuy, uint value) internal {
        console.log("remove called %s", value);
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        if (self.count == 0) return;
        self.count--;

        // console.log("inside remove price   -- %s", isBuy);
        require(
            value != EMPTY,
            "OrderStatisticsTree(407) - Value to delete cannot be zero "
        );
        // require(
        //     _keyExists(isBuy, key, value),
        //     "OrderStatisticsTree(408) - Value to delete does not exist."
        // );
        IGridStructs.Node storage nValue = self.nodes[value];
        // uint rowToDelete = nValue.keyMap[key];
        // nValue.keys[rowToDelete] = nValue.keys[nValue.keys.length - uint(1)];
        // nValue.keyMap[key] = rowToDelete;
        // nValue.keys.pop;
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

    function inOrderSellHelper(
        uint root,
        uint[2][10] memory priceArray
    ) public view {
        uint[100] memory stac;
        uint sc = 0;
        stac[sc++] = (root);
        uint curr = root;
        uint count = 0;
        while (curr != 0 && count < 10 && count < sellTree.count) {
            while (curr != 0) {
                stac[sc++] = (curr);
                curr = sellTree.nodes[root].left;
            }
            curr = stac[0];
            sc--;
            priceArray[count] = [
                sellTree.nodes[curr].ll.head.price,
                sellTree.nodes[curr].ll.quantity
            ];
            curr = sellTree.nodes[root].right;
            count++;
        }
    }

    function inOrderSell() public view returns (uint[2][10] memory) {
        uint[2][10] memory priceArray;
        inOrderSellHelper(sellTree.root, priceArray);
        return priceArray;
    }

    // function inOrderBuyHelper(
    //     uint root,
    //     uint[2][10] memory priceArray
    // ) public view {
    //     uint[100] memory stac;
    //     uint sc = 0;
    //     stac[sc++] = (root);
    //     uint curr = root;
    //     uint count = 0;
    //     while (curr != 0 && count < 10 && count < buyTree.count) {
    //         while (curr != 0) {
    //             stac[sc++] = (curr);
    //             curr = sellTree.nodes[root].right;
    //         }
    //         curr = stac[0];
    //         sc--;
    //         priceArray[count] = [
    //             sellTree.nodes[curr].ll.head.price,
    //             sellTree.nodes[curr].ll.quantity
    //         ];
    //         curr = sellTree.nodes[root].left;
    //         count++;
    //     }
    // }

    // function inOrderBuy() public view returns (uint[2][10] memory) {
    //     uint[2][10] memory priceArray;
    //     inOrderBuyHelper(buyTree.root, priceArray);
    //     return priceArray;
    // }

    function _treeMinimum(bool isBuy) public view returns (uint price) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint value = self.root;
        uint i = 1;
        while (i <= self.count && self.nodes[value].left != EMPTY) {
            value = self.nodes[value].left;
            i++;
        }
        return minSell;
    }

    function _treeMaximum(bool isBuy) public view returns (uint price) {
        IGridStructs.Tree storage self = isBuy ? buyTree : sellTree;
        uint value = self.root;
        // console.log(
        //     "treeMax consoling   -- %d",
        //     self.nodes[value].ll.head.price
        // );
        if (value == 0) {
            return 0;
        }
        uint i = 0;
        while (i <= self.count && self.nodes[value].right != EMPTY) {
            value = self.nodes[value].right;

            // console.log(
            //     "treeMax consoling   -- %d",
            //     self.nodes[value].ll.head.price
            // );
            i++;
        }
        return maxBuy;
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
        console.log("ALL IS WELL PLZ");

        // Choose the correct tree based on whether the order is a buy or sell
        if (order.isTaker) {
            orders[id] = order;
            takerMatching(id);
            matchOrders();
            return;
        }
        IGridStructs.Tree storage tree = order.isBuy ? buyTree : sellTree;
        console.log("now i would give up again %s", priceKeySetBuy.length);
        if (order.isBuy) {
            uint i = IndexOf2(priceKeySetBuy, order.price);
            if (i == priceKeySetBuy.length) priceKeySetBuy.push(order.price);
            if (order.price >= maxBuy) {
                prevMaxBuy = maxBuy;
                maxBuy = order.price;
            }
            buyPtoQ[order.price] += order.quantity;
        } else {
            uint i = IndexOf2(priceKeySetSell, order.price);
            if (i == priceKeySetSell.length) priceKeySetSell.push(order.price);
            if (order.price <= minSell) {
                prevMinSell = minSell;
                minSell = order.price;
            }
            sellPtoQ[order.price] += order.quantity;
        }

        orders[id] = order;
        addressToOrder[order.trader].push(order.id);

        // If the tree is empty, create a new node for the order
        if (tree.count == 0) {
            _insert(order.isBuy, 0x0, order.price);
            // console.log("Inserted into tree --> %d", tree.count);
            IGridStructs.LL memory _ll = IGridStructs.LL({
                head: order,
                tail: order,
                size: 1,
                quantity: order.quantity
            });
            // tree.count++;
            tree.nodes[tree.root].ll = _ll;
        } else {
            // Find the node corresponding to the order price or create a new node if it doesn't exist
            // bool ex=_exists(order.isBuy, order.price);
            IGridStructs.LL memory ll = _getNode(order.isBuy, order.price);

            if (ll.size == 0) {
                _insert(order.isBuy, 0x0, order.price);
                ll.head = order;
                ll.tail = order;
                ll.size = 1;
                ll.quantity = order.quantity;
                // tree.nodes[tree.root].ll = ll;
            } else {
                ll.tail.next = id;
                ll.tail = order;
                ll.size++;
                ll.quantity += order.quantity;
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

    function getOrdersForAddress(
        address trader
    ) public view returns (bytes32[] memory) {
        return addressToOrder[trader];
    }

    function getCurrentPrice(bool isBuy) public view returns (uint) {
        if (isBuy) {
            return maxBuy;
        }
        return minSell;
    }

    function IndexOf(
        bytes32[] memory values,
        bytes32 value
    ) public pure returns (uint) {
        uint i = 0;
        while (i < values.length && values[i] != value) {
            i++;
        }
        return i;
    }

    function IndexOf2(
        uint[] memory values,
        uint value
    ) public pure returns (uint) {
        uint i = 0;
        while (i < values.length && values[i] != value) {
            i++;
        }
        return i;
    }

    /** Removes the given value in an array. */
    function RemoveByValue(bytes32[] memory values, bytes32 value) public pure {
        uint i = IndexOf(values, value);
        RemoveByIndex(values, i);
    }

    /** Removes the value at the given index in an array. */
    function RemoveByIndex(bytes32[] memory values, uint i) public pure {
        unchecked {
            while (i < values.length - 1) {
                values[i] = values[i + 1];
                i++;
            }
            values[values.length - 1] = 0;
        }
    }

    function goodDeleteorder(bytes32 id) public {
        console.log(
            "anything not closfsfsde to reallll %s",
            orders[id].quantity
        );
        if (orders[id].isBuy) {
            buyPtoQ[orders[id].price] -= orders[id].quantity;
            console.log("orders[id].quantity is ==> %s", orders[id].price);
            if (buyPtoQ[maxBuy] == 0) {
                console.log("In delete order gege");
                maxBuy = prevMaxBuy;
                // maxBuy = orders[id];
                // prevMaxBuy=priceKeySetBuy
                uint just = maxBuy;
                uint res;
                for (uint i = priceKeySetBuy.length - 1; i >= 0; i--) {
                    if (
                        priceKeySetBuy[i] < just &&
                        buyPtoQ[priceKeySetBuy[i]] != 0
                    ) {
                        res = priceKeySetBuy[i] > res ? priceKeySetBuy[i] : res;
                    }
                }
                prevMaxBuy = res;
            }
        } else {
            sellPtoQ[orders[id].price] -= orders[id].quantity;
            console.log(
                "orders[id].quantity for selling is ==> %s",
                orders[id].price
            );
            if (sellPtoQ[minSell] == 0) {
                console.log("In delete order hulu");
                prevMinSell = minSell;

                uint just = minSell;
                uint res;
                for (uint i = 0; i < priceKeySetSell.length; i++) {
                    if (
                        priceKeySetSell[i] > just &&
                        sellPtoQ[priceKeySetSell[i]] != 0
                    ) {
                        res = priceKeySetSell[i] < res
                            ? priceKeySetSell[i]
                            : res;
                    }
                }
                prevMinSell = res;
                // minSell = orders[id];
            }
        }
    }

    function getAvCurrentPrice() public view returns (uint256) {
        if (buyTree.count == 0 && sellTree.count == 0) {
            // console.log("entering both zero condition");
            return 0;
        }
        if (buyTree.count == 0) {
            // console.log("entering buy tree zero case");
            return getCurrentPrice(false);
        }
        if (sellTree.count == 0) {
            // console.log("entering sell zero case");
            return getCurrentPrice(true);
        }

        // console.log("entering neither zero case");
        return ((maxBuy + minSell) / 2);
    }

    // Function to delete an order from the order book
    function deleteOrder(bytes32 id) public onlyRouter {
        console.log("price at delete order   -- %d", orders[id].price);
        // Choose the correct tree based on whether the order is a buy or sell
        IGridStructs.Tree storage tree = orders[id].isBuy ? buyTree : sellTree;
        if (tree.count == 0) return;

        // goodDeleteorder(id);
        // console.log("IS THIS BUY %s", orders[id].isBuy);
        // if (orders[id].isBuy) {
        //     buyPtoQ[orders[id].price] -= orders[id].quantity;
        //     console.log("orders[id].quantity is ==> %s", orders[id].price);
        //     if (buyPtoQ[maxBuy] == 0) {
        //         console.log("In delete order gege");
        //         maxBuy = prevMaxBuy;
        //         // maxBuy = orders[id];
        //         // prevMaxBuy=priceKeySetBuy
        //         uint just=maxBuy;
        //         uint res;
        //         for(uint i=priceKeySetBuy.length-1;i>=0;i--){
        //             if(priceKeySetBuy[i]<just && buyPtoQ[priceKeySetBuy[i]]!=0){
        //                 res=priceKeySetBuy[i]>res?priceKeySetBuy[i]:res;
        //             }
        //         }
        //         prevMaxBuy=res;
        //     }
        // } else {
        //     sellPtoQ[orders[id].price] -= orders[id].quantity;
        //     console.log("orders[id].quantity for selling is ==> %s",orders[id].price);
        //     if (sellPtoQ[minSell]==0) {
        //         console.log("In delete order hulu");
        //         prevMinSell = minSell;

        //         uint just=minSell;
        //         uint res;
        //         for(uint i=0;i<priceKeySetSell.length;i++){
        //             if(priceKeySetSell[i]>just && sellPtoQ[priceKeySetSell[i]]!=0){
        //                 res=priceKeySetSell[i]<res?priceKeySetSell[i]:res;
        //             }
        //         }
        //         prevMinSell=res;
        //         // minSell = orders[id];
        //     }
        // }

        // Find the node corresponding to the order price
        IGridStructs.LL memory ll = _getNode(
            orders[id].isBuy,
            orders[id].price
        );

        // RemoveByValue(addressToOrder[orders[id].trader], id);
        // if(addressToOrder[orders[id].trader].length>=2) addressToOrder[orders[id].trader].pop;
        // require(ll != 0, "Order not found");

        ll.quantity -= orders[id].quantity;
        if (ll.size == 1) {
            _remove(orders[id].isBuy, orders[id].price);
            delete orders[id]; // remove from map
            ll.size = 0;
            return;
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
        if (ll.size > 0) {
            ll.size--;
        }

        // If the linked list is now empty, delete the node from the tree

        // Rebalance the tree
        tree.root = _removeFixup(orders[id].isBuy, orders[id].price);

        delete orders[id]; // remove from map

        // if (order.isBuy) {
        //     orderBook.rootBuy = root;
        // } else {
        //     orderBook.rootSell = root;
        // }
        // matchOrders();
    }

    function getTakerFee() internal view returns (uint) {
        return takerFee;
    }

    function getMakerFee() internal view returns (uint) {
        return makerFee;
    }

    function takerMatching(bytes32 id) internal {
        IGridStructs.Order memory order = getOrderByID(id);
        if (order.isBuy) {
            if (sellTree.count == 0) return;
            IGridStructs.LL memory sellNodeLL = _getNode(
                false,
                _treeMinimum(false)
            );
            if (sellNodeLL.head.quantity >= order.quantity) {
                sellNodeLL.head.quantity -= order.quantity;

                uint256 amount = (order.quantity *
                    sellNodeLL.head.price *
                    (1000 - makerFee)) / 1000;

                (bool success, ) = sellNodeLL.head.trader.call{value: amount}(
                    ""
                );
                require(success, "Transfer failed.");
                amount =
                    order.price -
                    (order.quantity * sellNodeLL.head.price) -
                    ((order.quantity * sellNodeLL.head.price * takerFee) /
                        1000);
                (success, ) = order.trader.call{value: amount}("");
                require(success, "Transfer failed.");
                nextDayExe[order.trader] += order.quantity;
                return;
            } else {
                uint256 amount2;
                uint256 amount3;
                bool check = true;
                while (order.quantity > 0 && (sellTree.count != 0)) {
                    if (order.quantity > sellNodeLL.head.quantity) {
                        order.quantity -= sellNodeLL.head.quantity;
                        amount3 = sellNodeLL.head.quantity;
                        check = true;
                    } else {
                        amount3 = order.quantity;
                        sellNodeLL.head.quantity -= amount3;
                        order.quantity = 0;
                        check = false;
                    }
                    uint256 amount = ((amount3) *
                        sellNodeLL.head.price *
                        (1000 - makerFee)) / 1000;

                    (bool success1, ) = sellNodeLL.head.trader.call{
                        value: amount
                    }("");
                    require(success1, "Transfer failed.");
                    amount2 +=
                        ((amount3) *
                            sellNodeLL.head.price *
                            (1000 - takerFee)) /
                        1000;

                    nextDayExe[order.trader] += amount3;
                    if (check) deleteOrder(sellNodeLL.head.id);
                    sellNodeLL = _getNode(false, _treeMinimum(false));
                }
                (bool success, ) = order.trader.call{
                    value: (order.price - amount2)
                }("");
                require(success, "Transfer failed.");
            }
        } else {
            if (buyTree.count == 0) return;
            IGridStructs.LL memory buyNodeLL = _getNode(
                true,
                _treeMaximum(true)
            );
            if (buyNodeLL.head.quantity > order.quantity) {
                buyNodeLL.head.quantity -= order.quantity;

                uint amount = order.price -
                    (order.quantity * buyNodeLL.head.price) -
                    ((order.quantity * buyNodeLL.head.price * takerFee) / 1000);

                (bool success, ) = order.trader.call{value: amount}("");
                require(success, "Transfer failed.");
                nextDayExe[order.trader] += order.quantity;
                return;
            } else {
                uint amount2;
                uint amount3;
                bool check = true;
                while (order.quantity > 0 && (sellTree.count != 0)) {
                    if (order.quantity > buyNodeLL.head.quantity) {
                        order.quantity -= buyNodeLL.head.quantity;
                        amount3 = buyNodeLL.head.quantity;
                        check = true;
                    } else {
                        amount3 = order.quantity;
                        buyNodeLL.head.quantity -= amount3;
                        order.quantity = 0;
                        check = false;
                    }
                    amount2 +=
                        ((amount3) * buyNodeLL.head.price * (1000 - takerFee)) /
                        1000;

                    nextDayExe[order.trader] += amount3;
                    if (check) deleteOrder(buyNodeLL.head.id);
                    buyNodeLL = _getNode(false, _treeMinimum(false));
                }
                (bool success, ) = order.trader.call{
                    value: (order.price - amount2)
                }("");
                require(success, "Transfer failed.");
            }
        }
        delete orders[id];
    }

    function printAllOrders() public view {
        address a = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        address b = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        address c = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        bytes32[] memory orsa = getOrdersForAddress(a);
        bytes32[] memory orsb = getOrdersForAddress(b);
        bytes32[] memory orsc = getOrdersForAddress(c);
        for (uint i = 0; i < orsa.length; i++) {
            // console.log("logging order price -%s --- quantity-%d",getOrderByID(orsa[i]).price, getOrderByID(orsa[i]).quantity);
        }
        for (uint i = 0; i < orsb.length; i++) {
            // console.log("logging order %s --- %d",getOrderByID(orsb[i]).price, getOrderByID(orsb[i]).quantity);
        }
        for (uint i = 0; i < orsc.length; i++) {
            // console.log("logging order %s --- %d",getOrderByID(orsc[i]).price, getOrderByID(orsc[i]).quantity);
        }
    }

    function matchOrders() internal {
        if (buyTree.count == 0 || sellTree.count == 0) return;
        // console.log(
        //     "buyTree count is --> %d === sellTree count is --> %d",
        //     buyTree.count,
        //     sellTree.count
        // );
        IGridStructs.LL memory sellNodeLL = _getNode(
            false,
            _treeMinimum(false)
        );
        IGridStructs.LL memory buyNodeLL = _getNode(true, _treeMaximum(true));
        // while (sellNode != 0 && buyNode != 0) {
        uint i = 0;
        while (
            i < buyTree.count &&
            i < sellTree.count &&
            buyTree.count != 0 &&
            sellTree.count != 0 &&
            sellNodeLL.head.price <= buyNodeLL.head.price
        ) {
            i++;
            // printAllOrders();
            console.log("buyTree.count", buyTree.count);
            console.log("sellTree.count", sellTree.count);
            // If the sell price is less than or equal to the buy price, we have a match.
            IGridStructs.Order memory sellOrder = sellNodeLL.head;
            IGridStructs.Order memory buyOrder = buyNodeLL.head;
            // console.log("just outside sell= %d -- buy= %d ", sellOrder.quantity, buyOrder.quantity);
            // if(buyOrder.quantity==0){
            //     deleteOrder(buyOrder.id);
            // }
            // if(sellOrder.quantity==0){
            //     deleteOrder(sellOrder.id);
            // }
            // if (sellOrder.quantity != 0 && buyOrder.quantity != 0) {
            // console.log("ahhh");
            // console.log("sell order id is ===> %", sellOrder.id);
            if (sellOrder.quantity <= buyOrder.quantity) {
                // If the sell order quantity is less than or equal to the buy order quantity, the sell order is fully matched.
                // emit Trade(sellOrder.user, buyOrder.user, sellOrder.quantity, sellNode.key);

                buyOrder.quantity -= sellOrder.quantity;
                sellOrder.quantity = 0;
                buyNodeLL.quantity -= sellOrder.quantity;
                sellNodeLL.quantity -= sellOrder.quantity;
                uint256 amount = (sellOrder.quantity *
                    buyOrder.price *
                    (1000 - makerFee)) / 1000;

                (bool success, ) = sellOrder.trader.call{value: amount}("");
                require(success, "Transfer failed.");
                nextDayExe[buyOrder.trader] += sellOrder.quantity;

                if (buyOrder.quantity == 0) {
                    goodDeleteorder(buyOrder.id);
                    deleteOrder(buyOrder.id);
                }

                goodDeleteorder(sellOrder.id);
                deleteOrder(sellOrder.id);
                sellNodeLL = _getNode(false, _treeMinimum(false));
                sellOrder = sellNodeLL.head;
                buyNodeLL = _getNode(true, _treeMaximum(true));
                buyOrder = buyNodeLL.head;
            } else {
                // Otherwise, the sell order is partially matched.
                // emit Trade(sellOrder.user, buyOrder.user, buyOrder.quantity, sellNode.key);
                sellOrder.quantity -= buyOrder.quantity;
                buyOrder.quantity = 0;
                buyNodeLL.quantity -= buyOrder.quantity;
                sellNodeLL.quantity -= buyOrder.quantity;
                uint256 amount = (buyOrder.quantity *
                    buyOrder.price *
                    (1000 - makerFee)) / 1000;

                (bool success, ) = sellOrder.trader.call{value: amount}("");
                require(success, "Transfer failed.");
                nextDayExe[buyOrder.trader] += buyOrder.quantity;

                if (sellOrder.quantity == 0) {
                    deleteOrder(sellOrder.id);
                    goodDeleteorder(sellOrder.id);
                }

                goodDeleteorder(buyOrder.id);
                deleteOrder(buyOrder.id);
                buyNodeLL = _getNode(true, _treeMaximum(true));
                buyOrder = buyNodeLL.head;
                sellNodeLL = _getNode(false, _treeMinimum(false));
                sellOrder = sellNodeLL.head;
            }
            // }
            // else{
            //     break;
            // }
            // console.log("buyNodeLL  - %s", buyNodeLL.quantity);
            // console.log("sellNodeLL  - %s", sellNodeLL.quantity);
            // if (sellNodeLL.head.quantity == 0) {
            //     // If all sell orders at this price have been matched, remove the node from the sell tree.
            //     console.log("last sell price - %s", lastSell);
            //     _remove(false, 0x0, lastSell);
            // }
            // if (buyNodeLL.head.quantity == 0) {
            //     console.log("last buy price - %s", lastBuy);
            //     _remove(true, 0x0, lastBuy);
            // }
        }
        // }
    }

    fallback() external payable {}

    receive() external payable {}
}
