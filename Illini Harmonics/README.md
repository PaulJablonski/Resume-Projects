# Illini Harmonics

**Description:**

This project involved creating a GCP hosted website that allows users to share their listening history with others through a simple rating-based system. Data was handled through mySQL on a GCP database, whereas the frontend was developed through React and Node.js utilizing CSS, TS, and JS. User, song, and artist data was additionally gathered through the Spotify API and a Python script that populated the initial SQL database with usable information.

Users are capable of registering accounts, logging in, and creating posts on the site. Posts contain information regarding a song, artist, and designated rating. Where the former two attributes contain pages of their own that present all stored artist and song data on the database. SQL queries, stored procedures, and triggers are utilized in the upkeep of data to ensure posts may be inserted, deleted, and edited. Furthermore, SQL stored procedures enable the site to ensure that a login or signup query is allowable with the usernames and passwords stored on the database.

**Included Directories:**


**Instructions for Running:**
1. Download the distributed zipped file from the drive link as follows:

   https://drive.google.com/file/d/1kRmTPqloMmKDpv7__bXW53tQu9zKoE_s/view?usp=sharing
2. Unzip the file, and setup Node.js alongside React on your local device.
3. Due to the GCP shell not being public and limited in access, you may run the react app from the "Client" directory in the zipped folder. Redirect the Bash terminal to "Client" and utilize "npm run dev" in order to start the local website without data.

Note: This does not include all of the data as presented in the example usage below, thus it runs only as the front-end framework.

**Webpage Example Usage:**

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/c86f2006-6f60-48ae-b067-78a93dde382d">
</p>

<p align="center">  
  Figure 1. Home page of Illini Harmonics.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/5347612e-5368-44ce-a672-1da8bc464269">
</p>

<p align="center">  
  Figure 2. Music page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/e42c9614-7c6e-4b81-9ffc-8cd42e742d15">
</p>

<p align="center">  
  Figure 3. Artist page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/29815180-18bf-4504-ad48-44b7bcabb94c">
</p>

<p align="center">  
  Figure 4. Posts page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/81390248-69c4-463d-a602-3f06dea622fa">
</p>

<p align="center">  
  Figure 5. Friends page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/535b739d-8970-4ddc-bff5-95f5bf1f6876">
</p>

<p align="center">  
  Figure 6. Create a post page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/e2b8e211-ea08-4e50-b96f-0e3fb0002d27">
</p>

<p align="center">  
  Figure 7. Login page.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/8ce28ca8-d2bc-4b46-82b9-82d4b096011a">
</p>

<p align="center">  
  Figure 8. Signup page.
</p>

**Database Example Usage:**

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/678100b5-d46c-40a7-a006-3965a676e0b5">
</p>

<p align="center">  
  Figure 9. MySQL query presenting all data tables in database.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/9efd695c-7487-4573-af45-ff533d43e170">
</p>

<p align="center">  
  Figure 10. MySQL query displaying most popular songs on Illini Harmonics.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/032de7b8-d03c-47cb-af69-812642c66f9f">
</p>

<p align="center">  
  Figure 11. MySQL query displaying highest rating songs.
</p>
