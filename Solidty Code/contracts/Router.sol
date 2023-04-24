// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.8.0;

import "./interfaces/IGrid.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/Structs.sol";

contract Router {
    address grid;
    address admin;
    IGrid gridContract;
    address usdc;

    constructor(address _grid, address _usdc) {
        grid = _grid;
        admin = msg.sender;
        gridContract = IGrid(grid);
        usdc = _usdc;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }
    modifier onlyWhitelisted() {
        require(
            gridContract.whitelisted[msg.sender],
            "Only whitelisted users can call this function."
        );
        _;
    }

    function setAdmin(address _admin) public onlyAdmin {
        admin = _admin;
    }

    function getGrid() public view returns (address) {
        return grid;
    }

    function setGrid(address _grid) public {
        grid = _grid;
        gridContract = IGrid(grid);
    }

    function placeOrder(
        uint256 _shares,
        bool _isTaker,
        uint256 _price,
        bool _isBuy
    ) public payable returns (bytes32) {
        if (_isBuy) {
            if (_isTaker) {
                uint256 currentPrice = gridContract.getCurrentPrice(_isBuy);
                require(msg.value == _price, "Enter price as msg.value");
                require(_price >= (currentPrice * 14 * _shares) / 10);
                (bool success, ) = payable(grid).call{value: msg.value}("");
                require(success, "Transfer failed.");
            } else {
                uint256 amount = _shares * _price;
                require(msg.value >= amount, "Incorrect amount of ETH sent.");
                (bool success, ) = payable(grid).call{value: msg.value}("");
                require(success, "Transfer failed.");
            }
        }

        IGridStructs.Order memory order = IGridStructs.Order({
            id: 0,
            trader: msg.sender,
            quantity: _shares,
            isTaker: _isTaker,
            price: _price,
            isBuy: _isBuy,
            next: 0
        });
        bytes32 id = keccak256(
            abi.encodePacked(order.trader, order.quantity, order.price)
        );
        order.id = id;
        gridContract.addOrder(order, id);
        return id;
    }

    function deleteOrder(bytes32 _id) public {
        IGridStructs.Order memory order;
        order = gridContract.getOrderByID(_id);
        require(
            order.trader == msg.sender,
            "Only the owner of the order can delete it."
        );
        gridContract.deleteOrder(_id);
    }

    function getOrderDetails() public {}

    function getEXEbalance(address consumer) public view returns (uint256) {
        return gridContract.getExe(consumer);
    }

    function whitelist(address _user) public onlyAdmin {
        gridContract.whitelist(_user);
    }
}
