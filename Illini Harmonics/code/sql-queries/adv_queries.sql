
-- Select 10 most popular songs of each genre
SELECT DISTINCT songid, songname, artistname, listens
FROM Songs NATURAL JOIN HasSongs NATURAL JOIN Artists
LIMIT 10
GROUP BY genre
ORDER BY listens DESC

-- Select 3 most popular songs of each artist
SELECT DISTINCT songid, songname, artistname, listens
FROM Songs NATURAL JOIN HasSongs NATURAL JOIN Artists
LIMIT 3
GROUP BY artistid
ORDER BY listens DESC

-- Select songs with the best rating
SELECT DISTINCT songid, songname, AVG(rating) as AverageRating
FROM Posts NATURAL JOIN Songs
GROUP BY genre
ORDER BY AVG(rating) DESC

-- Select most popular artists among friends
SELECT DISTINCT artistid, COUNT(*) as ArtistCount
FROM UserAccounts NATURAL JOIN ListeningHistory NATURAL JOIN Songs
     NATURAL JOIN HasSongs NATURAL JOIN Artists
WHERE UserAccounts.userid IN (SELECT userid2
                              FROM FRIENDS
                              WHERE userid1 = UserAccounts.userid)
LIMIT 15
GROUP BY artistid
ORDER BY ArtistCount DESC

