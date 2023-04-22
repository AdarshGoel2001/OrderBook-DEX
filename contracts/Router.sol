pragma solidity >=0.8.0;

import "./interfaces/IGrid.sol";

contract Router {
    address grid;
    address admin;
    IGrid gridContract;

    struct orderDetails {
        ;
    }

    constructor(address _grid) {
        grid = _grid;
        admin = msg.sender;
        gridContract = IGrid(grid);
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

    function placeOrder() public {}

    function deleteOrder() public {}

    function updateOrder() public {}

    function getOrderDetails() public {}

    function getEXEbalance(address consumer) public returns (uint256) {
        return gridContract.getEXEbalance(consumer);
    }
    // CREATE READ UPDATE DELETE
}
