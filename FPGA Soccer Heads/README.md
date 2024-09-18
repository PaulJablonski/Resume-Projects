# FPGA Soccer Heads

**Description:**

This project recreated the classic flash game of Soccer Heads using SystemVerilog and C onto a Microblaze FGPA board. This game involves two player modules, one controlled by the user and one by an AI program. 
The two player modules play off in a three minute round of 2D soccer, which ends when the real-time timer is over or when one player scored nine goals. Recreating this game required implementing: 

* VGA controller for Mode X graphics and conversion from analog to HDMI.
* SPI protocols for connecting peripheral devices such as the keyboard used to control the player modules.
* IP module creation and arrangement, newly created IP modules primarily served for block memory and ROMs.
* A physics system for gravity and acceleration, used for both players and the ball.
* Menus with a finite state machine module that also controlled the overall match states.
* Scorekeeping through collisions that displayed on both the FPGA hex display and HDMI display.
* Sophisticated sprite drawing and animation creation.
* AI module capable of player-like movement.

**Included Files:**

1. Color_Mapper.sv - Contains variables for player heights, widths, positional location, and movements, in addition to the same for the goals and the ball. This allows it to draw the sprites properly based on the location of each individual object and the DrawX and DrawY inputs.
2. FSM.sv - Contains inputs from the keyboard GPIO alongside the scoreboard, which tells the state machine when the game time is over. Outputs are then included for the current game mode, whether the score should be wiped, and the current state at hand.
3. GoalPost.sv - Contains an input signal for LR, which indicates whether it is a left or right goal, which will affect the output positional variables.
4. Player1.sv - Outputs positional variables for the player based on keyboard inputs and current location, which is then used in the color mapper to display the player and also to interact with the ball.
5. PlayerAI.sv - Functions similar to the user-controlled player module, except it doesn’t utilize any keyboard inputs, instead it has an internal program that will determine movements based on the ball’s positional inputs.
6. Scoreboard.sv - Uses clock division principles to convert the 25 MHz clock from the VGA controller into a 1 Hz clock used to count down the number of seconds from 180. Outputs the TimeOver signal once the game time is exhausted.
7. VGA_controller.sv - Contains signals for handling the display and its implementation. Signals such as hs and vs ensure that the module is synchronizing the horizontal and vertical aspects of the display with respect to the inputs provided. Similarly, a pixel_clk is provided, which coincides with internal signals that serve as counters for both the vertical and horizontal synchronization of the display.
8. ball.sv - Contains the logic for the ball, alongside its acceleration and movement in correspondence to the display boundaries. Inputs are fed in from both player modules and the goals in order to handle collision.
9. hex.sv -  Consists of four generated submodules that convert nibbles of 4 bit hexadecimal characters into characters on a seven segment display hex_seg. The hex driver itself has additional functionality for resetting its values on the positive edge of its Clk input.
10. mb_usb_hdmi_top.sv - Top level file that takes in inputs from clock, reset signal, GPIOs, USB, and UART modules within the block design. This module then outputs signals relevant to HDMI signaling for the VGA display connection. Modules are instantiated from all other listed parts in this report, this includes: Hexdrivers, an updated block design, clocking wizard, VGA to HDMI converter, a ball instance, the players, a color mapper, the FSM, and more.
11. ROM Files - Block memory generated IPs that serve as the ROM for various assets, they store the indices from the generated and corresponding COE file, which inevitably is called to determine color mapping.
12. Palette Files - Contain the color palettes for individual sprites and text.

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

**Block Diagrams:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/a35c9a53-b45c-4767-b3a1-1aed4b98e603" alt="BD1"> 
</p>

<p align="center">  
  Figure 6. Overall block diagram for project and toplevel.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/8905ec7a-c980-4510-b3a1-c886fd9d791f" alt="BD2"> 
</p>

<p align="center">  
  Figure 7. State transition diagram for game state and menus.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/d805b733-0a63-417d-8f94-c3e9cc33f31f" alt="BD3"> 
</p>

<p align="center">  
  Figure 8. IP diagram for Microblaze configuration.
</p>

**Key RTL Diagrams:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/c7204bd1-6323-42c3-83b2-535e0ffd4cf0" alt="RTL1"> 
</p>

<p align="center">  
  Figure 9. RTL diagram for the VGA controller module.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/95f9ae38-9b0c-431e-b47d-42e86d226d5a" alt="RTL2"> 
</p>

<p align="center">  
  Figure 10. RTL diagram for player one module.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/40493adb-dfc0-4038-b80f-18bf76616e7c" alt="RTL3"> 
</p>

<p align="center">  
  Figure 11. RTL diagram for the finite state machine.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7a200a03-19b6-4705-bcfd-fe89efe9d6d0" alt="RTL4"> 
</p>

<p align="center">  
  Figure 12. RTL diagram for hex display module.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/15851a51-a521-41b3-9ac6-fdaaafbcb34d" alt="RTL5"> 
</p>

<p align="center">  
  Figure 13. RTL diagram for color mapper module.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/29e48dd1-3e1e-4ff7-b896-fa4f3ad2b8f1" alt="RTL6"> 
</p>

<p align="center">  
  Figure 14. RTL diagram for physics-based ball module.
</p>

**FPGA Block Designs:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/9b220716-2b3e-4145-8312-4b73530d2de9" alt="TopLevelLeft"> 
</p>

<p align="center">  
  Figure 15. Top level design left side.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/083c600f-1ab3-45bc-86c9-7cb9778eb19f" alt="TopLevelMiddle">
</p>

<p align="center">
  Figure 16. Top level design middle.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/747cc01b-b5b5-4547-8b86-ba8d3daaa4c0" alt="TopLevelRight">
</p>

<p align="center">
  Figure 17. Top level design right side.
</p>
