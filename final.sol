pragma solidity ^0.8.0;

contract  test {



// Struct for an order
struct Order {
    uint256 id;
    address trader;
    uint256 quantity;
    uint256 price;
    bool isBuy;
    Order next; // Linked list pointer
}

// Struct for a tree node
struct Node {
    uint256 key;
    Order head; // Linked list head pointer
    uint8 height;
    Node left;
    Node right;
}

// Order book struct
struct OrderBook {
    Node rootBuy;
    Node rootSell;
}

// Function to add an order to the order book
function addOrder(Order memory order, OrderBook storage orderBook) external {
    // Choose the correct tree based on whether the order is a buy or sell
    Node storage root = order.isBuy ? orderBook.rootBuy : orderBook.rootSell;
    
    // If the tree is empty, create a new node for the order
    if (root == 0) {
        root = Node({
            key: order.price,
            height: 1,
            head: order,
            left: 0,
            right: 0
        });
    } else {
        // Find the node corresponding to the order price or create a new node if it doesn't exist
        Node storage node = getNode(order.price, root);
        if (node == 0) {
            node = insertNode(order.price, root);
        }
        
        // Add the order to the linked list at the node
        order.next = node.head;
        node.head = order;
    }
    
    // Rebalance the tree
    root = balanceNode(root);
    if (order.isBuy) {
        orderBook.rootBuy = root;
    } else {
        orderBook.rootSell = root;
    }
}

// Function to delete an order from the order book
function deleteOrder(Order memory order, OrderBook storage orderBook) private {
    // Choose the correct tree based on whether the order is a buy or sell
    Node storage root = order.isBuy ? orderBook.rootBuy : orderBook.rootSell;
    
    // Find the node corresponding to the order price
    Node storage node = getNode(order.price, root);
    require(node != 0, "Order not found");
    
    // Find and remove the order from the linked list at the node
    Order storage curr = node.head;
    Order storage prev = 0;
    while (curr != 0 && curr.id != order.id) {
        prev = curr;
        curr = curr.next;
    }
    require(curr != 0, "Order not found");
    if (prev == 0) {
        node.head = curr.next;
    } else {
        prev.next = curr.next;
    }
    
    // If the linked list is now empty, delete the node from the tree
    if (node.head == 0) {
        root = deleteNode(node.key, order.isBuy, orderBook);
    }
    
    // Rebalance the tree
    root = balanceNode(root);
    if (order.isBuy) {
        orderBook.rootBuy = root;
    } else {
        orderBook.rootSell = root;
    }
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
function getNode(Node tree, uint256 price) internal returns (Node storage) {
    if (tree.price == price) {
        return tree;
    } else if (tree.price > price) {
        if (tree.left.price == 0) {
            tree.left.price = price;
        }
        return getNode(tree.left, price);
    } else {
        if (tree.right.price == 0) {
            tree.right.price = price;
        }
        return getNode(tree.right, price);
    }
}

// Insert an order into the tree
function insertNode(Node tree, Order memory order) internal {
    Node storage node = getNode(tree, order.price);
    node.orders.push(order);
    balanceNode(node);
}

// Balances a node in the AVL tree
function balanceNode(Node storage node) internal {
    int256 balance = getBalanceFactor(node);
    if (balance > 1) {
        if (getBalanceFactor(node.left) < 0) {
            rotateLeft(node.left);
        }
        rotateRight(node);
    } else if (balance < -1) {
        if (getBalanceFactor(node.right) > 0) {
            rotateRight(node.right);
        }
        rotateLeft(node);
    }
}

// Rotates a node to the right
function rotateRight(Node storage node) internal {
    Node storage newParent = node.left;
    node.left = newParent.right;
    newParent.right = node;
    node.balanceFactor = getBalanceFactor(node);
    newParent.balanceFactor = getBalanceFactor(newParent);
    node = newParent;
}

// Rotates a node to the left
function rotateLeft(Node storage node) internal {
    Node storage newParent = node.right;
    node.right = newParent.left;
    newParent.left = node;
    node.balanceFactor = getBalanceFactor(node);
    newParent.balanceFactor = getBalanceFactor(newParent);
    node = newParent;
}

// Gets the balance factor of a node in the AVL tree
function getBalanceFactor(Node storage node) internal view returns (int256) {
    return int256(height(node.left)) - int256(height(node.right));
}

// Gets the height of a node in the AVL tree
function height(Node storage node) internal view returns (uint256) {
    if (node.price == 0) {
        return 0;
    } else {
        uint256 leftHeight = height(node.left);
        uint256 rightHeight = height(node.right);
        if (leftHeight > rightHeight) {
            return leftHeight + 1;
        } else {
            return rightHeight + 1;
        }
    }
}

function deleteNode(uint256 price, bool orderType, OrderBook storage orderBook) public returns (bool) {

    Node storage root = orderType ? orderBook.rootBuy : orderBook.rootSell;

    Node storage node = getNode(root, price);
    if (node.price != price) {
        return false; // Node not found
    }

    // Case 1: Node has no children
    if (node.left == 0 && node.right == 0) {
        if (node.parent == 0) {
            root = 0; // Root node
        } else if (node.parent.left == node) {
            node.parent.left = 0; // Left child
        } else {
            node.parent.right = 0; // Right child
        }
        balanceNode(node.parent);
        return true;
    }

    // Case 2: Node has one child
    if (node.left == 0 || node.right == 0) {
        Node storage child = node.left != 0 ? node.left : node.right;
        child.parent = node.parent;
        if (node.parent == 0) {
            root[orderType] = child; // Root node
        } else if (node.parent.left == node) {
            node.parent.left = child; // Left child
        } else {
            node.parent.right = child; // Right child
        }
        balanceNode(child);
        return true;
    }

    // Case 3: Node has two children
    Node storage successor = getSuccessor(node);
    node.price = successor.price;
    node.orders = successor.orders;
    deleteNode(successor.price, orderType, orderBook);
    return true;
}

function getSuccessor(Node storage node) internal view returns (Node storage) {
    if (node.right != 0) {
        // If the node has a right child, its successor is the leftmost node of its right subtree.
        node = node.right;
        while (node.left != 0) {
            node = node.left;
        }
        return node;
    } else {
        // If the node does not have a right child, its successor is the nearest ancestor whose left child is also an ancestor of the node.
        Node storage parent = node.parent;
        while (parent != 0 && node == parent.right) {
            node = parent;
            parent = node.parent;
        }
        return parent;
    }
}

function findMinPrice(Node memory node) internal view returns (uint256) {
    if (node.left != 0) {
        return findMinPrice(node.left);
    }
    return node.price;
}

function findMaxPrice(Node memory node) internal view returns (uint256) {
    if (node.right != 0) {
        return findMaxPrice(node.right);
    }
    return node.price;
}

function matchOrders(OrderBook storage orderBook) internal {
    Node storage sellNode = orderBook.rootSell;
    Node storage buyNode = orderBook.rootBuy;

    sellNode=findMinPrice(sellNode);
    buyNode=findMaxPrice(buyNode);

    // while (sellNode != 0 && buyNode != 0) {
        if (sellNode.key <= buyNode.key) {
            // If the sell price is less than or equal to the buy price, we have a match.
            Order storage sellOrder = sellNode.head;
            Order storage buyOrder = buyNode.head;
            while (sellOrder != 0 && buyOrder != 0) {
                if (sellOrder.quantity <= buyOrder.quantity) {
                    // If the sell order quantity is less than or equal to the buy order quantity, the sell order is fully matched.
                    // emit Trade(sellOrder.user, buyOrder.user, sellOrder.quantity, sellNode.key);
                    buyOrder.quantity -= sellOrder.quantity;
                    deleteOrder(sellOrder, orderBook);
                    sellOrder = sellNode.head;
                } else {
                    // Otherwise, the sell order is partially matched.
                    // emit Trade(sellOrder.user, buyOrder.user, buyOrder.quantity, sellNode.key);
                    sellOrder.quantity -= buyOrder.quantity;
                    deleteOrder(buyOrder, orderBook);
                    buyOrder = buyNode.head;
                }
            }
            if (sellNode.head == 0) {
                // If all sell orders at this price have been matched, remove the node from the sell tree.
                deleteNode(sellNode.key, false, orderBook);
            }
            sellNode = orderBook.rootSell;
        } else {
            // If the sell price is greater than the buy price, move to the next highest buy price.
            buyNode = getSuccessor(buyNode);
        }
    // }
}



}