import React, { useState } from "react";
import SidePanel from "./SidePanel";

function NavBar() {
  return (
    <div className="sticky-top">
      <nav className="navbar navbar-expand-lg navbar-custom">
        <div className="container">
          <a className="navbar-brand" href="/">
            <img
              src="https://i.imgur.com/EswKOEZ.png"
              className="logo"
              alt="Logo"
            />
          </a>
          <div className="collapse navbar-collapse" id="navbarNav">
            <ul className="navbar-nav ml-auto .navbar-nav-scroll">
              <li className="nav-item active">
                <a className="nav-link" href="/">
                  Home
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="music">
                  Music
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="artists">
                  Artists
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="posts">
                  Posts
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="friends">
                  Friends
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="about">
                  About
                </a>
              </li>
              <li className="nav-item">
                <a className="nav-link" href="create">
                  Create
                </a>
              </li>
              <li className="nav-item" style={{ marginLeft: "650px" }}>
                <a className="nav-link" href="login">
                  Login
                </a>
              </li>
            </ul>
          </div>
        </div>
      </nav>
    </div>
  );
}

export default NavBar;
