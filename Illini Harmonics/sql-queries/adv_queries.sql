
-- Select 10 most popular songs of each genre
SELECT DISTINCT songid, songname, Artists.genre
FROM Songs NATURAL JOIN HasSongs NATURAL JOIN Artists
GROUP BY Artists.genre, songid, songname
HAVING genre LIKE '%Hip Hop%'
ORDER BY Artists.genre
LIMIT 15;

-- Select 3 most popular songs
SELECT DISTINCT Songs.songid, songname, artistid, artistname, COUNT(ListeningHistories.songid) AS listens
FROM (SELECT DISTINCT songname FROM Songs) AS SongNames NATURAL JOIN Songs NATURAL JOIN HasSongs NATURAL JOIN Artists NATURAL JOIN ListeningHistories
GROUP BY songname, songid, artistname, artistid
ORDER BY listens DESC
LIMIT 15;

-- Select songs with the best rating
SELECT DISTINCT songid, songname, AVG(rating) as AverageRating
FROM Posts NATURAL JOIN Songs NATURAL JOIN Artists
GROUP BY genre, songid
ORDER BY AVG(rating) DESC
LIMIT 15;

-- Select most popular artists among friends
SELECT DISTINCT artistid, artistname, COUNT(*) as ArtistCount
FROM UserAccounts NATURAL JOIN ListeningHistories NATURAL JOIN Songs
     NATURAL JOIN HasSongs NATURAL JOIN Artists
WHERE UserAccounts.userid IN (SELECT userid2
                              FROM Friends
                              WHERE userid1 = UserAccounts.userid)
GROUP BY artistid
ORDER BY ArtistCount DESC
LIMIT 15;


ALTER TABLE Artists ADD COLUMN numreferences INT DEFAULT 0;
CREATE TABLE Logins (
  userid INT,
  logintimes INT,
);

ALTER TABLE Logins ADD CONSTRAINT FK_userid_L FOREIGN KEY (userid) REFERENCES UserAccounts(userid) ON DELETE CASCADE;



SELECT DISTINCT u.username
     FROM UserAccounts u
     JOIN Friends f ON u.userid = f.userid2
     WHERE f.userid1 IN (SELECT userid FROM UserAccounts WHERE username = 'ber9594' AND userid IN ActiveUser)
     UNION
     SELECT u2.username
     FROM UserAccounts u2
     JOIN Friends f2 ON u2.userid = f2.userid1
     WHERE f2.userid2 IN (SELECT userid FROM UserAccounts WHERE username = 'ber9594' AND userid IN ActiveUser)