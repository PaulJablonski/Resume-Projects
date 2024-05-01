import "../App.css";

import React, { useState } from "react";

function SearchBar({
  onSearch,
  placeholder,
}: {
  onSearch: (query: string) => void;
  placeholder: string;
}) {
  const [searchQuery, setSearchQuery] = useState("");

  function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
    setSearchQuery(event.target.value);
  }

  // This prepares the query to be used by the function passed in, trims the query
  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    onSearch(searchQuery.trim());
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Enter") {
      event.preventDefault();
      onSearch(searchQuery.trim());
    }
  }

  return (
    <form onSubmit={handleSubmit} className="d-flex">
      <input
        type="text"
        className="form-control me-2"
        placeholder={placeholder}
        value={searchQuery}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
      />
      <button type="submit" className="btn btn-outline-success">
        Search
      </button>
    </form>
  );
}

export default SearchBar;
