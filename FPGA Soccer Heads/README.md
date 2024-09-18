# FPGA Soccer Heads

**Description:**

This project recreated the classic flash game of Soccer Heads using SystemVerilog and C onto a Microblaze FGPA board. This game involves two player modules, one controlled by the user and one by an AI program. 
The two player modules play off in a three minute round of 2D soccer, which ends when the real-time timer is over or when one player scored nine goals. Recreating this game required implementing: 

* Analog VGA signal conversion to digital HDMI for display device connection.
* SPI protocols for connecting peripheral devices such as the keyboard used to control the player modules.
* A physics system for gravity and acceleration, used for both players and the ball.
* Menus with a finite state machine that also controlled the overall match states.
* Collision detection with the ball and goals, alongside game boundaries and other objects.
* Sophisticated sprite drawing and animation creation.
* AI capable of player-like movement.

**Included Files:**

1. ____ - ___.

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

**FPGA Block Designs:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/9b220716-2b3e-4145-8312-4b73530d2de9" alt="TopLevelLeft"> 
</p>

<p align="center">  
  Figure 1. Top level design left side.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/083c600f-1ab3-45bc-86c9-7cb9778eb19f" alt="TopLevelMiddle">
</p>

<p align="center">
  Figure 2. Top level design middle.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/747cc01b-b5b5-4547-8b86-ba8d3daaa4c0" alt="TopLevelRight">
</p>

<p align="center">
  Figure 3. Top level design right side.
</p>
