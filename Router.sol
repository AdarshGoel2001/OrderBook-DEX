pragma solidity >=0.8.0;

contract Router {
    address grid;
    address admin;

    struct orderDetails{}
    

    constructor(address _grid) {
        grid = _grid;
        admin = msg.sender;
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
    }

    function placeOrder(){

    }

    ̀

    function deleteOrder(){

    }

    function updateOrder(){

    }

    function getOrderDetails(){

    }
    // CREATE READ UPDATE DELETE
}
