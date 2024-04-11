
# **ILLINI HARMONICS**
# **Problem Track 1.2**

## **Explain your assumptions for each entity and relationship in your model. Discuss why you've modeled something as an entity rather than an attribute of another entity. Describe the cardinality of relationships, like why a student is linked to only one advisor. These assumptions might come from customer requirements or application constraints. Please clarify them.**

General:
In general, we aimed to create entities for sets of data easily grouped together. Additionally, any sets with many to many relations were forced into entities as well. 

User Accounts:
This entity exists to hold all of the relevant user data. It works best as an entity due to the inherent restriction that each user will only be responsible for one set of account data. 
User Accounts is only represented through 1 to many relationships with the Posts and Songs entities. Every Post must correspond to exactly one User Account, and each Song is only present once in the relation of Listening History between Songs and User Account.

Posts:
This entity holds all of the data relating to a single review post. Our application requires that each post contains several specific attributes like the rating, time of post, and tags which should be unique. Posts are connected to User Accounts and Songs through many to one relationships since our application guarantees that a post can only represent one User and one Song. However, many different reviews may be made by one user or may reference one song.

Songs:
The Songs entity contains data pertinent to the review and recommendation services provided by our application. This must be an entity due to the quantity of information necessary for each Song. Additionally, Songs are related to User Accounts using a 1 to 1 relation on Listening History, a 1 to many relation to Posts, and a many to many relation on tags. We assume that one User will have exactly one Listening History. We also assume that each Post will only correspond to exactly one Song, but there could be many unique Posts referencing the same song. Finally, each Song can be associated with many tags.

Tags:
Originally, we were going to use Tags as an attribute of both Songs and Posts. However, due to the many to many relations between these, Tags must become an entity. If it was just an attribute, we would have to use large tuples to store all of the Tags for a single entity which is both inconvenient and suboptimal. 

Artists:
The Artists entity is necessary to contain information which could be used for sorting or recommendations. The Artists table is linked to the Songs table in a many to many relationship because each song could have multiple artists and every artist could have multiple songs. 

Create:
The Create entity is an entity that relates both Posts and Tags, where the user-created posts may tag a song according to a tag from the Tags table. Thus, the relation is drawn that the post creates a new tag, or multiple tags, for the song that is contained in it.

Friends:
The Friends entity relates User Accounts to itself, as some users may store other users as friends that you can view feed from.

Has_songs:
The Has_song relation relates Artists and Songs as music artists have a list of songs that belong to them and are authored by them, this allows for our website to display both the author and related song at once for things such as posts or a music directory.

Listening_History:
The Listening_History relation relates User_Accounts to Songs, as users have a list of songs that are going to be retrieved from the Spotify API that they've listened to. This retrieved list will then be converted and stored through this relation.




## **Normalize your database. Apply BCNF or 3NF to your schema or show that your schema adheres to one of these normal forms. Describe why you choose to use BCNF vs 3NF.**
	
Since our dataset is extremely large, the most important priority is to reduce redundancy. In our project, redundant keys may heavily impact performance. Additionally, we have intentionally chosen entities and dependencies which will always be lossless. So, the optimal normalization for us is the BCNF normalization. With BCNF, we will focus on eliminating all unnecessary FDs and maximize the efficiency and performance of our database.


FDs:
Userid -> username, password

Artistid -> artistname, genre

Postid -> rating, timeofpost, likes

Tagid -> tagname

Songid -> songname, length, popularity


All of our functional dependencies satisfy the BCNF conditions because each key on the left side is a candidate key. These keys can be used to obtain all necessary information, meaning that there are no troublesome FDs, and our design meets BCNF criteria.




## **Convert your conceptual database design (ER/UML) to the logical design (relational schema). Note that a relational schema is NOT an SQL DDL command.**

Table-UserAccounts(userid:INT [PK], username:VARCHAR(255), password:VARCHAR(255))

Table-Posts(postid:INT [PK], rating:INT, timeofpost:VARCHAR(20), likes:INT, userid:VARCHAR(20) [FK to UserAccounts.userid], songid:VARCHAR(50) [FK to Songs.songid])

Table-Tags(tagid:INT [PK], tagname:VARCHAR(20))

Table-Songs(songid:VARCHAR(50) [PK], songname:VARCHAR(255), length:INT, popularity:INT)

Table-Artists(artistid:VARCHAR(50) [PK], artistname:VARCHAR(255), genre:VARCHAR(20))

Table-Create(postid:INT [FK to Posts.postid], tagid:INT [FK to Tags.tagid] (postid, tagid [PK])

Table-Listening_History(userid:INT [FK to UserAccounts.userid], songid:VARCHAR(50) [FK to Songs.songid] (userid, songid [PK])

Table-Friends(userid:INT [FK to UserAccounts.userid], userid:INT [FK to UserAccounts.userid] (userid, userid[PK])

Table-Has_Songs(artistid:VARCHAR(50) [FK to Artists.artistid], songid:VARCHAR(50) [FK to Songs.songid] (artistid, songid[PK])
