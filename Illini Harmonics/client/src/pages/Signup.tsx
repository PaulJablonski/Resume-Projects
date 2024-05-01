// Signup.tsx
import React, { useState } from "react";
import { Link } from "react-router-dom";
import NavBar from "../components/NavBar";

function Signup() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const [signupSuccess, setSignUpSuccess] = useState(false); // State to track login success
  const [signupFailed, setSignUpFailed] = useState(false); // State to track login success


  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); 
  
    // Pass username and password to SQL query function or API endpoint
    console.log("Username:", username);
    console.log("Password:", password);
  
    try {
      const response = await fetch("http://localhost:8080/signup?tmp_username=" + username + "&tmp_pswrd=" + password);
      if (!response.ok) {
        throw new Error("Failed to signup");
      }
      const data = await response.json();
      
      // Check the login status returned from the server
      if (data === 'Signup success') {
        setSignUpSuccess(true);
        setSignUpFailed(false);
      } else {
        setSignUpFailed(true);
        setSignUpSuccess(false);
      }
    } catch (error) {
      console.error("Error logging in:", error);
      setSignUpFailed(true);
      setSignUpSuccess(false);
    }
  };  

  return (
    <div className="screen">
      <NavBar />
      <div className="login-form" style={{ marginTop: '50px' }}>
        <h2>Sign Up</h2>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="Enter username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <input
            type="password"
            placeholder="Enter password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button type="submit">Sign Up</button>
        </form>
        {signupSuccess && (
          <p style={{ color: "green", marginTop: "10px" }}>Signup successful!</p>
        )}
        {signupFailed && (
          <p style={{ color: "red", marginTop: "10px" }}>Signup failed!</p>
        )}
        <p style={{ marginTop: '10px' }}>
          Already have an account? <Link to="/login">Login</Link>
        </p>
      </div>
    </div>
  );
};

export default Signup;
