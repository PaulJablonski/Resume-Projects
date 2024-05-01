import "../App.css";

function Button({
  clickFunction,
  text,
}: {
  clickFunction: () => void;
  text: string;
}) {
  return (
    <button className="btn btn-primary" onClick={clickFunction}>
      {text}
    </button>
  );
}

export default Button;
