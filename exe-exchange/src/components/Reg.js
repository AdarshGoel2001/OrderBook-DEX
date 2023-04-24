import React, { useState } from "react";
import { createBrowserRouter } from "react-router-dom";
import "../App.css";
import Navbar from "./Navbar";
import "../Reg.css";
import { ethers } from "ethers";
import lighthouse from "@lighthouse-web3/sdk";
import { useAccount, useContract, useSigner } from "wagmi";
import { useProvider } from "wagmi";

export default function Reg() {
  const [name, setName] = useState("");

  const [aadhar, setAadhar] = useState(0);

  const [voterId, setVoterId] = useState("");

  const [add, setAddress] = useState("");
  const [dob, setDob] = useState(0);

  const { data: signer, isError, isLoading } = useSigner();
  const { address, isConnected } = useAccount();
  const provider = useProvider();

  const nameHandler = (e) => {
    setName(e.target.value);
  };
  const aadharHandler = (e) => {
    setAadhar(e.target.value);
  };
  const voterIDHandler = (e) => {
    setVoterId(e.target.value);
  };
  const addressHandler = (e) => {
    setAddress(e.target.value);
  };
  const dateHandler = (e) => {
    setDob(e.target.value);
  };
  const CID = "";

  const submitHandler = () => {
    const uploadObject = { name, aadhar, voterId, add, dob };
    uploadFileEncrypted(uploadObject);
  };
  const encryptionSignature = async () => {
    const messageRequested = (await lighthouse.getAuthMessage(address)).data
      .message;
    const signedMessage = await signer.signMessage(messageRequested);
    return {
      signedMessage: signedMessage,
      publicKey: address,
    };
  };

  const progressCallback = (progressData) => {
    let percentageDone =
      100 - (progressData?.total / progressData?.uploaded)?.toFixed(2);
    console.log(percentageDone);
  };

  /* Deploy file along with encryption */
  const uploadFileEncrypted = async (e) => {
    /*
       uploadEncrypted(e, accessToken, publicKey, signedMessage, uploadProgressCallback)
       - e: js event
       - accessToken: your API key
       - publicKey: wallets public key
       - signedMessage: message signed by the owner of publicKey
       - uploadProgressCallback: function to get progress (optional)
    */
    const sig = await encryptionSignature();
    const response = await lighthouse.uploadEncrypted(
      e,
      "YOUR_API_KEY",
      sig.publicKey,
      sig.signedMessage,
      progressCallback
    );
    console.log(response);
    /*
      output:
        data: {
          Name: "c04b017b6b9d1c189e15e6559aeb3ca8.png",
          Size: "318557",
          Hash: "QmcuuAtmYqbPYmPx3vhJvPDi61zMxYvJbfENMjBQjq7aM3"
        }
      Note: Hash in response is CID.
    */
    CID = response.data.Hash;
  };

  const signAuthMessage = async () => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const publicKey = (await signer.getAddress()).toLowerCase();
    const messageRequested = (await lighthouse.getAuthMessage(publicKey)).data
      .message;
    const signedMessage = await signer.signMessage(messageRequested);
    return { publicKey: publicKey, signedMessage: signedMessage };
  };

  const shareFile = async () => {
    // const cid = "QmVkbVeTGA7RHgvdt31H3ax1gW3pLi9JfW6i9hDdxTmcGK";

    // Then get auth message and sign
    // Note: the owner of the file should sign the message.
    const { publicKey, signedMessage } = await signAuthMessage();

    const publicKeyUserB = ["0xCD6701515a90C32f4d40D8C6b370A1FA51712794"];

    const res = await lighthouse.shareFile(
      publicKey,
      publicKeyUserB,
      CID,
      signedMessage
    );

    console.log(res);
    /*
      data: {
        cid: "QmTTa7rm2nMjz6wCj9pvRsadrCKyDXm5Vmd2YyBubCvGPi",
        shareTo: ["0x201Bcc3217E5AA8e803B41d1F5B6695fFEbD5CeD"],
        status: "Success"
      }
    */
    /*Visit: 
        https://files.lighthouse.storage/viewFile/<cid>  
      To view encrypted file
    */
  };

  return (
    <>
      <Navbar />
      <div className="mainDiv">
        <div class="form">
          <div class="title">Welcome</div>
          <div class="subtitle">Let's create your account!</div>
          <div class="input-container ic1">
            <input
              id="name"
              class="input"
              type="text"
              placeholder="Name"
              onChange={nameHandler}
            />
          </div>
          <div class="input-container ic2">
            <input
              id="aadharId"
              class="input"
              type="text"
              placeholder="aadharId"
              onChange={aadharHandler}
            />
          </div>
          <div class="input-container ic2">
            <input
              id="voterId"
              class="input"
              type="text"
              placeholder="voterId"
              onChange={voterIDHandler}
            />
          </div>
          <div class="input-container ic2">
            <input
              id="address"
              class="input"
              type="text"
              placeholder="address"
              onChange={addressHandler}
            />
          </div>
          <div class="input-container ic2">
            <input
              type="date"
              id="birthday"
              name="birthday"
              onChange={dateHandler}
            ></input>
          </div>

          <button type="text" class="submit" onClick={submitHandler}>
            submit
          </button>
        </div>
      </div>
    </>
  );
}
