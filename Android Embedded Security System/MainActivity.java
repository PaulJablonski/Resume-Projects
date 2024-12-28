// CODE WRITTEN BY PAUL JABLONSKI AND JUN HAYAKAWA
package com.ece420.finalproject;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.opencv.android.BaseLoaderCallback;
import org.opencv.android.CameraBridgeViewBase;
import org.opencv.android.LoaderCallbackInterface;
import org.opencv.android.OpenCVLoader;
import org.opencv.core.Mat;
import org.opencv.core.Point;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Scalar;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.opencv.core.Size;

public class MainActivity extends Activity implements CameraBridgeViewBase.CvCameraViewListener2 {

    static {
        System.loadLibrary("c++_shared");
        System.loadLibrary("opencv_core");
        System.loadLibrary("opencv_imgproc");
        System.loadLibrary("opencv_ximgproc");
    }

    private static final String TAG = "MainActivity";
    private ImageProcessingUtils imageProcessor;
    private Mat calibrationImage = null; // Calibration image

    // Declare OpenCV based camera view base
    private CameraBridgeViewBase mOpenCvCameraView;
    // Buffer variable for displaying output
    private Mat outputBuffer;
    private boolean shouldCaptureCalibrationFrame = false; // tracking calibration state

    public static Instant start;
    private boolean isRunning = false;

    // Add a variable to track camera direction
    private boolean isFrontCamera = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_main);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        ImageData.clearCache(this);
        // initialize imageprocessingutils
        imageProcessor = new ImageProcessingUtils(this);

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, 1);
        }

        // OpenCV Loader and Avoid using OpenCV Manager
        if (!OpenCVLoader.initDebug()) {
            Log.e(TAG, "OpenCVLoader.initDebug() not working.");
        } else {
            Log.d(TAG, "OpenCVLoader.initDebug() working.");
        }

        // Setup OpenCV Camera View
        mOpenCvCameraView = findViewById(R.id.opencv_camera_preview);
        if (mOpenCvCameraView != null) {
            mOpenCvCameraView.setCameraIndex(1); // Main camera
            mOpenCvCameraView.setVisibility(CameraBridgeViewBase.VISIBLE);
            mOpenCvCameraView.setCvCameraViewListener(this);
        } else {
            Log.e(TAG, "Camera view not found. Make sure R.id.opencv_camera_preview is correctly defined in the layout.");
        }

        // Start Button to start calibration process
        Button controlButton = findViewById(R.id.startButton);
        controlButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                shouldCaptureCalibrationFrame = true; // Set the flag to capture a new calibration frame
                Log.d(TAG, "Calibration button pressed.");
                isRunning = true;
            }
        });

        // Stop Button to stop calibration process
        Button stopButton = findViewById(R.id.stopButton);
        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                calibrationImage = null; // Set the calibration image to null to stop the process
                Log.d(TAG, "Stop button pressed. Calibration image reset.");
                isRunning = false;
            }
        });

        Button playbackButton = findViewById(R.id.playbackButton);
        playbackButton.setOnClickListener(v -> {
            // get time when user moved to playback window
            Instant stop = Instant.now();
            Duration elapsed = Duration.between(start, stop);
            ImageData.time += elapsed.toMillis();
            Intent intent = new Intent(MainActivity.this, Playback.class);
            startActivity(intent);
        });

        // Camera flip Button to switch front and rear camera usage
        Button flipCameraButton = findViewById(R.id.n);
        flipCameraButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Stop the camera before switching
                if (mOpenCvCameraView != null) {
                    mOpenCvCameraView.disableView();

                    // Toggle camera direction
                    isFrontCamera = !isFrontCamera;

                    // Set camera index based on the direction
                    // 1 is the main/back camera and 0 is the front camera
                    mOpenCvCameraView.setCameraIndex(isFrontCamera ? 0 : 1);

                    // Re-enable the camera view
                    mOpenCvCameraView.enableView();
                }
            }
        });

    }

    @Override
    protected void onStart() {
        super.onStart();
        // reset the timer each time the user enters the camera interface
        MainActivity.start = Instant.now();
        Log.d(TAG, "clock reset.");
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.enableView();
        if (!OpenCVLoader.initDebug()) {
            Log.d(TAG, "Internal OpenCV library not found. Using OpenCV Manager for initialization");
            OpenCVLoader.initAsync(OpenCVLoader.OPENCV_VERSION, this, mLoaderCallback);
        } else {
            Log.d(TAG, "OpenCV library found inside package. Using it!");
            mLoaderCallback.onManagerConnected(LoaderCallbackInterface.SUCCESS);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.disableView();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mOpenCvCameraView != null)
            mOpenCvCameraView.disableView();
        if (outputBuffer != null)
            outputBuffer.release();
    }

    private BaseLoaderCallback mLoaderCallback = new BaseLoaderCallback(this) {
        @Override
        public void onManagerConnected(int status) {
            switch (status) {
                case LoaderCallbackInterface.SUCCESS:
                    Log.i(TAG, "OpenCV loaded successfully");
                    if (mOpenCvCameraView != null) {
                        mOpenCvCameraView.enableView();
                    }
                    break;
                default:
                    super.onManagerConnected(status);
                    break;
            }
        }
    };

    // Handle permission result
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Camera permission granted.");
            } else {
                Log.e(TAG, "Camera permission denied.");
            }
        }
    }

    // OpenCV Camera Functionality Code
    @Override
    public void onCameraViewStarted(int width, int height) {
        Log.d(TAG, "Camera view started with resolution: " + width + "x" + height);
        outputBuffer = new Mat(); // Initialize buffer
    }

    @Override
    public void onCameraViewStopped() {
        Log.d(TAG, "Camera view stopped.");
        if (outputBuffer != null)
            outputBuffer.release(); // Release buffer
    }

    @Override
    public Mat onCameraFrame(CameraBridgeViewBase.CvCameraViewFrame inputFrame) {
        // Get the input camera frame
        Mat inputImage = inputFrame.rgba();

        // Downscale the image
        Mat downscaledImage = new Mat();
        Imgproc.resize(inputImage, downscaledImage, new Size(inputImage.cols() / 5, inputImage.rows() / 5));

        // Save a copy of the original image
        Mat originalImage = new Mat();
        Imgproc.cvtColor(downscaledImage, originalImage, Imgproc.COLOR_RGBA2RGB);

        // Check if a new calibration frame should be captured
        if (shouldCaptureCalibrationFrame) {
            if (calibrationImage != null) {
                calibrationImage.release(); // Release the previous calibration frame
            }
            calibrationImage = originalImage.clone(); // Clone the new calibration frame
            imageProcessor.resetBlurredCalibrationImage(); // Reset blurred calibration
            Log.d(TAG, "Calibration image captured.");

            //store the calibration image
            Mat calib_disp = new Mat();
            Imgproc.cvtColor(calibrationImage, calib_disp, Imgproc.COLOR_RGB2BGR);
            imageProcessor.saveImage(this, calib_disp, 0, 0, downscaledImage.cols(), downscaledImage.rows());
            // Reset the flag
            shouldCaptureCalibrationFrame = false;
        }


        // If no calibration image is available, just show the normal camera feed
        if (calibrationImage == null) {
            // Rescale the image back to display size
            Mat upscaledImage = new Mat();
            Imgproc.resize(originalImage, upscaledImage, new Size(inputImage.cols(), inputImage.rows()));

            // Release intermediate Mat objects to prevent memory leaks
            downscaledImage.release();
            originalImage.release();

            // Copy the upscaled image to the output buffer and return it
            if (outputBuffer != null) {
                outputBuffer.release(); // Release previous buffer to prevent memory leaks
            }
            upscaledImage.copyTo(outputBuffer);
            upscaledImage.release();

            return outputBuffer;
        }

        // Proceed with processing if a calibration image is available
        Mat processedImage = imageProcessor.processGreenScreen(originalImage, calibrationImage);
        Mat edges = imageProcessor.applyCannyEdgeDetection(processedImage, 50, 200);
        Mat orientations = imageProcessor.calculateOrientations(edges);
        List<int[]> edgeGroupCenters = imageProcessor.groupAllEdges(orientations);
        imageProcessor.clusterDrawSaveAndColor(edgeGroupCenters, originalImage, processedImage);
        List<Scalar> palette = generateRainbowPalette(edgeGroupCenters.size());

        for (int i = 0; i < edgeGroupCenters.size(); i++) {
            int[] pixel = edgeGroupCenters.get(i);
            Scalar color = palette.get(i % palette.size()); // Cycle through the palette

            int x = pixel[0];
            int y = pixel[1];
            if (x >= 0 && x < originalImage.rows() && y >= 0 && y < originalImage.cols()) {
                originalImage.put(x, y, color.val[0], color.val[1], color.val[2]);
            }
        }

        // Rescale the image back to display size
        Mat upscaledImage = new Mat();
        Imgproc.resize(originalImage, upscaledImage, new Size(inputImage.cols(), inputImage.rows()));

        Imgproc.putText(upscaledImage, "Elapsed Time: " + ImageData.time + " ms",
                new Point(50, 50), 1,
                1.0, new Scalar(255, 255, 255), 2);


        // Release intermediate Mat objects to prevent memory leaks
        processedImage.release();
        edges.release();
        orientations.release();
        downscaledImage.release();
        originalImage.release();

        // Copy the upscaled image to the output buffer and return it
        if (outputBuffer != null) {
            outputBuffer.release(); // Release previous buffer to prevent memory leaks
        }
        upscaledImage.copyTo(outputBuffer);
        upscaledImage.release();

        return outputBuffer;
    }

    // Helper function to generate a rainbow palette
    private List<Scalar> generateRainbowPalette(int numColors) {
        List<Scalar> palette = new ArrayList<>();
        float transparency = 0.4f; // Adjust this value to control transparency (0.0 to 1.0)

        for (int i = 0; i < numColors; i++) {
            float hue = (float) i / numColors; // Distribute hues across the full range
            int r = (int) (255 * Math.max(0, Math.min(1, Math.abs(hue * 6 - 3) - 1)));
            int g = (int) (255 * Math.max(0, Math.min(1, 2 - Math.abs(hue * 6 - 2))));
            int b = (int) (255 * Math.max(0, Math.min(1, 2 - Math.abs(hue * 6 - 4))));

            // Create a Scalar with an alpha channel for transparency
            palette.add(new Scalar(r, g, b, 255 * (1 - transparency)));
        }
        return palette;
    }


}