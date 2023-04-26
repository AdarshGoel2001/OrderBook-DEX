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
  const [CID, setCID] = useState("");

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

  const gateway = `https://gateway.lighthouse.storage/ipfs/${CID}`;

  const submitHandler = () => {
    const upload = { name, aadhar, voterId, add, dob };
    const uploadObject = JSON.stringify(upload);
    const filename = name;
    const file = new File([uploadObject], filename, { type: "text/plain" });
    const url = URL.createObjectURL(file);

    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", "data.txt");
    link.click();
  };

  const uploadHandler = async (e) => {
    e.preventDefault();
    console.log(e);
    await uploadFileEncrypted(e).then(() => console.log("hello"));
  };

  const encryptionSignature = async () => {
    const messageRequested = (await lighthouse.getAuthMessage(address)).data
      .message;
    console.log(messageRequested);
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

  const handleSubmit = async (e) => {
    // e.preventDefault();
    // await uploadFileEncrypted(e).then(()=>console.log("hello"));
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
    // var tmppath = URL.createObjectURL(e.target.files[0]);
    // tmppath=tmppath.slice(5)
    console.log(sig);
    // console.log(tmppath);
    console.log(e.target.files[0]);
    const response = await lighthouse.uploadEncrypted(
      e,
      "b5f54b5b.a9704f1109444ea3a1831057a0585df4",
      sig.publicKey,
      sig.signedMessage
      // progressCallback
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
    setCID(response.data.Hash);
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
    console.log("Copied");
    const txt = copyText.textContent;
    navigator.clipboard.writeText(txt);
  };

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
            Download KYC file
          </button>
          <form action="" id="up" onSubmit={handleSubmit}>
            <input
              accept="text/*"
              id="files"
              form="up"
              class="submit"
              type="file"
              onChangeCapture={uploadFileEncrypted}
              placeholder="Upload encrypted to IPFS"
            />
            <button type="text" class="submit" onClick={uploadHandler}>
              Upload encrypted to IPFS
            </button>
          </form>

          {CID != "" && (
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
