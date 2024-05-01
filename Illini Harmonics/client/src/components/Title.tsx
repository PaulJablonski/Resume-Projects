import "../App.css";
function Title() {
  // Javascript XML - under the hood this code gets compiled into Javascript even though it is currently HTML
  return (
    <div className="titleText">
      Illini Harmonics
      <div className="subtitleText">Embark On Your Listening Journey</div>
    </div>
  );
}

// Export it as an object from this file so it can be used in other files.
export default Title;
