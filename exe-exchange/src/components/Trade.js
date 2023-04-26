import { useState, useEffect } from "react";
import { ethers } from "ethers";
import "../App.css";
import Navbar from "./Navbar";
import {
  useAccount,
  useContract,
  useSigner,
  usePrepareContractWrite,
  useContractWrite,
} from "wagmi";
import { fetchBalance } from "@wagmi/core";

const gridABI = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_timeOracle",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    stateMutability: "payable",
    type: "fallback",
  },
  {
    inputs: [
      {
        internalType: "bytes32[]",
        name: "values",
        type: "bytes32[]",
      },
      {
        internalType: "bytes32",
        name: "value",
        type: "bytes32",
      },
    ],
    name: "IndexOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32[]",
        name: "values",
        type: "bytes32[]",
      },
      {
        internalType: "uint256",
        name: "i",
        type: "uint256",
      },
    ],
    name: "RemoveByIndex",
    outputs: [],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32[]",
        name: "values",
        type: "bytes32[]",
      },
      {
        internalType: "bytes32",
        name: "value",
        type: "bytes32",
      },
    ],
    name: "RemoveByValue",
    outputs: [],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "isBuy",
        type: "bool",
      },
    ],
    name: "_treeMaximum",
    outputs: [
      {
        internalType: "uint256",
        name: "price",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "isBuy",
        type: "bool",
      },
    ],
    name: "_treeMinimum",
    outputs: [
      {
        internalType: "uint256",
        name: "price",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: "bytes32",
            name: "id",
            type: "bytes32",
          },
          {
            internalType: "address",
            name: "trader",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "quantity",
            type: "uint256",
          },
          {
            internalType: "bool",
            name: "isTaker",
            type: "bool",
          },
          {
            internalType: "uint256",
            name: "price",
            type: "uint256",
          },
          {
            internalType: "bool",
            name: "isBuy",
            type: "bool",
          },
          {
            internalType: "bytes32",
            name: "next",
            type: "bytes32",
          },
        ],
        internalType: "struct IGridStructs.Order",
        name: "order",
        type: "tuple",
      },
      {
        internalType: "bytes32",
        name: "id",
        type: "bytes32",
      },
    ],
    name: "addOrder",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "trader",
        type: "address",
      },
    ],
    name: "checkIfWhitelisted",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "id",
        type: "bytes32",
      },
    ],
    name: "deleteOrder",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "getAvCurrentPrice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "isBuy",
        type: "bool",
      },
    ],
    name: "getCurrentPrice",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "getExe",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "getNextExe",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "id",
        type: "bytes32",
      },
    ],
    name: "getOrderByID",
    outputs: [
      {
        components: [
          {
            internalType: "bytes32",
            name: "id",
            type: "bytes32",
          },
          {
            internalType: "address",
            name: "trader",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "quantity",
            type: "uint256",
          },
          {
            internalType: "bool",
            name: "isTaker",
            type: "bool",
          },
          {
            internalType: "uint256",
            name: "price",
            type: "uint256",
          },
          {
            internalType: "bool",
            name: "isBuy",
            type: "bool",
          },
          {
            internalType: "bytes32",
            name: "next",
            type: "bytes32",
          },
        ],
        internalType: "struct IGridStructs.Order",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "trader",
        type: "address",
      },
    ],
    name: "getOrdersForAddress",
    outputs: [
      {
        internalType: "bytes32[]",
        name: "",
        type: "bytes32[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "isBuy",
        type: "bool",
      },
    ],
    name: "getRootTree",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "inOrderBuy",
    outputs: [
      {
        internalType: "uint256[2][10]",
        name: "",
        type: "uint256[2][10]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "root",
        type: "uint256",
      },
      {
        internalType: "uint256[2][10]",
        name: "priceArray",
        type: "uint256[2][10]",
      },
    ],
    name: "inOrderBuyHelper",
    outputs: [],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "inOrderSell",
    outputs: [
      {
        internalType: "uint256[2][10]",
        name: "",
        type: "uint256[2][10]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "root",
        type: "uint256",
      },
      {
        internalType: "uint256[2][10]",
        name: "priceArray",
        type: "uint256[2][10]",
      },
    ],
    name: "inOrderSellHelper",
    outputs: [],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    name: "orders",
    outputs: [
      {
        internalType: "bytes32",
        name: "id",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "trader",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "quantity",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "isTaker",
        type: "bool",
      },
      {
        internalType: "uint256",
        name: "price",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "isBuy",
        type: "bool",
      },
      {
        internalType: "bytes32",
        name: "next",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_makerFee",
        type: "uint256",
      },
    ],
    name: "setMakerFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_router",
        type: "address",
      },
    ],
    name: "setRouter",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_takerFee",
        type: "uint256",
      },
    ],
    name: "setTakerFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "updateAllEXEbalances",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_daystart",
        type: "uint256",
      },
    ],
    name: "updateTimeStamp",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "whitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
];

const routerABI = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_grid",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "_id",
        type: "bytes32",
      },
    ],
    name: "deleteOrder",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "consumer",
        type: "address",
      },
    ],
    name: "getEXEbalance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getGrid",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "consumer",
        type: "address",
      },
    ],
    name: "getNextExeBal",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getOrderDetails",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_shares",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_isTaker",
        type: "bool",
      },
      {
        internalType: "uint256",
        name: "_price",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_isBuy",
        type: "bool",
      },
    ],
    name: "placeOrder",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_admin",
        type: "address",
      },
    ],
    name: "setAdmin",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_grid",
        type: "address",
      },
    ],
    name: "setGrid",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
    ],
    name: "whitelist",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

export default function Trade() {
  var count = 1;
  const mappa = ["Sell", "Buy"];
  const [direction, setdirection] = useState(false);
  const [type, settype] = useState(true);
  const [amount, setamount] = useState(0);
  const [price, setprice] = useState(0);
  const [positions, setpositions] = useState([]);
  const [bal, setbal] = useState([]);
  const [currPrice, setCurrPrice] = useState(0);

  const { data: signer, isError } = useSigner();
  const { address, isConnected } = useAccount();

  // const getArgsforOrder = () => {
  // let ETHtoBeSent = 0;
  // if (direction) {
  //   if (type) {
  //     ETHtoBeSent = (currPrice * 15 * amount) / 10;
  //     setprice(ETHtoBeSent);
  //   } else {
  //     ETHtoBeSent = (price * 15 * amount) / 10;
  //   }
  // }
  //   return [
  //     amount,
  //     type,
  //     price,
  //     direction,
  //     {
  //       value: ethers.utils.parseEther(ETHtoBeSent.toString()),
  //     },
  //   ];
  // };

  // const { config } = usePrepareContractWrite({
  //   address: "0x70e0ba845a1a0f2da3359c97e0285013525ffc49",
  //   abi: routerABI,
  //   functionName: "placeOrder",
  //   args: getArgsforOrder(),
  // });

  // const { data, isLoading, isSuccess, write } = useContractWrite(config);

  // getPositions();
  // getPrice();
  // count++;

  useEffect(() => {
    getPositions();
    getBalances();
    getPrice();
  }, [isConnected]);

  const getPrice = async () => {
    const price = await gridContract
      .getAvCurrentPrice()
      .then(() => console.log("Price gotten"));
    setCurrPrice(price);
  };

  const getBalances = async (address) => {
    const exe = await routerContract
      .getEXEbalance(address)
      .then(() => console.log("Noice"));
    const nextexe = await routerContract
      .getNextExeBal(address)
      .then(() => console.log("gg"));
    const balance = await fetchBalance({
      address: address,
    });
    
    setbal([ exe, nextexe, balance ]);
    console.log("We are getting bals", bal.exe, bal.nextexe, bal.balance);
  };

  const getPositions = async () => {
    const orderIDArray = await gridContract
      .getOrdersForAddress(address)
      .then(() => console.log("boom bam"));
    console.log(orderIDArray);
    const orders = orderIDArray.map((id) => gridContract.getOrderByID(id));
    console.log("We are getting poss");
    setpositions(orders);
  };

  const gridContract = useContract({
    address: "0x99bba657f2bbc93c02d617f8ba121cb8fc104acf",
    abi: gridABI,
    signerOrProvider: signer,
  });
  const routerContract = useContract({
    address: "0x8f86403a4de0bb5791fa46b8e795c547942fe4cf",
    abi: routerABI,
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

  const deleteOrder = async (id) => {
    const del = await routerContract
      .deleteOrder(id)
      .then(() => console.log("Order deleted"));
    setpositions((pos) => pos.filter((pos) => pos.id !== id));
  };

  const handleSwap = async () => {
    console.log(process.env.REACT_APP_LIGHTHOUSE_API);

    const obj = {
      amount: amount,
      type: type,
      price: price,
      direction: direction,
    };
    console.log(obj);
    let ETHtoBeSent = 0;
    if (direction) {
      if (type) {
        ETHtoBeSent = (currPrice * 15 * amount) / 10;
        setprice(ETHtoBeSent);
      } else {
        ETHtoBeSent = (price * 15 * amount) / 10;
      }
    }
    const swap = await routerContract
      .placeOrder(amount, type, price, direction, {
        value: ethers.utils.parseEther(ETHtoBeSent.toString()),
      })
      .then(() => console.log("hello"));
    // swap.wait();
    getBalances(address);
    getBalances();
    // write?.();
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
              onClick={() => handletype(false)}
              className={"selector selectorLeft" + (!type ? " selected" : "")}
            >
              Maker (Limit)
            </button>
            <button
              // onChange={settype(false)}
              onClick={() => handletype(true)}
              className={"selector selectorRight" + (type ? " selected" : "")}
            >
              Taker (Market)
            </button>
          </div>
          <p style={{ margin: "20px 0" }}>
            Current Price :${currPrice || 0}
            {/* <span style={{ color: "#5fbf80", fontWeight: 600 }}>$30.00</span>{" "} */}
          </p>
          <p>Enter Quantity</p>
          <input
            type="number"
            name="amount"
            className="input inputAmount"
            placeholder="Enter Amount"
            min="1"
            value={amount}
            onChange={(e) => setamount(e.target.value)}
          />{" "}
          <p>Enter Price</p>
          {!type && (
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
              <span className="infoItem">{item.mappa[direction]}</span>
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
