require('dotenv').config()

var mysql = require('mysql2');
const express = require('express');
const app = express();
const cors = require('cors'); // Import the cors middleware
var connection = mysql.createConnection({
  host: '34.170.173.137', 
  user: 'root',
  password: 'root',
  database: 'ihd'
});

connection.connect;
const bodyParser = require('body-parser');

app.use(cors()); // Enable CORS for all routes

app.get('/', (req,res) => res.send('Try: /status, /artistdata') );

app.get('/status', (req, res) => res.send('Success.') );


// GET all artist data for initial display
app.get('/artists', (req, res) => {
  connection.query("SELECT artistname, genre FROM `ihd`.`Artists`", (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// GET all music data for initial display
app.get('/music', (req, res) => {
  connection.query("SELECT songname, len, popularity FROM `ihd`.`Songs`", (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// GET all post data for initial display
app.get('/posts', (req, res) => {
  connection.query("SELECT songname, username, artistname, rating, timeofpost FROM `ihd`.`Posts` NATURAL JOIN `ihd`.`HasSongs` NATURAL JOIN `ihd`.`Songs` NATURAL JOIN `ihd`.`UserAccounts` NATURAL JOIN `ihd`.`Artists` LIMIT 30", (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});
  
// GET all post data that have the artist name
app.get('/artistsearch', (req, res) => {
  const artistName = req.query.artistName; // Assuming the artist name is passed as a query parameter
  connection.query("SELECT songname, username, artistname, rating, timeofpost FROM `ihd`.`Posts` NATURAL JOIN `ihd`.`HasSongs` NATURAL JOIN `ihd`.`Songs` NATURAL JOIN `ihd`.`UserAccounts` NATURAL JOIN `ihd`.`Artists` WHERE artistname LIKE CONCAT('%', ?, '%') LIMIT 30", [artistName], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// GET all post data that have the song name
app.get('/songsearch', (req, res) => {
  const songName = req.query.songName; // Assuming the song name is passed as a query parameter
  connection.query("SELECT songname, username, artistname, rating, timeofpost FROM `ihd`.`Posts` NATURAL JOIN `ihd`.`HasSongs` NATURAL JOIN `ihd`.`Songs` NATURAL JOIN `ihd`.`UserAccounts` NATURAL JOIN `ihd`.`Artists` WHERE songname LIKE CONCAT('%', ?, '%') LIMIT 30", [songName], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// GET all post data that have the song name
app.get('/ratingsearch', (req, res) => {
  const rating = req.query.rating; // Assuming the song name is passed as a query parameter
  connection.query("SELECT songname, username, artistname, rating, timeofpost FROM `ihd`.`Posts` NATURAL JOIN `ihd`.`HasSongs` NATURAL JOIN `ihd`.`Songs` NATURAL JOIN `ihd`.`UserAccounts` NATURAL JOIN `ihd`.`Artists` WHERE rating LIKE CONCAT('%', ?, '%') LIMIT 30", [rating], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// GET all post data that have the song name
app.get('/usersearch', (req, res) => {
  const userName = req.query.userName; // Assuming the song name is passed as a query parameter
  connection.query("SELECT songname, username, artistname, rating, timeofpost FROM `ihd`.`Posts` NATURAL JOIN `ihd`.`HasSongs` NATURAL JOIN `ihd`.`Songs` NATURAL JOIN `ihd`.`UserAccounts` NATURAL JOIN `ihd`.`Artists` WHERE username LIKE CONCAT('%', ?, '%') LIMIT 30", [userName], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

app.get('/logout', (req, res) => {
  const rating = req.query.rating; // Assuming the song name is passed as a query parameter
  connection.query("DELETE FROM ActiveUser", (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.json(results);
  });
});

// Login endpoint
app.get('/login', (req, res) => {
  const { tmp_username, tmp_pswrd } = req.query;

  // Check if the required parameters are provided
  if (!tmp_username || !tmp_pswrd) {
    res.status(400).send('Username or password is missing');
    return;
  }

  // Use parameterized query or prepared statement to prevent SQL injection
  connection.query('CALL CheckLogins(?, ?, @success)', [tmp_username, tmp_pswrd], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Retrieve the value of the output parameter
    connection.query('SELECT @success', (err, results2) => {
      if (err) {
        console.error('Error retrieving output parameter:', err);
        res.status(500).send('Internal Server Error');
        return;
      }

      var success = results2[0]['@success'];

      // Check the value of account_found and send appropriate response
      if (success === 1) {
        res.send(JSON.stringify('Login success'));
      } else {
        res.send(JSON.stringify('Login failed'));
      }
    });
  });
});



// Signup endpoint
app.get('/signup', (req, res) => {
  const { tmp_username, tmp_pswrd } = req.query;

  // Check if the required parameters are provided
  if (!tmp_username || !tmp_pswrd) {
    res.status(400).send('Username or password is missing');
    return;
  }

  // Use parameterized query or prepared statement to prevent SQL injection
  connection.query('CALL CheckSignups(?, ?, @success)', [tmp_username, tmp_pswrd], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Retrieve the value of the output parameter
    connection.query('SELECT @success', (err, results2) => {
      if (err) {
        console.error('Error retrieving output parameter:', err);
        res.status(500).send('Internal Server Error');
        return;
      }

      var success = results2[0]['@success'];

      // Check the value of account_found and send appropriate response
      if (success === 1) {
        res.send(JSON.stringify('Signup success'));
      } else {
        res.send(JSON.stringify('Signup failed'));
      }
    });
  });
});

// friends endpoint
app.get('/friends', (req, res) => {

  connection.query(
    `SELECT DISTINCT u.username
    FROM UserAccounts u
    JOIN Friends f ON u.userid = f.userid2
    WHERE f.userid1 IN (SELECT userid FROM ActiveUser)
    UNION
    SELECT DISTINCT u2.username
    FROM UserAccounts u2
    JOIN Friends f2 ON u2.userid = f2.userid1
    WHERE f2.userid2 IN (SELECT userid FROM ActiveUser);
    `,
    (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        res.status(500).send('Internal Server Error');
        return;
      }

      // Check if friends are found
      if (results.length === 0) {
        res.status(404).send('User not found or has no friends');
        return;
      }

      // Send the list of friends in the response
      res.json(results);
    }
  );
});

app.get('/addfriend', (req, res) => {

  const { tmp_username } = req.query;

  console.log(tmp_username);
  // Check if the required parameters are provided
  if (!tmp_username) {
    res.status(400).send('Username or password is missing');
    return;
  }

  connection.query('CALL AddFriend(?, @success)', [tmp_username], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error1');
      return;
    }

    // Retrieve the value of the output parameter
    connection.query('SELECT @success', (err, results2) => {
      if (err) {
        console.error('Error retrieving output parameter:', err);
        res.status(500).send('Internal Server Error2');
        return;
      }

      var success = results2[0]['@success'];
      console.log("Success = " + success);
      // Check the value of account_found and send appropriate response
      if (success === 1) {
        res.send(JSON.stringify('Add friend success'));
      } else {
        res.send(JSON.stringify('Add friend failed'));
      }
    });
  });
});

app.get('/removefriend', (req, res) => {

  const { tmp_username } = req.query;

  console.log(tmp_username);

  // Check if the required parameters are provided
  if (!tmp_username) {
    res.status(400).send('Username or password is missing');
    return;
  }

  connection.query('CALL RemoveFriend(?, @success)', [tmp_username], (err, results) => {
    if (err) {
      console.log('1');
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Retrieve the value of the output parameter
    connection.query('SELECT @success', (err, results2) => {
      if (err) {
        console.error('Error retrieving output parameter:', err);
        res.status(500).send('Internal Server Error');
        return;
      }

      var success = results2[0]['@success'];

      // Check the value of account_found and send appropriate response
      if (success === 1) {
        res.send(JSON.stringify('Remove friend success'));
      } else {
        res.send(JSON.stringify('Remove friend failed'));
      }
    });
  });
});

app.post('/createpost', (req, res) => {
  const { songName, artist, rating } = req.query;
  if (!songName || !artist || !rating) {
    res.status(400).send('Required fields are missing');
    return;
  }

  connection.query('CALL createpost(?, ?, ?, @success)', [songName, artist, rating], (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    

    // Retrieve the value of the output parameter
    connection.query('SELECT @success', (err, results2) => {
      if (err) {
        console.error('Error retrieving output parameter:', err);
        res.status(500).send('Internal Server Error');
        return;
      }

    var success = results2[0]['@success'];
    
    if (success) {
      res.send(JSON.stringify(success)); // Send success message
    } else {
      res.status(500).send('Error creating post'); // Send error message if no success message found
    }
  });
  });
});


// Use port 8080 by default, unless configured differently in Google Cloud
const port = process.env.PORT || 8080;
app.listen(port, () => {
   console.log(`App is running at: http://localhost:${port}`);
});