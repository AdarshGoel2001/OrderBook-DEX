import { useState, useEffect } from "react";
import { ethers } from "ethers";
import "../App.css";
import Navbar from "./Navbar";
import { useAccount, useContract, useSigner } from "wagmi";
import { fetchBalance } from "@wagmi/core";


export default function Trade() {
  var count=1;
  const map=["Sell", "Buy"]
  const [direction, setdirection] = useState(false);
  const [type, settype] = useState(true);
  const [amount, setamount] = useState(0);
  const [price, setprice] = useState(0);
  const [positions, setpositions] = useState([]);
  const [bal, setbal]=useState({});
  const [currPrice, setCurrPrice]=useState(0);

  const { data: signer, isError, isLoading } = useSigner();
  const { address, isConnected } = useAccount();
  

  useEffect(() => {
    getPositions();
    getBalances();
    getPrice();
  }, [isConnected]);

  const getPrice = async () =>{
    const price=await gridContract.getAvCurrentPrice().then(()=>console.log("Price gotten"));
    setCurrPrice(price);
  }

  const getBalances = async (address) => {
    const exe=await routerContract.getExebalance(address).then(()=>console.log("Noice"));
    const nextexe=await routerContract.getNextExeBal(address).then(()=>console.log("gg"));
    const balance = await fetchBalance({
      address: address,
    });
    console.log("We are getting bals");
    setbal({exe:exe, nextexe:nextexe, balance:balance});
  }

  const getPositions = async () => {
    const orderIDArray = await gridContract
      .getOrdersForAddress(address)
      .then(() => console.log("boom bam"));
    const orders = orderIDArray.map((id) => gridContract.getOrderByID(id));
    console.log("We are getting poss")
    setpositions(orders);
  };

  const gridContract = useContract({
    address: "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e",
    signerOrProvider: signer,
  });
  const routerContract = useContract({
    address: "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e",
    signerOrProvider: signer,
  });

  const handledirection = () => {
    setdirection((value) => !value);
  };
  const handletype = (e) => {
    settype(e);
  };

  // const handleAmount = (e) => {
  //   setamount(e);
  //   console.log(amount);
  // };
  // const handlePrice = (e) => {
  //   setprice(e);
  //   console.log(price);
  // };

  const deleteOrder = async (id) =>{
    const del= await routerContract.deleteOrder(id).then(()=>console.log("Order deleted"));
    setpositions((pos) => pos.filter((pos)=>pos.id!==id));
  }

  const handleSwap = async () => {

    console.log(process.env.REACT_APP_LIGHTHOUSE_API)
    
    const obj={amount:amount, type:type, price:price, direction:direction}
    console.log(obj);
    const swap=await routerContract.placeOrder(amount, type, price, direction).then(()=>getPositions());
    getPositions();
    getPrice();
    count++;
  };

  return (
    <>
      <Navbar />
      <div className="trade">
        <div className="tradeBlock">
          <h2 className="heading2">Trade</h2>
          <div className="selectorBlock">
            <button
              // onChange={setdirection(true)}
              onClick={handledirection}
              className={
                "selector selectorLeft" + (direction ? " selected" : "")
              }
            >
              Buy EXE from ETH
            </button>
            <button
              // onChange={setdirection(false)}
              onClick={handledirection}
              className={
                "selector selectorRight" + (!direction ? " selected" : "")
              }
            >
              Sell EXE for ETH
            </button>
          </div>
          <div className="selectorBlock">
            <button
              // onChange={settype(true)}
              onClick={()=>handletype(false)}
              className={"selector selectorLeft" + (!type ? " selected" : "")}
            >
              Maker (Limit)
            </button>
            <button
              // onChange={settype(false)}
              onClick={()=>handletype(true)}
              className={"selector selectorRight" + (type ? " selected" : "")}
            >
              Taker (Market)
            </button>
          </div>
          <p style={{ margin: "20px 0" }}>
            Current Price :${currPrice || 0}
            {/* <span style={{ color: "#5fbf80", fontWeight: 600 }}>$30.00</span>{" "} */}
          </p>
          <input
            type="number"
            name="amount"
            className="input inputAmount"
            placeholder="Enter Amount"
            min="1"
            value={amount}
            onChange={(e) => setamount(e.target.value)}
          />
          {type && (
            <input
              type="number"
              name="price"
              className="input inputPrice"
              placeholder="Enter Price"
              min={"1"}
              value={price}
              onChange={(e) => setprice(e.target.value)}
            />
          )}
          {!type && (
            <p style={{ margin: "20px 0" }}>
              Output :{direction ? <>$</> : <>EXE</>} {currPrice * amount}
              {/* <span style={{ color: "#5fbf80", fontWeight: 600 }}>$30.00</span> */}
            </p>
          )}
          <button className="metamask-connect heroButton" onClick={handleSwap}>
            Swap
          </button>
        </div>
        <div className="tradeBlock tradeBlock2">
          <h2 className="heading2">Your Positions</h2>
          {positions.map((item) => (
            <div key={item.id} className="infoBlock">
              <span className="infoItem">{item.map[direction]}</span>
              <span className="infoItem">Size: {item.quantity}</span>
              <span className="infoItem">Price: {item.price}</span>
              <button
                className="endButton"
                onClick={() => deleteOrder(item.key)}
              >
                end
              </button>
            </div>
          ))}
        </div>
        <div className="tradeBlock3">
          <div className="selectorBlock3">
            <h2 className="heading2">Your Balances</h2>
            <h3 className="heading3">
              EXE <span className="spacing">{bal.exe || 0}</span>
            </h3>
            <h3 className="heading3">
              Tommorow's EXE <span>{bal.nextexe || 0}</span>
            </h3>
            <h3 className="heading3">
              Token <span>{bal.balance || 0}</span>
            </h3>
          </div>
        </div>
      </div>
    </>
  );
}
