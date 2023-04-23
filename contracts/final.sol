pragma solidity ^0.8.0; 

import "./HitchensOrderStatisticsTreeLib.sol";
// import "solidity-linked-list/contracts/StructuredLinkedList.sol";
import "contracts/interfaces/Structs.sol";


contract test is HitchensOrderStatisticsTreeLib {

    
    // global vars
    mapping (bytes32 => Order) public orders;
    Tree buyTree;
    Tree sellTree;   


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
    function addOrder(
        Order memory order, bytes32 id
    ) external {
        // Choose the correct tree based on whether the order is a buy or sell
        Tree storage tree = order.isBuy
            ? buyTree
            : sellTree;

        orders[id]=order;
        // If the tree is empty, create a new node for the order
        if (tree.root == 0) {
            _insert(tree, 0x0, order.price);
            LL memory _ll= LL({head:order, tail:order, size:1})
            nodes[tree.root].ll=_ll;
        } else {
            // Find the node corresponding to the order price or create a new node if it doesn't exist
            LL ll = _getNode(root, order.price);

            if (ll == 0) {
                node = _insert(tree, 0x0, order.price);
                LL memory _ll= LL({head:order, tail:order, size:1})
                nodes[tree.root].ll=_ll;
            }
            else{
                ll.tail.next=id;
                ll.tail=order;
                ll.size++;
            }

            // Add the order to the linked list at the node
            // order.next = node.head;
            // node.head = order;
        }

        // Rebalance the tree
        tree.root=_insertFixup(tree, order.price);
        // if (order.isBuy) {
        //     orderBook.rootBuy = root;
        // } else {
        //     orderBook.rootSell = root;
        // }

        matchOrders();
    }

    function getOrderByID(bytes32 id) internal returns(Order){
        return orders[id];
    }

    function getCurrentPrice(bool isBuy) returns(uint){
        if(isBuy){
            Node cur=_treeMaximum(buyTree);
            return cur.ll.head.price;
        }
        Node cur=_treeMinimum(sellTree);
        return cur.ll.head.price;
    }

    // Function to delete an order from the order book
    function deleteOrder(
        bytes32 id
    ) private returns(bool){
        // Choose the correct tree based on whether the order is a buy or sell
        Tree storage tree = orders[id].isBuy
            ? buyTree;
            : sellTree;

        // Find the node corresponding to the order price
        LL ll = _getNode(tree, orders[id].price);
        // require(ll != 0, "Order not found");


        if(ll.size==1){
            _remove(tree, 0x0, orders[id].price);
            delete orders[id]; // remove from map
            return true;
        }
        // Find and remove the order from the linked list at the node
        Order storage curr = ll.head;
        Order storage prev = 0;
        while (curr != 0 && curr.id != id) {
            prev = curr;
            curr = orders[curr.next];
        }
        // require(curr != 0, "Order not found");
        if (prev == 0) {
            ll.head = orders[curr.next];
        } 
        else if(curr.next==0){
            prev.next = curr.next;
            ll.tail=prev;
        }
        else {
            prev.next = curr.next;
        }
        delete curr;
        ll.size--;
        // If the linked list is now empty, delete the node from the tree


        // Rebalance the tree
        tree.root = _removeFixup(tree, orders[id].price);
        delete orders[id]; // remove from map


        // if (order.isBuy) {
        //     orderBook.rootBuy = root;
        // } else {
        //     orderBook.rootSell = root;
        // }
        matchOrders();
        return true;
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
        Node sellNode = _treeMinimum(sellTree);
        Node buyNode = _treeMaximum(buyTree);
        LL sellNodeLL = sellNode.ll;
        LL buyNodeLL = buyNode.ll;
        // while (sellNode != 0 && buyNode != 0) {
        while (sellNodeLL.head.price <= buyNodeLL.head.price) {
            // If the sell price is less than or equal to the buy price, we have a match.
            Order storage sellOrder = sellNodeLL.head;
            Order storage buyOrder = buyNodeLL.head;
            while (sellOrder != 0 && buyOrder != 0) {
                if (sellOrder.quantity <= buyOrder.quantity) {
                    // If the sell order quantity is less than or equal to the buy order quantity, the sell order is fully matched.
                    // emit Trade(sellOrder.user, buyOrder.user, sellOrder.quantity, sellNode.key);
                    buyOrder.quantity -= sellOrder.quantity;
                    uint lastSell = sellNodeLL.head.price;
                    deleteOrder(sellOrder.id);
                    sellOrder = sellNodeLL.head;
                } else {
                    // Otherwise, the sell order is partially matched.
                    // emit Trade(sellOrder.user, buyOrder.user, buyOrder.quantity, sellNode.key);
                    sellOrder.quantity -= buyOrder.quantity;
                    uint lastBuy = buyNodeLL.head.price;
                    deleteOrder(buyOrder.id);
                    buyOrder = buyNodeLL.head;
                }
            }
            if (sellNodeLL.head == 0) {
                // If all sell orders at this price have been matched, remove the node from the sell tree.
                _remove(sellTree, 0x0, lastSell);
            }
            if(buyNodeLL.head == 0){
                _remove(buyTree, 0x0, lastBuy);
            }
            sellNode = _treeMinimum(sellTree);
            buyNode = _treeMaximum(buyTree);
        } 
        // }
    }
}
