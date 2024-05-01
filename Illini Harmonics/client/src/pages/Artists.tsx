import NavBar from "../components/NavBar";
import "../App.css";
import Artist from "../components/ArtistEntry";

interface ArtistData {
  artistname: string;
  genre: string;
}

interface ArtistsProps {
  artists: ArtistData[];
}

function Artists({ artists }: ArtistsProps) {
  return (
    <div className="screen">
      <NavBar />
      <div className="postContainer" style={{ height: 'calc(100% - 10%)' }}>
        {artists.map((artist, index) => (
          <Artist
            key={index}
            ArtistName={artist.artistname}
            Genre={artist.genre}
          />
        ))}
      </div>
    </div>
  );
}

export default Artists;

