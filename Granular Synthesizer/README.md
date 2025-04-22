# Granular Synthesizer

**Description:**

This project implements a real-time granular synthesis plugin using the JUCE C++ framework. Originally intended for FPGA deployment, the project pivoted to a software solution to prioritize flexibility, usability, and rapid iteration. The resulting VST plugin functions as a DAW-compatible tool that deconstructs incoming audio into micro-sound grains and resynthesizes them into new textures by controlling grain size, timing, pitch, density, and randomness.

Each grain is generated from a circular audio buffer and then processed individually with pitch shifting, time-stretching, and envelope shaping (via a Hann window). Grains are dynamically layered based on user-configurable parameters to produce shimmering textures, time-stretched soundscapes, and glitched artifacts. The plugin supports real-time control via a graphical user interface and is fully automatable within any compatible DAW environment such as Ableton Live or FL Studio.

Key Features:

* Grain size, pitch shift, and density control
* Real-time audio buffer slicing and playback
* Grain randomization for natural, non-repetitive textures
* Time stretching without pitch change
* Hann window envelope smoothing
* Dry/wet signal blending
* Fully automatable parameter controls in DAW
* JUCE-based GUI with slider controls and tooltips


**Included Files:**

1. GranularSynthOverview.pdf - A 12-page comprehensive final report regarding this project / research and all technical details necessary to understand its purpose and functionality.
2. PluginProcessor.cpp - Implements the audio processing logic including buffer handling, grain scheduling, interpolation, and dry/wet mixing. This is the core of the DSP pipeline.
3. PluginProcessor.h - Declares the main audio processor class, grain structure, parameters, and utility functions used throughout the plugin.
4. PluginEditor.cpp - Defines and arranges the graphical interface components including rotary sliders and tooltips, and connects them to the backend parameter state.
5. PluginEditor.h - Declares the plugin editor class and its GUI components, including layout and control bindings for interaction within the DAW environment.
6. GranularSynthVST.vst3 - Plugin file that needs to be added to Windows VST folder in order to utilize in DAW.

**Instructions for Running:**
1. Download the "FinalAndroid" folder for testing on a local Android device, or download the "PythonPrototype.py" file if testing on a desktop device. Note that the former performs better and has more manual optimizations than the prototype.
2. If testing Android version, open the folder in the latest version of Android Studio and allow the Gradle files to build. Then connect your device via USB, and press the run button to test.
3. If testing the prototype, simply load the prototype file in the IDE of your choice and run the file, make sure all libraries are installed.

**Example Usage:**
