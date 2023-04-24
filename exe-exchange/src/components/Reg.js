import React from "react";
import { createBrowserRouter } from "react-router-dom";
import "../App.css";
import Navbar from "./Navbar";
import "../Reg.css";

export default function Reg({reg}, {setreg}) {


  return (
    <>
      <Navbar />
      <div className="mainDiv">
        <div class="form">
          <div class="title">Welcome</div>
          <div class="subtitle">Let's create your account!</div>
          <div class="input-container ic1">
            <input
              id="firstname"
              class="input"
              type="text"
              placeholder="First name"
            />
            {/* <div class="cut"></div> */}
            {/* <label for="firstname" class="placeholder">
                First name
              </label> */}
          </div>
          <div class="input-container ic2">
            <input
              id="lastname"
              class="input"
              type="text"
              placeholder="Last name"
            />
            {/* <div class="cut"></div> */}
            {/* <label for="lastname" class="placeholder">
                Last name
              </label> */}
          </div>
          <div class="input-container ic2">
            <input id="email" class="input" type="text" placeholder="email" />
            {/* <div class="cut cut-short"></div> */}
            {/* <label for="email" class="placeholder">
                Email
              </label> */}
          </div>
          <button type="text" class="submit">
            submit
          </button>
        </div>
      </div>
    </>
  );
}
