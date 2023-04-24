import React from "react";
import { createBrowserRouter } from "react-router-dom";
import "../App.css";
import Navbar from "./Navbar";
import "../Reg.css";


export default function Reg() {


  return (
    <>
      <Navbar />
      <div className="mainDiv">
        <div class="form">
          <div class="title">Welcome</div>
          <div class="subtitle">Let's create your account!</div>
          <div class="input-container ic1">
            <input id="name" class="input" type="text" placeholder="Name" />
          </div>
          <div class="input-container ic2">
            <input
              id="aadharId"
              class="input"
              type="text"
              placeholder="aadharId"
            />
          </div>
          <div class="input-container ic2">
            <input
              id="voterId"
              class="input"
              type="text"
              placeholder="voterId"
            />
          </div>
          <div class="input-container ic2">
            <input
              id="address"
              class="input"
              type="text"
              placeholder="address"
            />
          </div>
          <div class="input-container ic2">
            <input type="date" id="birthday" name="birthday"></input>
          </div>

          <button type="text" class="submit">
            submit
          </button>
        </div>
      </div>
    </>
  );
}
