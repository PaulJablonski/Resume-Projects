import React, { useState } from "react";

function CreatePost() {
  const [songName, setSongName] = useState("");
  const [artist, setArtist] = useState("");
  const [rating, setRating] = useState(0);

  const handleSubmit = async (e) => {
    e.preventDefault();
    console.log("Song Name:", songName);
    console.log("Artist:", artist);
    console.log("Rating:", rating);
  
    try {
      const response = await fetch(`http://localhost:8080/createpost?songName=${songName}&artist=${artist}&rating=${rating}`, {
        method: "POST", // Assuming you're sending data via POST
        headers: {
          "Content-Type": "application/json", // Assuming you're sending JSON data
        },
        body: JSON.stringify({ // Assuming you're sending songName, artist, and rating as JSON data
          songName: songName,
          artist: artist,
          rating: rating,
        }),
      });
      
      if (!response.ok) {
        throw new Error("Failed to create post");
      }
  
      // Handle response from the server if needed
      const responseData = await response.json();
      console.log("Response from server:", responseData);
  
      // Reset form fields after successful submission
      setSongName("");
      setArtist("");
      setRating(0);
    } catch (error) {
      console.error("Error creating post:", error);
    }
  };
  

  return (
    <div
      className="postContainer"
      style={{
        marginTop: "0px",
        height: "500px",
        marginLeft: "5px",
        marginRight: "5px",
        justifyContent: "center",
        position: "relative",
        overflowY: "auto",
      }}
    >
      <form
        className="post"
        style={{
          border: "2px solid #6b6b6b",
          borderRadius: "10px",
          width: "500px",
          height: "250px",
          padding: "20px",
          marginBottom: "10px",
          marginTop: "10px",
          backgroundColor: "rgb(24, 24, 24)",
          position: "relative",
        }}
        onSubmit={handleSubmit}
      >
        <h2
          style={{
            fontSize: "2rem",
            marginTop: "-5px",
            marginLeft: "10px",
            marginBottom: "10px",
            fontWeight: "500",
            textShadow: "2px 2px 4px #ffffff5d",
            color: "rgb(218, 218, 218)",
          }}
        >
          Create a New Post
        </h2>
        <div>
          <label htmlFor="songName" style={{ fontSize: "1.5rem", color: "white" }}>
            Song Name:
          </label>
          <input
            type="text"
            id="songName"
            value={songName}
            onChange={(e) => setSongName(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="artist" style={{ fontSize: "1.5rem", color: "white" }}>
            Artist:
          </label>
          <input
            type="text"
            id="artist"
            value={artist}
            onChange={(e) => setArtist(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="rating" style={{ fontSize: "1.5rem", color: "white" }}>
            Rating:
          </label>
          <input
            type="number"
            id="rating"
            min="0"
            max="5"
            value={rating}
            onChange={(e) => setRating(parseInt(e.target.value))}
            required
          />
        </div>
        <button type="submit" style={{ fontSize: "1.5rem", marginTop: "10px"    }}>
          Submit
        </button>
      </form>
    </div>
  );
}

export default CreatePost;
