import "./App.css";
import { Route, Routes } from "react-router-dom";
import Home from "./pages/Home";
import Posts from "./pages/Posts";
import Artists from "./pages/Artists";
import Music from "./pages/Music";
import Friends from "./pages/Friends";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import Create from "./pages/Create";

import React, { useState, useEffect } from "react";
import About from "./pages/About";

function App() {
  // States to store data
  const [artists, setArtists] = useState([]);
  const [posts, setPosts] = useState([]);
  const [friends, setFriends] = useState([]);
  const [music, setMusic] = useState([]);

  // Function to fetch artists data from backend
  const fetchArtistsData = async () => {
    console.log("trying to get artist data");
    try {
      const response = await fetch("http://localhost:8080/artists");
      if (!response.ok) {
        throw new Error("Failed to fetch artists data");
      }
      const data = await response.json();
      setArtists(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error fetching artists data:", error);
    }
  };

  // Function to fetch posts data from backend
  const fetchPostsData = async () => {
    console.log("trying to get post data");
    try {
      const response = await fetch("http://localhost:8080/posts");
      if (!response.ok) {
        throw new Error("Failed to fetch posts data");
      }
      const data = await response.json();
      setPosts(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error fetching posts data:", error);
    }
  };

   const fetchFriendsData = async () => {
    console.log("trying to get friends data");
    try {
      const response = await fetch("http://localhost:8080/friends");
      if (!response.ok) {
        throw new Error("Failed to fetch friends data");
      }
      const data = await response.json();
      setFriends(data);
    } catch (error) {
      console.error("Error fetching friends data:", error);
    }
  };

  const fetchMusicData = async () => {
    console.log("trying to get music data");
    try {
      const response = await fetch("http://localhost:8080/music");
      if (!response.ok) {
        throw new Error("Failed to fetch music data");
      }
      const data = await response.json();
      setMusic(data);
    } catch (error) {
      console.error("Error fetching music data:", error);
    }
  };

  // Fetch artists data when component mounts
  useEffect(() => {
    fetchArtistsData();
    fetchPostsData();
    fetchFriendsData();
    fetchMusicData();
  }, []);

  return (
    <div>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/posts" element={<Posts />} />{" "}
        {/* Pass post data as props to Posts component */}
        <Route path="/artists" element={<Artists artists={artists} />} />{" "}
        {/* Pass artists data as props to Artists component */}
        <Route path="/friends" element={<Friends friends={friends} />} />{" "}
        {/* Pass friends data as props */}
        <Route path="/music" element={<Music music={music}/>} />{" "}
        {/* Pass music data as props */}
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/about" element={<About />} />
        <Route path="/create" element={<Create />} />
      </Routes>
    </div>
  );
}

export default App;

