import React from "react";

// Import the CSS file for styling
import "../App.css";

// Define the interface for PostProps
interface PostProps {
  SongName: string;
  UserName: string;
  Artist: string;
  TimeOfPost: string;
  Rating: number;
}

function Post({ SongName, UserName, Artist, TimeOfPost, Rating }: PostProps) {
  const getImageUrl = () => {
    const ratingImages: { [key: number]: string } = {
      0: "https://i.imgur.com/G5i4y9h.png",
      1: "https://i.imgur.com/3RvL8zq.png",
      2: "https://i.imgur.com/YPxzNGe.png",
      3: "https://i.imgur.com/0B5SeCt.png",
      4: "https://i.imgur.com/YhQtKmk.png",
      5: "https://i.imgur.com/9V64Cbu.png",
    };

    return ratingImages[Rating];
  };

  return (
    <div className="post">
      <h2>{UserName}</h2>
      <h1>
        {SongName} by {Artist}
      </h1>
      <p>{TimeOfPost}</p>
      <img src={getImageUrl()} alt={`Rating ${Rating}`} />
      <div
        className="button-container"
        style={{ marginLeft: "800px", marginTop: "-30px" }}
      >
        <button>Edit</button>
        <button>Delete</button>
      </div>
    </div>
  );
}

export default Post;
