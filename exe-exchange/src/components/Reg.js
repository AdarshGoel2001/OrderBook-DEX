import React, { useState } from "react";
import { createBrowserRouter } from "react-router-dom";
import "../App.css";
import Navbar from "./Navbar";
import "../Reg.css";

export default function Reg() {
  const [name, setName] = useState("");

  const [aadhar, setAadhar] = useState(0);

  const [voterId, setVoterId] = useState("");

  const [address, setAddress] = useState("");
  const [dob, setDob] = useState(0);

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

  const submitHandler = () => {
    const uploadObject = { name, aadhar, voterId, address, dob };
    console.log(uploadObject);
    uploadToIPFS(uploadObject);
  };

  const uploadToIPFS = (uploadObject) => {};

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
