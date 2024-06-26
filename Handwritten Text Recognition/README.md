# Handwritten Text Recognition

**Description:**

The project contained within this folder displays an implementation of recognizing handwritten text. This is achieved through training a linear SVM model on training data convoluted 
with various identifying kernels. The kernels are utilized to detect edges and lines within the 28x28 text images fed to the model. 

Following convolution and training, various functions are implemented in order to make sure that new input data may be preprocessed, convolved in two dimensions, and classified by the
model. Finally, a user interface was created using a front end library PyQT, which enabled the user to input their own drawn text. The user input was then tested through the model and classified 
with an accuracy higher than 85%. 

**Included Files:**

1. App.py - Contains the code for the creation of the front end app, this includes creating a UI, functions for processing the UI's input, and labelling the resulting outputs of the trained model.
2. App.spec - Created from PyInstaller in order to manage the compiling of the final executable.
3. AppUI.ui - Created with PyQT in order to manage signals for the user interface, also contains the general design itself.
4. AppUIPy.py - Contains the python version of the AppUI.ui file, includes instantiations of UI components.
5. PythonImplementation.py - Creates the training model that is used within this project. Includes functions for kernelization of data, alongside the importation of a dataset from EMNIST. The model is exported from here and imported into App.py for user interface use.
6. svmModel.pkl (not included directly) - The model file that is exported from the PythonImplementation.py file. This file must be downloaded from the drive link included below as its file size exceeds that allowed in GitHub.
7. App.exe (not included directly) - The executable file that is created using PyInstaller, this file must also be downloaded as part of a zip from the google drive link.

**Instructions for Running:**

1. Download the distribution zipped file from the drive link as follows:
   
   https://drive.google.com/file/d/1Rc5vIrLi8Is2297xHjfs9RwDmQ2-k3Wf/view?usp=sharing
2. Unzip the file and run the HandwrittenRecognizer.exe file either directly or through a CMD instance (Note: this may take up to a minute to fully load).
3. Test the model! Draw any single character on the blank canvas, predict your drawing or clear your result and try again. Keep in mind that the model recenters any drawing to account for error, but DOES NOT scale drawings. This means that your character drawing should be appropriately large for the canvas for the model to properly classify it. If errors are encountered, try keeping the console open during loading the program.

**Example Usage:**

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/f74d8f76-8084-464a-b1f7-944f7c988b39" alt="HandwrittenExample3">
</p>

<p align="center">  
  Figure 1. Console loads the UI of the program.
</p>

<p align="center">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/d5aba49c-e7a1-4cc4-a2e5-1af51f7db88a" alt="HandwrittenExample2">
  <img src="https://github.com/PaulJablonski/Resume-Projects/assets/148725115/d67baf53-f7ce-4867-a53d-477ab0b1d3de" alt="HandwrittenExample1">
</p>

<p align="center">
  Figure 2. UI interface before and after user draws a character and runs program.
</p>

