import React from 'react';
import '../App.css';

interface ButtonProps {
  onClick: () => void; // Define the type of onClick function
  label: string; // Specify the type of label as string
}

const Button: React.FC<ButtonProps> = ({ onClick, label }) => {
  return (
    <button className="button" onClick={onClick}>{label}</button>
  );
}

export default Button;
