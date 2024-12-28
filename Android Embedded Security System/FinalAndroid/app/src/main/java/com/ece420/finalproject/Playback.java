// CODE WRITTEN BY PAUL JABLONSKI AND JUN HAYAKAWA
package com.ece420.finalproject;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Rect;
import org.opencv.imgcodecs.Imgcodecs;

import java.util.ArrayList;
import java.util.List;

public class Playback extends Activity {
    private int previewWidth;
    private int previewHeight;
    private ImageView imageView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.playback);

        imageView = findViewById(R.id.imageView); // Link the ImageView from XML

        // Ensure dimensions are initialized properly
        imageView.post(() -> {
            previewWidth = imageView.getWidth();
            previewHeight = imageView.getHeight();
            Log.d("Playback", "ImageView dimensions: " + previewWidth + "x" + previewHeight);
        });

        long T = ImageData.time;

        // Use T to set the max value of the slider, use first calibration image to set the minimum val to avoid black screen at the start
        SeekBar timeSlider = findViewById(R.id.timeSlider);
        timeSlider.setMax((int) T);

        TextView sliderValue = findViewById(R.id.sliderValue);
        timeSlider.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                sliderValue.setText("Current Time: " + progress + "ms");

                // Filter images by timestamp and display them
                List<Metadata> filteredImages = new ArrayList<>();
                for (Metadata metadata : ImageData.imageMetadataList) {
                    if (metadata.getTimestamp() <= progress) { // Convert seconds to milliseconds
                        filteredImages.add(metadata);
                    }
                }

                displayImages(filteredImages); // Update the display
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
        });


        Button playbackButton = findViewById(R.id.cameraInterfaceButton);
        playbackButton.setOnClickListener(v -> {
            Intent intent = new Intent(Playback.this, MainActivity.class);
            startActivity(intent);
        });

        Button clearCacheButton = findViewById(R.id.clearCacheButton);
        clearCacheButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ImageData.clearCache(Playback.this); // Call the method to clear the cache
            }
        });

    }

    private void displayImages(List<Metadata> images) {
        // Create a blank image for combining
        Mat combinedImage = Mat.zeros(previewHeight/5, previewWidth/5, CvType.CV_8UC3);

        for (Metadata metadata : images) {
            // Load the image from file
            Mat image = Imgcodecs.imread(metadata.getFilePath());
            if (image != null && !image.empty()) {

                int topLeftX = metadata.getTopX();
                int topLeftY = metadata.getTopY();

                int roiWidth = Math.min(image.cols(), metadata.getWidth());
                int roiHeight = Math.min(image.rows(), metadata.getHeight());

                if (topLeftX + roiWidth > combinedImage.cols()) {
                    Log.e("Playback", "BAD WIDTH");
                }
                if (topLeftY + roiHeight > combinedImage.rows()) {
                    Log.e("Playback", "BAD HEIGHT");
                }

                // Log ROI
                Log.d("Playback", "ROI Details: X=" + topLeftX + ", Y=" + topLeftY +
                        ", Width=" + roiWidth + ", Height=" + roiHeight);
                Log.d("Playback", "Image size: " + image.cols() + "x" + image.rows());
                Log.d("Playback", "CombinedImage size: " + combinedImage.cols() + "x" + combinedImage.rows());

                if (roiWidth > 0 && roiHeight > 0) {
                    try {
                        // Define the ROI and create submat
                        Rect roi = new Rect(topLeftX, topLeftY, roiWidth, roiHeight);
                        Mat submat = combinedImage.submat(roi);
                        Mat imageSubmat = image.submat(new Rect(0, 0, roiWidth, roiHeight)); // Same ROI for the source image

                        // Overlay the image
                        imageSubmat.copyTo(submat);
                        Log.i("Playback", "SUCCESSFULLY PRINTED IMAGE");
                    } catch (Exception e) {
                        Log.e("Playback", "Error during image overlay: " + e.getMessage());
                    }
                } else {
                    Log.e("Playback", "Invalid ROI dimensions: Width=" + roiWidth + ", Height=" + roiHeight);
                }

                image.release(); // Free memory
            } else {
                Log.e("Playback", "Image not loaded or empty: " + metadata.getFilePath());
            }
        }



        // Convert the combined image to Bitmap and update the preview
        Bitmap bitmap = Bitmap.createBitmap(combinedImage.cols(), combinedImage.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(combinedImage, bitmap);
        imageView.setImageBitmap(bitmap); // Assume you have an ImageView for displaying the result

        combinedImage.release(); // Free memory
    }

}

