import React from "react";
import "../App.css";

interface MusicProps {
  songname: string;
  len: number;
  popularity: number;
}

function Music({ songname, len, popularity }: MusicProps) {
console.log(songname);
  return (
    <div className="musicentry">
      <h2>{songname}</h2>
      <h1>Length: {len}</h1>
      <h3>Popularity: {popularity}</h3>
    </div>
  );
};

export default Music;
