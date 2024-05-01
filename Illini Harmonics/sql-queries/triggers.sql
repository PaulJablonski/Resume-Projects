
DELIMITER //
CREATE TRIGGER DeleteUserFriends AFTER DELETE ON UserAccounts
FOR EACH ROW
BEGIN
    DELETE FROM Friends WHERE userid1 = OLD.userid OR userid2 = OLD.userid;
    DELETE FROM Logins WHERE userid = OLD.userid;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER UpdateArtistPopularity AFTER INSERT ON Posts
FOR EACH ROW
BEGIN
    DECLARE cur_artistname VARCHAR(50) DEFAULT NULL;

    -- Select the artistname based on the songid of the inserted post
    SET cur_artistname = (SELECT artistname FROM HasSongs NATURAL JOIN Artists WHERE songid = NEW.songid);

    -- Check if cur_artistname is not null and perform the update
    IF cur_artistname IS NOT NULL THEN
        IF NEW.rating > 3 THEN
            UPDATE Artists SET numreferences = numreferences + 1 WHERE artistname = cur_artistname;
        ELSE
            UPDATE Artists SET numreferences = numreferences - 1 WHERE artistname = cur_artistname;
        END IF;
    END IF;
END;
//
DELIMITER ;

