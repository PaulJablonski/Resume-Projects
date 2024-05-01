import React from "react";

// Import the CSS file for styling
import "../App.css";

interface ArtistProps {
    ArtistName: string;
    Genre: string;
  }

function Artist({ArtistName, Genre}: ArtistProps) {
  return (
    <div className = "artistentry">
      <h2>{ArtistName}</h2>
      <h1>Genre: {Genre}</h1>
    </div>
  );
};

export default Artist;