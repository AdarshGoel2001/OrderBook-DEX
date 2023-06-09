import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";
import { RouterProvider } from "react-router-dom";
import { router } from "./Router";
import {
  EthereumClient,
  w3mConnectors,
  w3mProvider,
} from "@web3modal/ethereum";
import { Web3Modal } from "@web3modal/react";
import { configureChains, createClient, WagmiConfig } from "wagmi";
import { polygon, polygonMumbai, hardhat } from "wagmi/chains";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";

const chains = [polygon, polygonMumbai];
// const chains = [hardhat];
const projectId = process.env.REACT_APP_W3M_PROJECTID;

const { provider } = configureChains(chains, [w3mProvider({ projectId })]);

// const { provider } = configureChains(chains, [
//   jsonRpcProvider({
//     rpc: (chain) => ({
//       http: `http://127.0.0.1:8545/`,
//     }),
//   }),
// ]);

const wagmiClient = createClient({
  autoConnect: true,
  connectors: w3mConnectors({ projectId, version: 1, chains }),
  provider,
});
const ethereumClient = new EthereumClient(wagmiClient, chains);

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    {" "}
    <WagmiConfig client={wagmiClient}>
      <RouterProvider router={router}>
        <App />
      </RouterProvider>{" "}
    </WagmiConfig>
    <Web3Modal projectId={projectId} ethereumClient={ethereumClient} />
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
