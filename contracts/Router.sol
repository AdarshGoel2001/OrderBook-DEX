pragma solidity >=0.8.0;

import "./interfaces/IGrid.sol";
import "./interfaces/IERC20.sol";

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
        uint256 shares,
        uint256 price,
        bool isTaker,
        bool isBuy
    ) public {
        if (isTaker) {
            uint256 currentPrice = gridContract.getCurrentPrice();
            _transferInUSDC(msg.sender, currentPrice * shares);
        } else {
            uint256 amount = shares * price;
            _transferInUSDC(msg.sender, amount);
        }
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
