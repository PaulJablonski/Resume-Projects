import React, { useState } from "react";
import NavBar from "../components/NavBar";
import "../App.css";

interface FriendData {
  username: string;
}

interface FriendsProps {
  friends: FriendData[];
}

function Friends({ friends }: FriendsProps) {
  const [searchInput, setSearchInput] = useState(""); // State to hold the search input value
  // const [operationResult, setOperationResult] = useState<{ success: boolean; message: string } | null>(null);

  const [addFriendSuccess, setAddFriendSuccess] = useState(false); 
  const [addFriendFailed, setAddFriendFailed] = useState(false); 

  const [removeFriendSuccess, setRemoveFriendSuccess] = useState(false); 
  const [removeFriendFailed, setRemoveFriendFailed] = useState(false);

  const handleSearchInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchInput(e.target.value); // Update the search input value as the user types
  };

  const handleAddFriend = async (friendUsername: string) => {
    try {
      console.log(friendUsername);
      const response = await fetch(`http://localhost:8080/addfriend?tmp_username=${friendUsername}`);
      if (!response.ok) {
        throw new Error("Failed to add friend");
      }
      
      const data = await response.json();

      if (data === 'Add friend success') {
        setAddFriendSuccess(true);
        setAddFriendFailed(false);
        setRemoveFriendSuccess(false);
        setRemoveFriendFailed(false);
      } else {
        setAddFriendSuccess(false);
        setAddFriendFailed(true);
        setRemoveFriendSuccess(false);
        setRemoveFriendFailed(false);
      }
    } catch (error) {
      console.error("Error logging in:", error);
      setAddFriendSuccess(false);
      setAddFriendFailed(true);
      setRemoveFriendSuccess(false);
      setRemoveFriendFailed(false);
    }
  };

  const handleRemoveFriend = async (friendUsername: string) => {
    try {
      const response = await fetch(`http://localhost:8080/removefriend?tmp_username=${friendUsername}`);
      if (!response.ok) {
        throw new Error("Failed to remove friend");
      }
      
      const data = await response.json();

      if (data === 'Remove friend success') {
        setRemoveFriendSuccess(true);
        setRemoveFriendFailed(false);
        setAddFriendSuccess(false);
        setAddFriendFailed(false);
      } else {
        setRemoveFriendSuccess(false);
        setRemoveFriendFailed(true);
        setAddFriendSuccess(false);
        setAddFriendFailed(false);
      }
    } catch (error) {
      console.error("Error logging in:", error);
      setRemoveFriendSuccess(false);
      setRemoveFriendFailed(true);
      setAddFriendSuccess(false);
      setAddFriendFailed(false);
    }
  };

  return (
    <div className="screen">
      <NavBar />
      <div className="bodyContainer">
        <div className="friendControls">
          {/* Search bar */}
          <div>
            <input
              type="text"
              value={searchInput}
              onChange={handleSearchInputChange}
              placeholder="Search friends"
              style={{ marginRight: '10px' }}
            />
            {/* Operation result message */}
            { (addFriendSuccess || removeFriendSuccess) && (
              <p style={{ color: "green", marginTop: "10px" }}>Add/Remove Friend Successful!</p>
            )}
            { (addFriendFailed || removeFriendFailed) && (
              <p style={{ color: "red", marginTop: "10px" }}>Add/Remove Friend failed!</p>
            )}
          </div>
          {/* Add Friend button */}
          <button onClick={() => handleAddFriend(searchInput)}>Add Friend</button>
          {/* Remove Friend button */}
          <button onClick={() => handleRemoveFriend(searchInput)}>Remove Friend</button>
        </div>
        <div className="friendList">
          {/* Display list of friends */}
          <ul style={{ listStyle: 'none', padding: '0', textAlign: 'center' }}>
            {friends.map((friend, index) => (
              <li key={index} style={{ fontSize: '30px', margin: '10px 0' }}>
                {friend.username}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

export default Friends;
