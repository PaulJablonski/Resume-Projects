import NavBar from "../components/NavBar";
import CreatePost from "../components/CreatePost";
import "../App.css";

function Create() {
  return (
    <div className="screen">
      <NavBar />
      <CreatePost />
    </div>
  );
}

export default Create;
