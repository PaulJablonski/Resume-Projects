import React from "react";
import NavBar from "../components/NavBar";
import "../App.css";
import Music from "../components/MusicEntry";

interface MusicData {
  songname: string;
  len: number;
  popularity: number;
}

interface MusicProps {
  music: MusicData[];
}

function Musics({ music }: MusicProps) {
  return (
    <div className="screen">
      <NavBar />
      <div className="postContainer" style={{ height: 'calc(100% - 10%)' }}>
        {music.map((song, index) => (
          <Music
            key={index}
            songname={song.songname}
            len={song.len}
            popularity={song.popularity}
          />
        ))}
      </div>
    </div>
  );
}

export default Musics;
