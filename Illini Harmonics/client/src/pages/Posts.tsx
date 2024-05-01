import React, { useState, useEffect } from "react";
import NavBar from "../components/NavBar";
import Post from "../components/Post";
import Button from "../components/LoginButton";
import SearchBar from "../components/SearchBar";

function Posts() {
  const [posts, setPosts] = useState<PostData[]>([]);

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

  // Function to fetch posts data from backend
  const filterPostsByArtist = async (artistName: string) => {
    console.log("trying to filter post data by artist");
    console.log(artistName);
    try {
      const response = await fetch(
        `http://localhost:8080/artistsearch?artistName=${encodeURIComponent(
          artistName
        )}`
      );
      if (!response.ok) {
        throw new Error("Failed to filter posts data by artist");
      }
      const data = await response.json();
      setPosts(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error filtering posts data by artist:", error);
    }
  };

  // Function to fetch posts data from backend
  const filterPostsBySong = async (songName: string) => {
    console.log("trying to filter post data by song");
    try {
      const response = await fetch(
        `http://localhost:8080/songsearch?songName=${encodeURIComponent(
          songName
        )}`
      );
      if (!response.ok) {
        throw new Error("Failed to filter posts data by song");
      }
      const data = await response.json();
      setPosts(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error filtering posts data by song:", error);
    }
  };

  // Function to fetch posts data from backend
  const filterPostsByRating = async (rating: string) => {
    console.log("trying to filter post data by rating");
    try {
      const response = await fetch(
        `http://localhost:8080/ratingsearch?rating=${encodeURIComponent(
          rating
        )}`
      );
      if (!response.ok) {
        throw new Error("Failed to filter posts data by rating");
      }
      const data = await response.json();
      setPosts(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error filtering posts data by rating:", error);
    }
  };

  // Function to fetch posts data from backend
  const filterPostsByUser = async (userName: string) => {
    console.log("trying to filter post data by user");
    try {
      const response = await fetch(
        `http://localhost:8080/usersearch?userName=${encodeURIComponent(
          userName
        )}`
      );
      if (!response.ok) {
        throw new Error("Failed to filter posts data by user");
      }
      const data = await response.json();
      setPosts(data); // Update state with fetched artists data
    } catch (error) {
      console.error("Error filtering posts data by user:", error);
    }
  };

  // Function to handle search based on artist name
  function handleSearchByArtist(artistName: string) {
    if (artistName.trim() === "") {
      // If search query is empty, fetch all posts
      fetchPostsData();
    } else {
      // Otherwise, fetch posts by artist
      filterPostsByArtist(artistName);
    }
  }

  // Function to handle search based on artist name
  function handleSearchBySong(songName: string) {
    if (songName.trim() === "") {
      // If search query is empty, fetch all posts
      fetchPostsData();
    } else {
      // Otherwise, fetch posts by artist
      filterPostsBySong(songName);
    }
  }

  // Function to handle search based on artist name
  function handleSearchByRating(rating: string) {
    if (rating.trim() === "") {
      // If search query is empty, fetch all posts
      fetchPostsData();
    } else {
      // Otherwise, fetch posts by artist
      filterPostsByRating(rating);
    }
  }

  // Function to handle search based on artist name
  function handleSearchByUser(userName: string) {
    if (userName.trim() === "") {
      // If search query is empty, fetch all posts
      fetchPostsData();
    } else {
      // Otherwise, fetch posts by artist
      filterPostsByUser(userName);
    }
  }

  useEffect(() => {
    // Fetch all posts data when component mounts
    fetchPostsData();
  }, []);

  console.log(posts);
  return (
    <div className="screen">
      <NavBar />
      <div className="buttoncontainer">
        <SearchBar
          onSearch={handleSearchByArtist}
          placeholder="Filter By Artist"
        />
        <div style={{ marginRight: "10px" }} />
        <SearchBar
          onSearch={handleSearchByRating}
          placeholder="Filter By Rating"
        />
        <div style={{ marginRight: "10px" }} />
        <SearchBar onSearch={handleSearchBySong} placeholder="Filter By Song" />
        <div style={{ marginRight: "10px" }} />
        <SearchBar
          onSearch={handleSearchByUser}
          placeholder="Filter By username"
        />
      </div>
      <div className="postContainer">
        {posts.map((post, index) => (
          <Post
            key={index}
            SongName={post.songname}
            UserName={post.username}
            Artist={post.artistname}
            TimeOfPost={post.timeofpost}
            Rating={post.rating}
          />
        ))}
      </div>
    </div>
  );
}

export default Posts;
