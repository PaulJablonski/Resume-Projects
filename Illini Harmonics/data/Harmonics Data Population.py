import spotipy
import csv
import math
import random

# The following file is used to populate our data CSVs for initial use.
# It will autogenerate data using popular public data from Spotify
# and create CSV files using this data that can be converted
# into our relational SQL tables later.

# SET UP DATA RETRIEVAL AND TOKENS
# Our client id and secret tokens
appid = '7aa1e70cf83b4fc3802f5787c863cd52'
appsecret = '1aa60611e118441f9536234375a332de'

# Set up authorization token for our client app using the generated token values I set up on the Spotify for Developers website
manager = spotipy.oauth2.SpotifyOAuth(client_id = appid,
                                      client_secret = appsecret,
                                      redirect_uri = 'http://localhost:8888/callback')

authToken = spotipy.Spotify(auth_manager = manager)






# GET RAW DATA FROM SPOTIFY
# Create list variables
songid, songname, artistid, artistname, length, popularity = [], [], [], [], [], []

# Retrieve data
for i in range(10):                                                                                         # Spotify requests only allow 100 tracks returned at a time, so we loop and do 10 requests
    rawsongdata = authToken.playlist_tracks(playlist_id = '4uwZQn4MxBKEAWhsRqH9jZ', offset = 100 * i)       # Perform data request   

    for idx, item in enumerate(rawsongdata['items']):                                                       # Loop through the raw song data and obtain the items we care about
        # Song related data (must be aligned index-wise)
        songname.append(item['track']['name'])                                                              # Song name
        songid.append(item['track']['id'])                                                                  # Song ID
        length.append(math.floor(item['track']['duration_ms'] / 1000))                                      # Length
        popularity.append(item['track']['popularity'])                                                      # Popularity

        artistid.append([artist['id'] for artist in item['track']['artists']])                              # Artist IDs
        artistname.append([artist['name'] for artist in item['track']['artists']])                          # Artist Names

print('Initial data retrieval complete')




# MAIN TABLES
# Creating the songs CSV
songdata = [['songid', 'songname', 'length', 'popularity']]                            

for i in range(len(songid)):                                                                                # Loop through all entries and add to song data
    songdata.append([songid[i], songname[i], length[i], popularity[i]])

print('Song data compiled with length of:', len(songdata))                                                  # Print complete statement
print(songdata[1])

with open('songs.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in songdata:
        csv_writer.writerow(row)



# Creating the artists CSV
artistdata = [['artistid', 'artistname', 'genre']]

genres = ['Hip Hop', 'Pop']                                                                                 # Basic genres for now
visitedartists = []                                                                                         # Keep track of already stored artists

for i in range(len(artistid)):                                                                              # Loop through all entries and add to artist data
    for j in range(len(artistid[i])):
        genre = genres[random.randrange(0,2)]                                                               # Genre will be obtained properly in future uses

        if artistid[i][j] not in visitedartists:                                                            # Check for duplicate artist IDs
            artistdata.append([artistid[i][j], artistname[i][j], genre])
            visitedartists.append(artistid[i][j])

print('Artist data compiled with length of:', len(artistdata))                                              # Print complete statement
print(artistdata[1])

with open('artists.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in artistdata:
        csv_writer.writerow(row)



# Creating the user accounts CSV
userdata = [['userid', 'username', 'password']]

words = ['hummus', 'goblin', 'brick', 'farm', 'mother', 'foo', 'grape', 'banana', 'car', 'home', 'lizard', 'knight', 'sir', 'miss', 'princess', 'king', 'prince', 'dork', 'lol', 'moon', 'squirrel',
         'gobbler', 'destroyer', 'slayer', 'lover', 'maker', 'coffee', 'branch', 'fish', 'bear', 'ber', 'pau', 'jac', 'joe', 'mic', 'parm', 'cheese', 'cheddar', 'leopard', 'tiger', 'soccer', 'footbol',
         'football', 'baseball', 'tennis', 'badminton', 'runner', 'major', 'mr', 'lil', 'little', 'umbrella', 'lit', 'travvypatty', 'fan', 'glizzy', 'obsessor', 'creator', 'relax', 'goober', 'fighter']

usedusernames = []
u = 0

while (u < 1250):
    chooser = random.randrange(0, 3)                                                                        # Choose one of three possible username combinations

    if (chooser == 0):
        username = words[random.randrange(0, len(words))] + words[random.randrange(0, len(words))] + str(random.randrange(0, 9999))
        password = words[random.randrange(0, len(words))] + str(random.randrange(0, 9999))
    elif (chooser == 1):
        username = words[random.randrange(0, len(words))] + words[random.randrange(0, len(words))]
        password = words[random.randrange(0, len(words))] + str(random.randrange(0, 9999))
    else:
        username = words[random.randrange(0, len(words))] + str(random.randrange(0, 9999))
        password = words[random.randrange(0, len(words))] + str(random.randrange(0, 9999))

    if username in usedusernames:                                                                           # Check for duplicate username entries
        continue
    else:
        userdata.append([u, username, password])
        usedusernames.append(username)
        u += 1

print('User data compiled with length of:', len(userdata))                                                  # Print complete statement
print(userdata[1])

with open('useraccounts.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in userdata:
        csv_writer.writerow(row)



# Creating the posts CSV
postdata = [['postid', 'rating', 'timeofpost', 'likes', 'userid', 'songid']]

for i in range(5000):                                                                                       # Loop through and create 5000 posts
    timeofpost = str(random.randrange(1, 13)).zfill(2) + '/' + str(random.randrange(1, 28)) + '/' + str(random.randrange(2020, 2025)) + ' ' + str(random.randrange(0, 24)).zfill(2) + ':' + str(random.randrange(0, 60)).zfill(2)
    rating = random.randrange(0, 6)
    likes = random.randrange(0, 750)
    postuserid = random.randrange(0, 1250)                                                                  # Generate a random user id
    postsongid = songid[random.randrange(len(songid))]                                                      # Generate a random song id

    postdata.append([i, rating, timeofpost, likes, postuserid, postsongid])

print('Post data compiled with length of:', len(postdata))                                                  # Print complete statement
print(postdata[1])

with open('posts.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in postdata:
        csv_writer.writerow(row)



# Creating the tags CSV
tagdata = [['tagid', 'tagname']]

tags = ['Happy', 'Sad', 'Hype', 'Party', 'Loud', 'Love', 'Angry']                                           # Basic tags for now

for i in range(len(tags)):                                                                                  # Loop through all tags
    tagdata.append([i, tags[i]])

print('Tag data compiled with length of:', len(tagdata))                                                    # Print complete statement
print(tagdata[1])

with open('tags.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in tagdata:
        csv_writer.writerow(row)



# RELATION TABLES
# Creating the listening history CSV
listeninghistorydata = [['userid', 'songid']]

for i in range(1250):                                                                                       # Loop through all users
    for j in range(random.randrange(10, 51)):                                                               # Loop through random amount of songs from 10-50
        user = i                                                                                            # Obtain user ID
        song = songid[random.randrange(0, len(songid))]                                                     # Pick a random song ID

        if [user, song] not in listeninghistorydata:                                                        # Ensure no duplicates
            listeninghistorydata.append([user, song])

print('Listening history data compiled with length of:', len(listeninghistorydata))                         # Print complete statement
print(listeninghistorydata[1])

with open('listeninghistories.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in listeninghistorydata:
        csv_writer.writerow(row)



# Creating the has songs CSV
hassongsdata = [['artistid', 'songid']]

for i in range(len(songid)):
    artistlist = artistid[i]                                                                                # Obtain artist list for current song
    currsong = songid[i]                                                                                    # Obtain current song

    for artist in artistlist:                                                                               # Loop through all artists on current song
        if [artist, currsong] not in hassongsdata:                                                          # Check if artist song combination has been stored already
            hassongsdata.append([artist, currsong])

print('Has Song data compiled with length of:', len(hassongsdata))                                          # Print complete statement
print(hassongsdata[1])

with open('hassongs.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in hassongsdata:
        csv_writer.writerow(row)



# Creating the friends CSV
friendsdata = [['userid1', 'userid2']]

for i in range(5000):
    user1 = random.randrange(0, 1250)                                                                       # Select first user
    user2 = random.randrange(0, 1250)                                                                       # Select second user

    if ([user1, user2] not in friendsdata and [user2, user1] not in friendsdata and user1 != user2):        # Check for duplicates and self friending
        friendsdata.append([user1, user2])

print('Friends data compiled with length of:', len(friendsdata))                                            # Print complete statement
print(friendsdata[1])

with open('friends.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in friendsdata:
        csv_writer.writerow(row)


# Creating the create CSV
createdata = [['postid', 'tagid']]

for i in range(len(postdata) - 1):                                                                          # Loop through posts
    post = i                                                                                                # Select post by ID
    tag = tags[random.randrange(0, len(tags))]                                                              # Select random tag

    createdata.append([post, tag])

print('Create data compiled with length of:', len(createdata))                                              # Print complete statement
print(createdata[1])

with open('creates.csv', 'w', newline='') as csvfile:                                                         
    csv_writer = csv.writer(csvfile)

    # Write data to CSV
    for row in createdata:
        csv_writer.writerow(row)