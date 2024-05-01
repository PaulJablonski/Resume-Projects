DELIMITER //
CREATE PROCEDURE CheckLogins(
    IN u_username VARCHAR(255),
    IN u_password VARCHAR(255),
    OUT success INT
)
BEGIN
    DECLARE cur_id INT DEFAULT NULL;
    DECLARE found_password VARCHAR(255);

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    -- INSERT INTO Logins (userid, logintimes) VALUES (1, 500);

    -- Get the userid based on the username
    SET cur_id = (SELECT userid FROM UserAccounts WHERE UserAccounts.username = u_username);

    -- Get their password based on userid
    SET found_password = (SELECT passwd FROM UserAccounts WHERE UserAccounts.userid = cur_id);

    -- Check if cur_id is not null
    IF cur_id IS NOT NULL THEN
        -- Check if password is correct
        IF found_password LIKE CONCAT('%', u_password, '%') THEN
            -- Check if the userid exists in Logins
            IF NOT EXISTS (SELECT * FROM Logins WHERE userid = cur_id) THEN
                -- Insert a new record into Logins
                INSERT INTO Logins (userid, logintimes) VALUES (cur_id, 1);
            ELSE
                -- Update the logintimes for the existing record
                UPDATE Logins SET logintimes = logintimes + 1 WHERE userid = cur_id;
            END IF;
            -- Account found
            INSERT INTO ActiveUser (userid) VALUES (cur_id);
            SET success = 1;
        ELSE
            -- Wrong password
            SET success = 0;
        END IF;
    ELSE
        -- Account not found
        SET success = -1;
    END IF;

    -- Commit the transaction
    COMMIT;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CheckSignups(
    IN u_username VARCHAR(255),
    IN u_password VARCHAR(255),
    OUT success INT
)
BEGIN
    DECLARE next_userid INT DEFAULT NULL;

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;
    SELECT COUNT(*) INTO next_userid FROM UserAccounts;
    SET next_userid = next_userid + 1;

    INSERT INTO UserAccounts (userid, username, passwd) VALUES (next_userid, u_username, u_password);
    INSERT INTO Logins (userid, logintimes) VALUES (next_userid, 1);
    INSERT INTO ActiveUser (userid) VALUES (next_userid);

    SET success = 1;

    -- Commit the transaction
    COMMIT;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE ShowFriends( IN username VARCHAR(255), OUT success INT )
BEGIN

    DECLARE cur_id INT DEFAULT NULL;

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    SET cur_id = (SELECT userid FROM UserAccounts WHERE UserAccounts.username = username);

    IF cur_id NOT IN (SELECT * FROM ActiveUser) THEN
        SET success = 0;
    ELSE 
        SET success = 1;
        SELECT username FROM UserAccounts u JOIN (SELECT fr.userid2 AS ud FROM UserAccounts JOIN Friends fr ON fr.userid1 = cur_id ) f ON u.userid=f.ud
        UNION
        SELECT username FROM UserAccounts u2 JOIN (SELECT fr.userid1 AS ud FROM UserAccounts JOIN Friends fr ON fr.userid2 = cur_id ) f2 ON u2.userid=f2.ud;

    COMMIT;
    END IF;

END
//
DELIMITER ;



DELIMITER //
CREATE PROCEDURE Logout( IN username VARCHAR(255) )
BEGIN
    DECLARE cur_id INT DEFAULT NULL;

    START TRANSACTION;
    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    SET cur_id = (SELECT userid FROM UserAccounts WHERE UserAccounts.username = username);
    IF cur_id IN (SELECT * FROM ActiveUser) THEN
        DELETE FROM ActiveUser WHERE cur_id = ActiveUser.userid;
    END IF;

    COMMIT;   

END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE AddFriend( IN u_username VARCHAR(255), OUT success INT )
BEGIN
    DECLARE cur_user_id INT;
    DECLARE friend_user_id INT;

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    SELECT userid INTO cur_user_id FROM ActiveUser ORDER BY userid LIMIT 1;
    SELECT DISTINCT userid INTO friend_user_id FROM UserAccounts WHERE username = u_username LIMIT 1;
    SELECT friend_user_id;
    IF EXISTS (SELECT DISTINCT userid1 FROM Friends WHERE ( userid1 = cur_user_id OR userid2 = cur_user_id ) AND ( userid1 = friend_user_id OR userid2 = friend_user_id ) ) THEN
        SET success = 0;
    ELSEIF EXISTS (SELECT DISTINCT userid FROM UserAccounts WHERE username = u_username) THEN
        SET success = 1;
        INSERT INTO Friends (userid1, userid2) VALUES (cur_user_id, friend_user_id);
    ELSE
        SET success = 0;
    END IF;

    COMMIT;   
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RemoveFriend( IN u_username VARCHAR(255), OUT success INT )
BEGIN
    DECLARE cur_user_id INT;
    DECLARE friend_user_id INT;

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    SELECT userid INTO cur_user_id FROM ActiveUser ORDER BY userid LIMIT 1;
    SELECT DISTINCT userid INTO friend_user_id FROM UserAccounts WHERE username = u_username LIMIT 1;

    IF EXISTS (
        SELECT * FROM (
            SELECT userid1 AS user_id FROM Friends WHERE userid2 = cur_user_id
            UNION
            SELECT userid2 AS user_id FROM Friends WHERE userid1 = cur_user_id
        ) AS temp
        WHERE user_id = friend_user_id
    ) THEN
        DELETE FROM Friends WHERE (userid1 = cur_user_id AND userid2 = friend_user_id) OR (userid1 = friend_user_id AND userid2 = cur_user_id);
        SET success = 1;
    ELSE
        SET success = 0;
    END IF;

    COMMIT;   
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CreatePost( IN u_songname VARCHAR(255), IN u_artist VARCHAR(255), IN u_rating INT, OUT success INT )
BEGIN

    DECLARE next_post_id INT DEFAULT NULL;
    DECLARE cur_user_id INT;
    DECLARE cur_timeofpost VARCHAR(255);
    DECLARE cur_song_id VARCHAR(22);

    SET TRANSACTION READ WRITE;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;

    SELECT userid INTO cur_user_id FROM ActiveUser ORDER BY userid LIMIT 1;
    select u_songname;
    SELECT songid INTO cur_song_id FROM Songs WHERE songname = u_songname ORDER BY songid LIMIT 1;
    select cur_song_id;
    SELECT COUNT(*) INTO next_post_id FROM Posts;
    SET next_post_id = next_post_id + 1;

    SELECT NOW() INTO cur_timeofpost;
    
    INSERT INTO Posts (postid, rating, timeofpost, likes, userid, songid) VALUES (next_post_id, u_rating, cur_timeofpost, 0, cur_user_id, cur_song_id);
    SET success = 1;

    COMMIT;   
END;
//
DELIMITER ;
