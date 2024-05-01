USE ihd;

-- Create baseline tables --
CREATE TABLE Artists (
  artistid VARCHAR(50),
  artistname VARCHAR(255),
  genre VARCHAR(20),
  PRIMARY KEY (artistid)
);

CREATE TABLE Songs (
  songid VARCHAR(22),
  songname VARCHAR(255),
  len INT,
  popularity INT,
  PRIMARY KEY (songid)
);

CREATE TABLE UserAccounts (
  userid INT,
  username VARCHAR(255),
  passwd VARCHAR(255),
  PRIMARY KEY (userid)
);

CREATE TABLE Posts (
  postid INT,
  rating INT,
  timeofpost VARCHAR(20),
  likes INT,
  userid INT,
  songid VARCHAR(22),
  PRIMARY KEY (postid)
);

CREATE TABLE Tags (
  tagid INT,
  tagname VARCHAR(20),
  PRIMARY KEY (tagid)
);

CREATE TABLE Creates (
  postid INT,
  tagid INT,
  PRIMARY KEY (postid, tagid)
);

CREATE TABLE ListeningHistories (
  userid INT,
  songid VARCHAR(22),
  PRIMARY KEY (userid, songid)
);

CREATE TABLE Friends (
  userid1 INT,
  userid2 INT,
  PRIMARY KEY (userid1, userid2)
);

CREATE TABLE HasSongs (
  artistid VARCHAR(50),
  songid VARCHAR(22),
  PRIMARY KEY (artistid, songid)
);

CREATE TABLE ActiveUser (
  userid INT,
);
