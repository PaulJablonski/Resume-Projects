from PIL import ImageOps, Image
import numpy as np
import joblib
from PyQt5.QtWidgets import QApplication, QMainWindow, QGraphicsScene, QGraphicsPixmapItem
from PyQt5.uic import loadUi
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QPainter, QPixmap, QPen, QColor, QBrush
import os, tempfile

import sys
import scipy.signal as signal
from numpy import genfromtxt

from sklearn import svm
from sklearn.utils import shuffle

# From PythonImplementation import kernelizeMass
horizKernel = np.array([[-1, 0, 1],
                        [-2, 0, 2],
                        [-1, 0, 1]])

vertKernel = np.array([[-1, -2, -1],
                       [0, 0, 0],
                       [1, 2, 1]])

diagKernel = np.array([[0, 1, 2],
                       [-1, 0, 1],
                       [-2, -1, 0]])

def convolve_2d(image, kernel):
    result = signal.convolve2d(image, kernel, 'same')
    result[result < 0] = 0
    return result

def kernelizeSingle(data):
    featureVectorList = [] # Create empty list to store each sample's features

    meanFeature = np.mean(data)
    stdFeature = np.std(data)
    horizFeatures = convolve_2d(data, horizKernel) # Convolve horizontal kernel with image
    vertFeatures = convolve_2d(data, vertKernel) # Convolve vertical kernel with image
    diagFeatures = convolve_2d(data, diagKernel) # Convolve vertical kernel with image

    totalFeatures = np.concatenate([meanFeature.flatten(), stdFeature.flatten(), horizFeatures.flatten(), vertFeatures.flatten(), diagFeatures.flatten()]) # Flatten and combine kernel convolutions
    totalFeatures = (totalFeatures - np.mean(totalFeatures)) / np.std(totalFeatures) # Normalize features

    featureVectorList.append(totalFeatures)

    featuremap = np.vstack(featureVectorList) # Stack total features of each image into 2D array
    return featuremap

# Create dictionary for labels
values = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '99', 
          'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
          'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

label_dict = {
    '[{}]'.format(idx) : values[idx] for idx in range(0, 63)
}

# Import model from joblib
svmModel = joblib.load('svmModel.pkl')

# Preprocess image
def preprocess(image_path):
    image = Image.open(image_path) # Open image path
    
    grayscale = ImageOps.grayscale(image) # Make image grayscale
    resized = grayscale.resize((28,28)) # Resize to 28x28
    imageArray = np.array(resized) # Make into numpy array
    imageArray = np.full((28, 28), 255) - imageArray # Convert values to those used in Emnist
    # print(imageArray) # Print test
    imageArray = centerImage(imageArray)

    featuremap = kernelizeSingle(imageArray) # Kernelize the input array
    return featuremap # Return feature map

# Center image function
def centerImage(imageArray):
    nonzero = np.nonzero(imageArray) # Determine nonzero indices
    centroidY = np.mean(nonzero[0]) # Find center of mass
    centroidX = np.mean(nonzero[1]) # Find center of mass

    shiftY = 14 - centroidY # Shift value for Y
    shiftX = 14 - centroidX # Shift value for X

    centReturn = np.roll(imageArray, int(shiftY), axis = 0)
    centReturn = np.roll(centReturn, int(shiftX), axis = 1)

    return centReturn

# Classify image function
def classify(image):
    processed = preprocess(image) # Use the preprocessing function on image
    pred = svmModel.predict(processed) # Predict using the preprocessed feature map
    return pred # Return prediction

# Create front-end app
class MainWindow(QMainWindow):
    # Initialization
    def __init__(self):
        super().__init__()
        loadUi('AppUI.ui', self) # Load the UI file

        # Create drawing canvas
        self.scene = QGraphicsScene(self)
        self.pixmap = QPixmap(280, 280)
        self.pixmap.fill(Qt.white)
        self.pen = QPen(QBrush(QColor(0, 0, 0, 80)), 25, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
        self.drawing = False
        self.lastPoint = None

        self.Canvas.setScene(self.scene)
        self.updatePixmap()

        # Create mouse events for canvas
        self.Canvas.mousePressEvent = self.mousePressEvent
        self.Canvas.mouseMoveEvent = self.mouseMoveEvent
        self.Canvas.mouseReleaseEvent = self.mouseReleaseEvent

        # Create buttons
        self.Execute.clicked.connect(self.predict)
        self.Clear.clicked.connect(self.clearCanvas)

    # Mouse press function / event
    def mousePressEvent(self, event):
        if (event.button() == Qt.LeftButton):
            self.lastPoint = event.pos()
            self.drawing = True
            # print('Mouse Pressed')
        
    # Mouse move function / event
    def mouseMoveEvent(self, event):
        if (self.drawing):
            painter = QPainter(self.pixmap)
            painter.setPen(self.pen)
            painter.drawLine(self.lastPoint, event.pos())
            self.lastPoint = event.pos()
            self.updatePixmap()
            # print('Mouse Moved')
            

    # Mouse release function / event
    def mouseReleaseEvent(self, event):
        if (event.button() == Qt.LeftButton and self.drawing):
            self.drawing = False
            # print('Mouse Released')

    # Update and display pixmap
    def updatePixmap(self):
        item = QGraphicsPixmapItem(self.pixmap)
        self.scene.clear()
        self.scene.addItem(item)
        # print('Line drawn')

    # Clear the pixmap and canvas
    def clearCanvas(self):
        self.pixmap.fill(Qt.white)
        self.updatePixmap()

    # Prediction function
    def predict(self):
        # Create a temp file for the image
        temp_file, image_path = tempfile.mkstemp(suffix='.png')
        os.close(temp_file)
        
        # Convert graphics scene to an image
        image = self.pixmap.toImage()
        image.save(image_path)

        # Preprocess and predict from image
        prediction = classify(image_path)

        # Display value in label
        self.PredictionValue.setText(label_dict[str(prediction)])
        print('Value Predicted as: ', label_dict[str(prediction)])


if __name__ == "__main__":
    print('Loading UI...')
    
    app = QApplication(sys.argv)
    mainWindow = MainWindow()
    mainWindow.show()
    sys.exit(app.exec_())
