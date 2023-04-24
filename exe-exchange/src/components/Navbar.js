import React from "react";
import logo from "./Logo.svg";
import icon from "../metamask-icon.png";
import { Link } from "react-router-dom";
import { Web3Button } from "@web3modal/react";

export default function Navbar() {
  return (
    <nav className="navbar">
      <div className="left-section">
        <Link to="/">
          <span className="logo-section">
            <img className="company-logo" src={logo} alt="company Logo" />
            <p className="company-name">EXE Trade</p>
          </span>
        </Link>
        <ul className="nav-links">
          <Link to="/trade">
            <li className="nav-link">
              <span className="shadow">Trade</span>
            </li>
          </Link>
          <li className="nav-link">
            <span className="shadow">About</span>
          </li>
          <li className="nav-link">
            <span className="shadow">Contact</span>
          </li>
        </ul>
      </div>
      <div className="right-section">
        <Web3Button />{" "}
      </div>
    </nav>
  );
}
