import React, { useState, useEffect } from "react";
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
  const [submit, setsubmit] =useState(false);

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
  var CID = "";
  const gateway = `https://gateway.lighthouse.storage/ipfs/${CID}`;

  const submitHandler = () => {
    const uploadObject = { name, aadhar, voterId, add, dob };
    setsubmit(true);
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
      process.env.LIGHTHOUSE_API,
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
    const publicKey = address.toLowerCase();
    const messageRequested = (await lighthouse.getAuthMessage(publicKey)).data
      .message;
    const signedMessage = await signer.signMessage(messageRequested);
    return { publicKey: publicKey, signedMessage: signedMessage };
  };


  const copy2 = () => {
    var copyText = document.querySelector("#text2");
    // copyText.select();
    console.log("Copied")
    const txt = copyText.textContent;
    navigator.clipboard.writeText(txt);
  }

    const copy1 = () => {
      var copyText = document.querySelector("#text1");
      // copyText.select();
      console.log("Copied");
      const txt = copyText.textContent;
      navigator.clipboard.writeText(txt);
    };

  const shareFile = async () => {
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
              required
            />
          </div>
          <div class="input-container ic2">
            <input
              id="aadharId"
              class="input"
              type="text"
              placeholder="aadharId"
              onChange={aadharHandler}
              required
            />
          </div>
          <div class="input-container ic2">
            <input
              id="voterId"
              class="input"
              type="text"
              placeholder="voterId"
              onChange={voterIDHandler}
              required
            />
          </div>
          <div class="input-container ic2">
            <input
              id="address"
              class="input"
              type="text"
              placeholder="address"
              onChange={addressHandler}
              required
            />
          </div>
          <div class="input-container ic2">
            <input
              type="date"
              id="birthday"
              name="birthday"
              onChange={dateHandler}
              required
            ></input>
          </div>
          <button type="text" class="submit" onClick={submitHandler}>
            submit
          </button>
          {submit && (
            <>
              <div class="subtitle" id="text1">
                {CID}
              </div>
              <button onClick={copy1} class="copybtn">
                Copy CID
              </button>
              <div class="subtitle" id="text2">
                {gateway}
              </div>
              <button onClick={copy2} class="copybtn">
                Copy gateway
              </button>
            </>
          )}
        </div>
      </div>
    </>
  );
}
