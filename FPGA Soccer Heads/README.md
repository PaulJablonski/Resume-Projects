# FPGA Soccer Heads

**Description:**

This project recreated the classic flash game of Soccer Heads using SystemVerilog and C onto a Microblaze FGPA board. This game involves two player modules, one controlled by the user and one by an AI program. 
The two player modules play off in a three minute round of 2D soccer, which ends when the real-time timer is over or when one player scored nine goals. Recreating this game required implementing: 

* SPI protocols for connecting peripheral devices such as the keyboard used to control the player modules.
* A physics system for gravity and acceleration, used for both players and the ball.
* Menus with a finite state machine that also controlled the overall match states.
* Collision detection with the ball and goals, alongside game boundaries and other objects.
* Sophisticated sprite drawing and animation creation.
* AI capable of player-like movement.

**Included Files:**

1. ____ - ___.

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

**Example Usage:**
