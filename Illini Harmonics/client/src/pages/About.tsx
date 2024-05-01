import NavBar from "../components/NavBar";
import "../App.css";
import SidePanel from "../components/SidePanel";
import MichaelText from "../components/MichaelText";
import PaulText from "../components/PaulText";
import JacobText from "../components/JacobText";
import JoeText from "../components/JoeText";

function About() {
  return (
    <div className="aboutsize">
      <NavBar />
      <SidePanel />
      <div className="about-container">
        <MichaelText />
        <PaulText />
        <JacobText />
        <JoeText />
      </div>
    </div>
  );
}

export default About;
