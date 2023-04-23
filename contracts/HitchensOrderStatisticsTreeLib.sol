// pragma solidity ^0.8.0;
// import "./interfaces/Structs.sol";

// /* 
// Hitchens Order Statistics Tree v0.99

// A Solidity Red-Black Tree library to store and maintain a sorted data
// structure in a Red-Black binary search tree, with O(log 2n) insert, remove
// and search time (and gas, approximately)

// https://github.com/rob-Hitchens/OrderStatisticsTree

// Copyright (c) Rob Hitchens. the MIT License

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Significant portions from BokkyPooBahsRedBlackTreeLibrary, 
// https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary

// THIS SOFTWARE IS NOT TESTED OR AUDITED. DO NOT USE FOR PRODUCTION.
// */

// // import "./Owned.sol";

// library HitchensOrderStatisticsTreeLib {
//     uint private constant EMPTY = 0;

//     // function _first(IGridStructs.Tree memory self) internal view returns (uint _value) {
//     //     _value = self.root;
//     //     if (_value == EMPTY) return 0;
//     //     while (self.nodes[_value].left != EMPTY) {
//     //         _value = self.nodes[_value].left;
//     //     }
//     // }

//     // function _last(IGridStructs.Tree storage self) internal view returns (uint _value) {
//     //     _value = self.root;
//     //     if (_value == EMPTY) return 0;
//     //     while (self.nodes[_value].right != EMPTY) {
//     //         _value = self.nodes[_value].right;
//     //     }
//     // }

//     // function _next(
//     //     Tree storage self,
//     //     uint value
//     // ) internal view returns (uint _cursor) {
//     //     require(
//     //         value != EMPTY,
//     //         "OrderStatisticsTree(401) - Starting value cannot be zero"
//     //     );
//     //     if (self.nodes[value].right != EMPTY) {
//     //         _cursor = _treeMinimum(self, self.nodes[value].right);
//     //     } else {
//     //         _cursor = self.nodes[value].parent;
//     //         while (_cursor != EMPTY && value == self.nodes[_cursor].right) {
//     //             value = _cursor;
//     //             _cursor = self.nodes[_cursor].parent;
//     //         }
//     //     }
//     // }

//     // function _prev(
//     //     Tree storage self,
//     //     uint value
//     // ) internal view returns (uint _cursor) {
//     //     require(
//     //         value != EMPTY,
//     //         "OrderStatisticsTree(402) - Starting value cannot be zero"
//     //     );
//     //     if (self.nodes[value].left != EMPTY) {
//     //         _cursor = _treeMaximum(self, self.nodes[value].left);
//     //     } else {
//     //         _cursor = self.nodes[value].parent;
//     //         while (_cursor != EMPTY && value == self.nodes[_cursor].left) {
//     //             value = _cursor;
//     //             _cursor = self.nodes[_cursor].parent;
//     //         }
//     //     }
//     // }

//     function _exists(
//         IGridStructs.Tree storage self,
//         uint value
//     ) internal view returns (bool exists) {
//         if (value == EMPTY) return false;
//         if (value == self.root) return true;
//         if (self.nodes[value].parent != EMPTY) return true;
//         return false;
//     }

//     function _keyExists(
//         IGridStructs.Tree storage self,
//         bytes32 key,
//         uint value
//     ) internal view returns (bool exists) {
//         if (!_exists(self, value)) return false;
//         return self.nodes[value].keys[self.nodes[value].keyMap[key]] == key;
//     }

//     function _getNode(
//         IGridStructs.Tree storage self,
//         uint value
//     ) internal view returns (IGridStructs.LL memory ll) {
//         require(
//             _exists(self, value),
//             "OrderStatisticsTree(403) - Value does not exist."
//         );
//         IGridStructs.Node memory gn = self.nodes[value];
//         return gn.ll;
//     }

//     function _getNodeCount(
//         IGridStructs.Tree storage self,
//         uint value
//     ) internal view returns (uint count) {
//         IGridStructs.Node memory gn = self.nodes[value];
//         return gn.keys.length + gn.count;
//     }

//     function _valueKeyAtIndex(
//         IGridStructs.Tree storage self,
//         uint value,
//         uint index
//     ) internal view returns (bytes32 _key) {
//         require(
//             _exists(self, value),
//             "OrderStatisticsTree(404) - Value does not exist."
//         );
//         return self.nodes[value].keys[index];
//     }

//     function _count(
//         IGridStructs.Tree storage self
//     ) internal view returns (uint count) {
//         return _getNodeCount(self, self.root);
//     }

//     function _insert(
//         IGridStructs.Tree storage self,
//         bytes32 key,
//         uint value
//     ) internal {
//         require(
//             value != EMPTY,
//             "OrderStatisticsTree(405) - Value to insert cannot be zero"
//         );
//         require(
//             !_keyExists(self, key, value),
//             "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again."
//         );
//         uint cursor;
//         uint probe = self.root;
//         while (probe != EMPTY) {
//             cursor = probe;
//             if (value < probe) {
//                 probe = self.nodes[probe].left;
//             } else if (value > probe) {
//                 probe = self.nodes[probe].right;
//             } else if (value == probe) {
//                 // self.nodes[probe].keyMap[key] =
//                 //     self.nodes[probe].keys.push(key) -
//                 //     uint(1);
//                 return;
//             }
//             self.nodes[cursor].count++;
//         }
//         IGridStructs.Node storage nValue = self.nodes[value];
//         // nValue.ll = ;
//         nValue.parent = cursor;
//         nValue.left = EMPTY;
//         nValue.right = EMPTY;
//         nValue.red = true;
//         // nValue.keyMap[key] = nValue.keys.push(key) - uint(1);
//         if (cursor == EMPTY) {
//             self.root = value;
//         } else if (value < cursor) {
//             self.nodes[cursor].left = value;
//         } else {
//             self.nodes[cursor].right = value;
//         }
//         _insertFixup(self, value);
//     }

//     function _remove(
//         IGridStructs.Tree storage self,
//         bytes32 key,
//         uint value
//     ) internal {
//         require(
//             value != EMPTY,
//             "OrderStatisticsTree(407) - Value to delete cannot be zero"
//         );
//         require(
//             _keyExists(self, key, value),
//             "OrderStatisticsTree(408) - Value to delete does not exist."
//         );
//         IGridStructs.Node storage nValue = self.nodes[value];
//         uint rowToDelete = nValue.keyMap[key];
//         nValue.keys[rowToDelete] = nValue.keys[nValue.keys.length - uint(1)];
//         nValue.keyMap[key] = rowToDelete;
//         // nValue.keys.length--;
//         uint probe;
//         uint cursor;
//         if (nValue.keys.length == 0) {
//             if (
//                 self.nodes[value].left == EMPTY ||
//                 self.nodes[value].right == EMPTY
//             ) {
//                 cursor = value;
//             } else {
//                 cursor = self.nodes[value].right;
//                 while (self.nodes[cursor].left != EMPTY) {
//                     cursor = self.nodes[cursor].left;
//                 }
//             }
//             if (self.nodes[cursor].left != EMPTY) {
//                 probe = self.nodes[cursor].left;
//             } else {
//                 probe = self.nodes[cursor].right;
//             }
//             uint cursorParent = self.nodes[cursor].parent;
//             self.nodes[probe].parent = cursorParent;
//             if (cursorParent != EMPTY) {
//                 if (cursor == self.nodes[cursorParent].left) {
//                     self.nodes[cursorParent].left = probe;
//                 } else {
//                     self.nodes[cursorParent].right = probe;
//                 }
//             } else {
//                 self.root = probe;
//             }
//             bool doFixup = !self.nodes[cursor].red;
//             if (cursor != value) {
//                 _replaceParent(self, cursor, value);
//                 self.nodes[cursor].left = self.nodes[value].left;
//                 self.nodes[self.nodes[cursor].left].parent = cursor;
//                 self.nodes[cursor].right = self.nodes[value].right;
//                 self.nodes[self.nodes[cursor].right].parent = cursor;
//                 self.nodes[cursor].red = self.nodes[value].red;
//                 (cursor, value) = (value, cursor);
//                 _fixCountRecurse(self, value);
//             }
//             if (doFixup) {
//                 _removeFixup(self, probe);
//             }
//             _fixCountRecurse(self, cursorParent);
//             delete self.nodes[cursor];
//         }
//     }

//     function _fixCountRecurse(
//         IGridStructs.Tree storage self,
//         uint value
//     ) private {
//         while (value != EMPTY) {
//             self.nodes[value].count =
//                 _getNodeCount(self, self.nodes[value].left) +
//                 _getNodeCount(self, self.nodes[value].right);
//             value = self.nodes[value].parent;
//         }
//     }

//     function _treeMinimum(
//         IGridStructs.Tree storage self,
//         uint value
//     ) public view returns (IGridStructs.Node memory) {
//         IGridStructs.Node memory cur = self.nodes[value];
//         while (self.nodes[value].left != EMPTY) {
//             value = self.nodes[value].left;
//             cur = self.nodes[value];
//         }
//         return cur;
//     }

//     function _treeMaximum(
//         IGridStructs.Tree storage self,
//         uint value
//     ) public view returns (IGridStructs.Node memory) {
//         IGridStructs.Node memory cur = self.nodes[value];
//         while (self.nodes[value].right != EMPTY) {
//             value = self.nodes[value].right;
//             cur = self.nodes[value];
//         }
//         return cur;
//     }

//     function _rotateLeft(IGridStructs.Tree storage self, uint value) private {
//         uint cursor = self.nodes[value].right;
//         uint parent = self.nodes[value].parent;
//         uint cursorLeft = self.nodes[cursor].left;
//         self.nodes[value].right = cursorLeft;
//         if (cursorLeft != EMPTY) {
//             self.nodes[cursorLeft].parent = value;
//         }
//         self.nodes[cursor].parent = parent;
//         if (parent == EMPTY) {
//             self.root = cursor;
//         } else if (value == self.nodes[parent].left) {
//             self.nodes[parent].left = cursor;
//         } else {
//             self.nodes[parent].right = cursor;
//         }
//         self.nodes[cursor].left = value;
//         self.nodes[value].parent = cursor;
//         self.nodes[value].count =
//             _getNodeCount(self, self.nodes[value].left) +
//             _getNodeCount(self, self.nodes[value].right);
//         self.nodes[cursor].count =
//             _getNodeCount(self, self.nodes[cursor].left) +
//             _getNodeCount(self, self.nodes[cursor].right);
//     }

//     function _rotateRight(IGridStructs.Tree storage self, uint value) private {
//         uint cursor = self.nodes[value].left;
//         uint parent = self.nodes[value].parent;
//         uint cursorRight = self.nodes[cursor].right;
//         self.nodes[value].left = cursorRight;
//         if (cursorRight != EMPTY) {
//             self.nodes[cursorRight].parent = value;
//         }
//         self.nodes[cursor].parent = parent;
//         if (parent == EMPTY) {
//             self.root = cursor;
//         } else if (value == self.nodes[parent].right) {
//             self.nodes[parent].right = cursor;
//         } else {
//             self.nodes[parent].left = cursor;
//         }
//         self.nodes[cursor].right = value;
//         self.nodes[value].parent = cursor;
//         self.nodes[value].count =
//             _getNodeCount(self, self.nodes[value].left) +
//             _getNodeCount(self, self.nodes[value].right);
//         self.nodes[cursor].count =
//             _getNodeCount(self, self.nodes[cursor].left) +
//             _getNodeCount(self, self.nodes[cursor].right);
//     }

//     function _insertFixup(
//         IGridStructs.Tree storage self,
//         uint value
//     ) internal returns (uint) {
//         uint cursor;
//         while (value != self.root && self.nodes[self.nodes[value].parent].red) {
//             uint valueParent = self.nodes[value].parent;
//             if (
//                 valueParent == self.nodes[self.nodes[valueParent].parent].left
//             ) {
//                 cursor = self.nodes[self.nodes[valueParent].parent].right;
//                 if (self.nodes[cursor].red) {
//                     self.nodes[valueParent].red = false;
//                     self.nodes[cursor].red = false;
//                     self.nodes[self.nodes[valueParent].parent].red = true;
//                     value = self.nodes[valueParent].parent;
//                 } else {
//                     if (value == self.nodes[valueParent].right) {
//                         value = valueParent;
//                         _rotateLeft(self, value);
//                     }
//                     valueParent = self.nodes[value].parent;
//                     self.nodes[valueParent].red = false;
//                     self.nodes[self.nodes[valueParent].parent].red = true;
//                     _rotateRight(self, self.nodes[valueParent].parent);
//                 }
//             } else {
//                 cursor = self.nodes[self.nodes[valueParent].parent].left;
//                 if (self.nodes[cursor].red) {
//                     self.nodes[valueParent].red = false;
//                     self.nodes[cursor].red = false;
//                     self.nodes[self.nodes[valueParent].parent].red = true;
//                     value = self.nodes[valueParent].parent;
//                 } else {
//                     if (value == self.nodes[valueParent].left) {
//                         value = valueParent;
//                         _rotateRight(self, value);
//                     }
//                     valueParent = self.nodes[value].parent;
//                     self.nodes[valueParent].red = false;
//                     self.nodes[self.nodes[valueParent].parent].red = true;
//                     _rotateLeft(self, self.nodes[valueParent].parent);
//                 }
//             }
//         }
//         self.nodes[self.root].red = false;
//         return self.root;
//     }

//     function _replaceParent(
//         IGridStructs.Tree storage self,
//         uint a,
//         uint b
//     ) private {
//         uint bParent = self.nodes[b].parent;
//         self.nodes[a].parent = bParent;
//         if (bParent == EMPTY) {
//             self.root = a;
//         } else {
//             if (b == self.nodes[bParent].left) {
//                 self.nodes[bParent].left = a;
//             } else {
//                 self.nodes[bParent].right = a;
//             }
//         }
//     }

//     function _removeFixup(
//         IGridStructs.Tree storage self,
//         uint value
//     ) internal returns (uint) {
//         uint cursor;
//         while (value != self.root && !self.nodes[value].red) {
//             uint valueParent = self.nodes[value].parent;
//             if (value == self.nodes[valueParent].left) {
//                 cursor = self.nodes[valueParent].right;
//                 if (self.nodes[cursor].red) {
//                     self.nodes[cursor].red = false;
//                     self.nodes[valueParent].red = true;
//                     _rotateLeft(self, valueParent);
//                     cursor = self.nodes[valueParent].right;
//                 }
//                 if (
//                     !self.nodes[self.nodes[cursor].left].red &&
//                     !self.nodes[self.nodes[cursor].right].red
//                 ) {
//                     self.nodes[cursor].red = true;
//                     value = valueParent;
//                 } else {
//                     if (!self.nodes[self.nodes[cursor].right].red) {
//                         self.nodes[self.nodes[cursor].left].red = false;
//                         self.nodes[cursor].red = true;
//                         _rotateRight(self, cursor);
//                         cursor = self.nodes[valueParent].right;
//                     }
//                     self.nodes[cursor].red = self.nodes[valueParent].red;
//                     self.nodes[valueParent].red = false;
//                     self.nodes[self.nodes[cursor].right].red = false;
//                     _rotateLeft(self, valueParent);
//                     value = self.root;
//                 }
//             } else {
//                 cursor = self.nodes[valueParent].left;
//                 if (self.nodes[cursor].red) {
//                     self.nodes[cursor].red = false;
//                     self.nodes[valueParent].red = true;
//                     _rotateRight(self, valueParent);
//                     cursor = self.nodes[valueParent].left;
//                 }
//                 if (
//                     !self.nodes[self.nodes[cursor].right].red &&
//                     !self.nodes[self.nodes[cursor].left].red
//                 ) {
//                     self.nodes[cursor].red = true;
//                     value = valueParent;
//                 } else {
//                     if (!self.nodes[self.nodes[cursor].left].red) {
//                         self.nodes[self.nodes[cursor].right].red = false;
//                         self.nodes[cursor].red = true;
//                         _rotateLeft(self, cursor);
//                         cursor = self.nodes[valueParent].left;
//                     }
//                     self.nodes[cursor].red = self.nodes[valueParent].red;
//                     self.nodes[valueParent].red = false;
//                     self.nodes[self.nodes[cursor].left].red = false;
//                     _rotateRight(self, valueParent);
//                     value = self.root;
//                 }
//             }
//         }
//         self.nodes[value].red = false;

//         return self.root;
//     }
// }
