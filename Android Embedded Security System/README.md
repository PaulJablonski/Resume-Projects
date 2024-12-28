# Android Embedded Security System

**Description:**

This project created an easily-deployable and data-conservative Android system that can eliminate primary sources of storage waste. More specifically, this solution masks human subjects from the background of security footage through utilizing a calibration image with nobody in it. This calibration image is compared to live frames to determine differences in the foreground and the background - ultimately isolating the foreground. Rectangular object proposals are then bound for each isolated person in frame by creating a bounding box around edge clusters. This reduces the resolution of images being stored, as only the identified person and their cropped bounding box needs to be stored in the security system’s database. The key idea is avoiding the storage of entire frames, and instead just storing key information like human object proposals as often as possible.

Beyond this, the stored and cropped images of people are compared to live footage through using a Euclidean color distance measurement. This allows for people to be labeled uniquely, serving as an object identification system as well. Each cropped image is analyzed in near real-time, pre-storage, to determine the six primary colors present on the person. The color content of their clothing, skin, and hair, identified by these most frequent colors, are compared to already stored data to see if a label can be assigned to them. If no match is found, a new label is made, as evidently a new person has been identified. This label system is beneficial as such identification aides in security, as cross-referencing the same person in different footage can lead to stronger analysis, and also can reduce the time needed to find specific people in a large database of footage. 

The final implementation is divisible into the following general functionalities:

* A canny edge detection method to find initial edges in a very raw form
* A bit-masking algorithm that removes similarities between calibration image and live footage
* Edge grouping that combines edges based on orientations through a flood-fill algorithm
* Manual density-based clustering for finding bounding boxes of nearby edge groups and making proposals
* Manual k-means clustering functionality which finds the six most frequent colors in a proposal
* Euclidean distance color comparison that compares stored and new object proposals’ colors
* Extracted image storage in a folder, alongside color data storage in a CSV for object labeling


**Included Files:**

Note: All .java files listed below are also found within the "FinalAndroid" folder, and were simply copied here for ease of access. They contain the most important functionalities and implementations from this project.

1. FinalAndroid - Compiled and cleaned Android Studio folder. Contains all necessary files to run this security system program on a local Android device. Simply open this folder in Android Studio, build the project, and click the "run" button to test the software.
2. ImageData.java - Defines the image storage class for playback and image file management.
3. ImageProcessingUtils.java - Contains all image-processing related functions as part of the main digital signal processing pipeline. All of these functions are called in the next file.
4. MainActivity.java - Calls image processing functions and structures the main program and its functionality.
5. MetaData.java - Defines a metadata class for storing timestamp and image dimensional data.
6. Playback.java - Handles the functionality of the playback menu and image retrieval, allowing for proper display of stored images after main pipeline has been ran.
7. PythonPrototype.py - Python prototype implementation. This file's pipeline structure is similar to the final Android implementation, but varies as it uses a structured edge detection model, imports a DB-scan library, and imports a k-means algorithm. Whereas, the final Android version implements all of this manually, and uses OpenCV for canny edge detection.

**Instructions for Running:**
1. Download the "FinalAndroid" folder for testing on a local Android device, or download the "PythonPrototype.py" file if testing on a desktop device. Note that the former performs better and has more manual optimizations than the prototype.
2. If testing Android version, open the folder in the latest version of Android Studio and allow the Gradle files to build. Then connect your device via USB, and press the run button to test.
3. If testing the prototype, simply load the prototype file in the IDE of your choice and run the file, make sure all libraries are installed.

**Example Usage:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/04bbda36-5b07-4410-9a90-c6e6cefdf13e" alt="SH1"> 
</p>

<p align="center">  
  Figure 1. Sprite-drawn main menu, featuring background and three separate button / title sprites.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/d80842f3-149a-4fe9-91f1-2fc83a2092749" alt="SH2"> 
</p>

<p align="center">  
  Figure 2. Example of a game being played, with player, goal, and background sprites alongside the ball.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/c5541b6e-40c3-4d84-be44-0947ad72a6ae" alt="SH3"> 
  <img src="https://github.com/user-attachments/assets/35829eb3-0dc9-4c0d-bf67-49daec986bf1" alt="SH4"> 
</p>

<p align="center">  
  Figure 3. Player sprite animations.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/9a00e734-dec6-42df-9110-d580e5fd59fc" alt="SH5"> 
</p>

<p align="center">  
  Figure 4. Goal post sprite, where pink was removed during color mapping and sprite was inverted for memory saving.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f5675313-92cf-4874-9364-8a07df430baa" alt="SH6"> 
  <img src="https://github.com/user-attachments/assets/835047fc-b6da-45eb-9719-b358676e6c78" alt="SH7"> 
</p>

<p align="center">  
  Figure 5. Power-ups that were implemented into ‘Power Mode’, namely a temporary speed increase and goal size increase.
</p>
