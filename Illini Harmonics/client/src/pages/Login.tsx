import React, { useState, ChangeEvent } from "react";
import { Link } from "react-router-dom";
import NavBar from "../components/NavBar";
import Button from "../components/Button";

interface UsernameTextboxProps {
  setUsername: React.Dispatch<React.SetStateAction<string>>;
}

const UsernameTextbox: React.FC<UsernameTextboxProps> = ({ setUsername }) => {
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setUsername(e.target.value);
  };

  return (
    <input
      type="text"
      placeholder="Enter username"
      onChange={handleChange}
    />
  );
};

interface PasswordTextboxProps {
  setPassword: React.Dispatch<React.SetStateAction<string>>;
}

const PasswordTextbox: React.FC<PasswordTextboxProps> = ({ setPassword }) => {
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
  };

  return (
    <input
      type="password"
      placeholder="Enter password"
      onChange={handleChange}
    />
  );
};

interface SubmitButtonProps {
    handleSubmit: (e: React.FormEvent<HTMLFormElement>) => void;
  }
  

  const SubmitButton: React.FC<SubmitButtonProps> = ({ handleSubmit }) => {
    return <button type="submit">Log in</button>;
  };

function Login() {
  const [username, setUsername] = useState<string>("");
  const [password, setPassword] = useState<string>("");

  const [loginSuccess, setLoginSuccess] = useState(false); // State to track login success
  const [loginFailed, setLoginFailed] = useState(false); // State to track login success


  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault(); 
  
    // Pass username and password to SQL query function or API endpoint
    console.log("Username:", username);
    console.log("Password:", password);
  
    try {
      const response = await fetch("http://localhost:8080/login?tmp_username=" + username + "&tmp_pswrd=" + password);
      if (!response.ok) {
        throw new Error("Failed to login");
      }
      const data = await response.json();
      
      // Check the login status returned from the server
      if (data === 'Login success') {
        setLoginSuccess(true);
        setLoginFailed(false);
      } else {
        setLoginFailed(true);
        setLoginSuccess(false);
      }
    } catch (error) {
      console.error("Error logging in:", error);
      setLoginFailed(true);
      setLoginSuccess(false);
    }
  };  

  const handleLogout = async () => {
    console.log("Logged out");
    try {
      const response = await fetch("http://localhost:8080/logout");
      if (!response.ok) {
        throw new Error("Failed to fetch music data");
      }
      setLoginSuccess(false);
      setLoginFailed(false);
      setUsername("");
      setPassword("");
    } catch (error) {
      console.error("Error fetching music data:", error);
    }
  };

  return (
    <div className="screen">
      <NavBar />
      <div className="login-form" style={{ marginTop: '50px' }}>
        <h2>Log In</h2>
        <form onSubmit={handleSubmit}>
          <UsernameTextbox setUsername={setUsername} />
          <PasswordTextbox setPassword={setPassword} />
          <SubmitButton handleSubmit={handleSubmit} />
        </form>
        {loginSuccess && (
          <p style={{ color: "green", marginTop: "10px" }}>Login successful!</p>
        )}
        {loginFailed && (
          <p style={{ color: "red", marginTop: "10px" }}>Login failed!</p>
        )}
        <p style={{ marginTop: '10px' }}>
          Don't have an account? <Link to="/signup">Sign Up</Link>
        </p>
      </div>
      <div style={{ display: "flex", justifyContent: "center", marginTop: "10px"}}>
            <Button clickFunction={handleLogout} text="Logout"></Button>
      </div>
    </div>
  );
}

export default Login;
