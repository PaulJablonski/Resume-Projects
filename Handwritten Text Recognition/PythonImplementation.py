# Import libraries and functions
import numpy as np
from numpy import genfromtxt

from sklearn import svm
from sklearn.metrics import accuracy_score
from sklearn.utils import shuffle

from emnist import extract_training_samples
from emnist import extract_test_samples

import joblib

import scipy.signal as signal

# Begin preprocessing and extraction
digitTrainData, digitTrainLabels = extract_training_samples('digits')
letterTrainData, letterTrainLabels = extract_training_samples('letters')

digitTestData, digitTestLabels = extract_test_samples('digits')
letterTestData, letterTestLabels = extract_test_samples('letters')

# Add to the labels for letters in order to account for overlap
letterTrainLabels = np.full(letterTrainLabels.shape, 10) + letterTrainLabels
letterTestLabels = np.full(letterTestLabels.shape, 10) + letterTestLabels

# Combine both digits with letters and permute randomly with same seeding
trainData = np.concatenate([digitTrainData, letterTrainData])
trainLabels = np.concatenate([digitTrainLabels, letterTrainLabels])

testData = np.concatenate([digitTestData, letterTestData])
testLabels = np.concatenate([digitTestLabels, letterTestLabels])

trainData, trainLabels = shuffle(trainData, trainLabels)
testData, testLabels = shuffle(testData, testLabels)

# Create kernels and convolution function to extract feature maps
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

# Define function for convolving kernels with large amount of data
def kernelizeMass(data):
    dataSize = data.shape[0]
    featureVectorList = [] # Create empty list to store each sample's features

    for i in range(dataSize):
        meanFeature = np.mean(data[i])
        stdFeature = np.std(data[i])
        horizFeatures = convolve_2d(data[i], horizKernel) # Convolve horizontal kernel with image
        vertFeatures = convolve_2d(data[i], vertKernel) # Convolve vertical kernel with image
        diagFeatures = convolve_2d(data[i], diagKernel) # Convolve vertical kernel with image

        totalFeatures = np.concatenate([meanFeature.flatten(), stdFeature.flatten(), horizFeatures.flatten(), vertFeatures.flatten(), diagFeatures.flatten()]) # Flatten and combine kernel convolutions
        totalFeatures = (totalFeatures - np.mean(totalFeatures)) / np.std(totalFeatures) # Normalize features

        featureVectorList.append(totalFeatures)

    featuremap = np.vstack(featureVectorList) # Stack total features of each image into 2D array
    return featuremap

# Kernelize training data
kernTrainData = kernelizeMass(trainData[:25000])

# Create model to train
linearSVM = svm.SVC(kernel = 'rbf', C = 7.5)
linearSVM.fit(kernTrainData, trainLabels[:25000])

# Kernelize, predict test data, and report accuracy
kernTestData = kernelizeMass(testData[:1000])
testPred = linearSVM.predict(kernTestData[:1000])
print(accuracy_score(testLabels[:1000], testPred))

# Save to Pkl file to load into app script
joblib.dump(linearSVM, 'svmModel.pkl')

# Testing / Debugging
# trainKernelized = kernelizeMass(trainData[:10])
# print(trainKernelized[0][100:120])
# print(trainKernelized[0][170:190])
# print(trainKernelized.shape)