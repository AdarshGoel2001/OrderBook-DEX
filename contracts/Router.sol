pragma solidity >=0.8.0;

import "./interfaces/IGrid.sol";
import "./interfaces/IERC20.sol";
import "contracts/interfaces/Structs.sol";

contract Router {
    address grid;
    address admin;
    IGrid gridContract;
    address usdc;

    struct orderDetails {
        uint256 price;
        uint256 amount;
        bool isBuy;
    }

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
    ) public {
        if (_isTaker) {
            uint256 currentPrice = gridContract.getCurrentPrice();
            _transferInUSDC(msg.sender, currentPrice * _shares);
        } else {
            uint256 amount = _shares * _price;
            _transferInUSDC(msg.sender, amount);
        }

        Order memory order = Order({
            trader: msg.sender,
            quantity: _shares,
            isTaker: _isTaker,
            price: _price,
            isBuy: _isBuy,
            next: 0
        });
        bytes32 id = sha3(order);
        gridContract.addOrder(order, id);
    }

    function deleteOrder() public {}

    function updateOrder() public {}

    function getOrderDetails() public {}

    function getEXEbalance(address consumer) public returns (uint256) {
        return gridContract.getEXEbalance(consumer);
    }

    function _transferInUSDC(address _user, uint256 _amount) internal {
        IERC20(usdc).transferfrom(_user, grid, _amount);
    }
}
