# Laser & Voice Assisted Cat Toy

**Description:**

This project involves a mouse-like toy, which has been seen before, but is now refined with multiple more advanced systems. The primary sensors consist of a distance measuring laser, a vibrational sensor, and a microphone in tandem with a miniature speaker. The first two serve in engaging the cat and improving both longevity and noise generation, whereas the final sensor system vastly improves user interaction through various voice commands. More specifically, the laser can be utilized to avoid collisions and detect ahead of the mouse, sparking movement changes that are more realistic for an animal. The vibrational sensor furthermore detects when the toy has been caught, which either dispenses a treat or plays dead depending on the toy's state. Finally, the aforementioned voice commands allow for the user to locate the toy at any time, or manually activate the toy itself without a need for physical contact.

Physically speaking, the non-rolling shape of a mouse also allows for more rigid and controllable movement. This is important for stabilizing the toy’s primary sensors and allows for greater reactivity to its environment and consequently less noisy behavior. The sensors as mentioned also are accompanied by several motorized and more physical systems. A moving tail is used to mimic the more excitatory behaviors of prey, making it more engaging than a typical toy's static tail. This is accompanied by faster motorized movements and more realistic movement states as is regulated by a microcontroller and stepper motor-driven wheel system. Further speaking, a latch can be controlled through a servo and used for dispensing treats from the back of the toy upon being caught. And finally, a rechargeable lithium ion battery is incorporated and regulated by a circuit protection system for easy re-usability.
 
The toy itself comprises four total subsystems:

* Sensor subsystem, including a VL53L1X laser sensor, an SW-420 vibration sensor, and a KY-038 sound sensor.
* Microcontroller subsystem, comprised of the ATmega328p, taking inputs from the sensor subsystem, and outputting to the motors and outputs subsystem.
* Motors and outputs subsystem, consisting of two Nema 17 short body motors, two SG90 servo motors, two A4988 stepper drivers, a PAM8302 sound amplifier, and one JSM 2.5mm speaker.
* Power subsystem, which has a 11.1V lithium-ion battery, three AZ1117 voltage regulators, and a CYT1091 button.

**Included Files:**

1. CAD - Includes all CAD files for the cat toy, including both versions of its main body, top and bottom panels, and its separate cover for treat dispensing that attaches to the toy's treat servo motor.
2. CatToyOverview.pdf - A comprehensive 26-page report that displays the results of this project, alongside more in-depth technical descriptions for each subsystem.
3. LaserPCB.kicad_pcb - KiCAD PCB file for the front-mounted PCB that contains the laser sensor.
4. MainPCB.kicad_pcb - KiCAD PCB file for the main system PCB that contains all other sensors and outputs, alongside the microcontroller and additional connections.
5. MainPCB.kicad_sch - KiCAD schematic file that compliments and provides the layed-out prototype for the aforementioned main PCB.
6. ToyFirmware.ino - Arduino code file that contains all states and operations of the toy's programmed behavior. This file serves as its primary state machine and is loaded onto the final version's ATmega328p controller.

**Video Overview:**

<div align="center" style="position: relative; display: inline-block;">
  <a href="https://www.youtube.com/watch?v=QRSZpgy2Lqo" title="Click to Watch Laser And Voice Assisted Cat Toy">
    <img src="http://img.youtube.com/vi/QRSZpgy2Lqo/0.jpg" alt="Video" style="width: 60%; max-width: 400px;">
  </a>
</div>

**Relevant Figures:**

<p align="center">
  <img src="https://github.com/user-attachments/assets/37ccaa5f-9542-4421-9ea8-11b387450108" alt="CT1" width="50%"> 
</p>

<p align="center">  
  Figure 1. Initial concept sketch for the cat toy, including all intended functionalities.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/bf1b8298-bf37-4ec9-9d6a-2a84f258c3b1" alt="CT2" width="50%"> 
</p>

<p align="center">  
  Figure 2. Initial concept render of disassembled front and back view of the toy.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/4a11b680-300e-405c-b774-f59a1829452c" alt="CT3" width="70%"> 
</p>

<p align="center">  
  Figure 3. Finalized CAD model of the toy alongside its interior.
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6f4876cd-b505-4303-bb59-6b5966c7aeed" alt="CT3" width="70%"> 
</p>

<p align="center">  
  Figure 4. Assembly of the final product, including buttons, sensors on the sides, holes for wheel mounts, power button, etc.
</p>
