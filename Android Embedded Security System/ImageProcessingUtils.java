// CODE WRITTEN BY PAUL JABLONSKI AND JUN HAYAKAWA
package com.ece420.finalproject;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.util.Log;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Rect;
import org.opencv.core.Scalar;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;

import java.io.File;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.ArrayList;
import java.util.Stack;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import org.opencv.core.Size;
import org.opencv.core.Point;

public class ImageProcessingUtils {

    private Context context;  // Holds context reference to access application resources

    // Constructor that initializes the edge detector by loading the model file from assets
    public ImageProcessingUtils(Context context) {
        this.context = context;  // Store the context for future use
        AssetManager assetManager = context.getAssets();  // Access the app's assets
    }

    // Static list to store known object color labels
    public static List<ObjectColorLabel> knownObjectColors = new ArrayList<>();

    // Process image by subtracting a calibration image, useful for background subtraction
    private Mat blurredCalibrationImage = null;

    public void resetBlurredCalibrationImage() {
        if (blurredCalibrationImage != null) {
            blurredCalibrationImage.release(); // Release the old Mat
            blurredCalibrationImage = null;   // Reset the reference
        }
    }




    // IMAGE PROCESSING PIPELINE FUNCTIONS

    // Bitmasking function
    public Mat processGreenScreen(Mat inputImage, Mat calibrationImage) {
        if (calibrationImage == null) {
            // If no calibration image is provided, return a copy of the input image
            return inputImage.clone();
        }

        // Check if the calibration image has already been blurred
        if (blurredCalibrationImage == null) {
            // Resize and apply Gaussian blur to the calibration image only once
            blurredCalibrationImage = new Mat();
            Mat resizedCalibration = new Mat();
            Imgproc.resize(calibrationImage, resizedCalibration, new Size(inputImage.cols(), inputImage.rows()));
            Imgproc.GaussianBlur(resizedCalibration, blurredCalibrationImage, new Size(5, 5), 1.5);
            resizedCalibration.release(); // Release the resized calibration image
        }

        // Resize and apply Gaussian blur to the input image
        Mat resizedInput = new Mat();
        Mat blurredInput = new Mat();
        Imgproc.resize(inputImage, resizedInput, new Size(blurredCalibrationImage.cols(), blurredCalibrationImage.rows()));
        Imgproc.GaussianBlur(resizedInput, blurredInput, new Size(5, 5), 1.5);

        // Calculate the absolute difference between the blurred images
        Mat diff = new Mat();
        Mat diffGray = new Mat();

        Core.absdiff(blurredInput, blurredCalibrationImage, diff);
        Imgproc.cvtColor(diff, diffGray, Imgproc.COLOR_BGR2GRAY); // Convert to grayscale

        // Create a binary mask to detect changes based on the pixel differences
        Mat mask = new Mat();
        double thresholdValue = 25.0;
        Imgproc.threshold(diffGray, mask, thresholdValue, 255, Imgproc.THRESH_BINARY);
        // denoise further by shrinking small noise and then re-expanding to close gaps
        Mat kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, new Size(4, 4));
        Imgproc.morphologyEx(mask, mask, Imgproc.MORPH_OPEN, kernel);
        Imgproc.morphologyEx(mask, mask, Imgproc.MORPH_CLOSE, kernel);

        // Release intermediate Mats to free memory
        resizedInput.release();
        blurredInput.release();
        diff.release();
        diffGray.release();

        return mask;
    }

    // Apply Canny edge detection to an image
    public Mat applyCannyEdgeDetection(Mat inputImage, double lowerThreshold, double upperThreshold) {
        // Apply Gaussian Blur to reduce noise
        //Mat blurredImage = new Mat();
        //Imgproc.GaussianBlur(inputImage, blurredImage, new Size(5, 5), 1.5);

        // Apply Canny Edge Detection
        Mat edges = new Mat();
        Imgproc.Canny(inputImage, edges, lowerThreshold, upperThreshold);

        // Perform non-maximum suppression to thin the edges
        //nonMaximumSuppression(edges);

        // Apply adaptive thresholding to enhance edges further
        Mat edgesThresholded = new Mat();
        Imgproc.adaptiveThreshold(edges, edgesThresholded, 255, Imgproc.ADAPTIVE_THRESH_MEAN_C, Imgproc.THRESH_BINARY, 11, 2);

        // Return the processed edge image
        return edges;
    }

    // Calculate gradient orientations based on detected edges
    public Mat calculateOrientations(Mat edgesClipped) {
        // Convert the edge image to float type for processing
        Mat edgesFloat = new Mat();
        edgesClipped.convertTo(edgesFloat, CvType.CV_32F);

        // Calculate gradients using Sobel operator (X and Y directions)
        Mat gradX = new Mat();
        Mat gradY = new Mat();
        Imgproc.Sobel(edgesFloat, gradX, CvType.CV_32F, 1, 0, 3);  // Sobel gradient in X direction
        Imgproc.Sobel(edgesFloat, gradY, CvType.CV_32F, 0, 1, 3);  // Sobel gradient in Y direction

        // Compute gradient orientations using arctangent function
        Mat orientations = new Mat();
        Core.phase(gradX, gradY, orientations, false);  // Set 'false' for radians

        // Set orientation values to 0 for pixels where edges are absent
        Mat validMask = new Mat();
        Core.compare(edgesClipped, new Scalar(0), validMask, Core.CMP_NE);
        orientations.setTo(new Scalar(0), validMask);

        // Release intermediate Mats to free memory
        gradX.release();
        gradY.release();
        edgesFloat.release();
        validMask.release();

        return orientations;
    }

    // Flood-fill algorithm to group edges based on orientation similarity
    private List<int[]> groupEdges(int i, int j, Mat orientations, double baseOrientation, double thresh, Mat visited) {
        List<int[]> edgeGroup = new ArrayList<>();
        Stack<int[]> stack = new Stack<>();
        stack.push(new int[]{i, j});

        // Perform depth-first search (DFS) to group edges
        while (!stack.isEmpty()) {
            int[] point = stack.pop();
            int x = point[0];
            int y = point[1];

            // Check if the point is out of bounds
            if (x < 0 || x >= orientations.rows() || y < 0 || y >= orientations.cols()) {
                continue;
            }

            // Skip visited points or those with zero orientation
            double[] visitedValue = visited.get(x, y);
            double[] orientationValue = orientations.get(x, y);
            if (visitedValue != null && visitedValue[0] == 1 || orientationValue == null || orientationValue[0] == 0) {
                continue;
            }

            // Compute the angular difference between current and base orientations
            double angleDiff = Math.abs(orientationValue[0] - baseOrientation);
            if (angleDiff > Math.PI) {
                angleDiff = 2 * Math.PI - angleDiff;
            }
            if (angleDiff > thresh) {
                continue;
            }

            // Mark the point as visited and add it to the current edge group
            visited.put(x, y, new double[]{1});
            edgeGroup.add(new int[]{x, y});

            // Add neighboring pixels to the stack for further exploration
            stack.push(new int[]{x, y + 1});
            stack.push(new int[]{x + 1, y});
            stack.push(new int[]{x - 1, y});
            stack.push(new int[]{x, y - 1});
        }

        return edgeGroup;
    }

    // Group edges based on orientations across the entire image
    public List<int[]> groupAllEdges(Mat orientations) {
        // Create a 'visited' matrix to track processed pixels
        Mat visited = Mat.zeros(orientations.size(), CvType.CV_8UC1);

        // List to hold all edge groups
        List<List<int[]>> allEdgeGroups = new ArrayList<>();
        double orientationThreshold = Math.PI / 4;

        // Iterate over the orientation matrix to group edges
        for (int i = 0; i < orientations.rows(); i++) {
            for (int j = 0; j < orientations.cols(); j++) {
                double[] orientationValue = orientations.get(i, j);
                double[] visitedValue = visited.get(i, j);

                // Skip already visited points or those without valid orientations
                if (orientationValue != null && orientationValue[0] != 0 && visitedValue != null && visitedValue[0] == 0) {
                    // Group edges starting from the current pixel
                    List<int[]> edgeGroup = groupEdges(i, j, orientations, orientationValue[0], orientationThreshold, visited);

                    // Add the grouped edges to the list
                    if (!edgeGroup.isEmpty()) {
                        allEdgeGroups.add(edgeGroup);
                    }
                }
            }
        }

        List<int[]> allEdgeGroupCenters = new ArrayList<>();
        for (List<int[]> sublist : allEdgeGroups) {
            if(!sublist.isEmpty()) {
                int x_center = 0;
                int y_center = 0;
                for (int[] point : sublist) {
                    x_center += point[0];
                    y_center += point[1];
                }
                allEdgeGroupCenters.add(new int[]{x_center / sublist.size(), y_center / sublist.size()});
            }
        }

        // Release the 'visited' matrix to free memory
        visited.release();

        return allEdgeGroupCenters;
    }



    // MAIN CLUSTERING PIPELINE FUNCTION

    // Method to cluster edge groups using DB clustering and then draw bounding boxes around them
    // This method then saves the bounding box images, and performs color analysis within the bounds
    public void clusterDrawSaveAndColor(List<int[]> centerPoints, Mat image, Mat mask) {
        List<Point2D> centers = new ArrayList<>();
        for (int[] point : centerPoints) {
            centers.add(new Point2D(point[0], point[1]));
        }

        Point2DDistanceMetric distanceMetric = new Point2DDistanceMetric();
        double eps = 50.0;
        int minPts = 40; // Minimum points to form a cluster

        try {
            ManualDBSCAN clusterer = new ManualDBSCAN(centers, eps, minPts, distanceMetric);
            List<List<Point2D>> clusters = new ArrayList<>(clusterer.performClustering());

            for (List<Point2D> cluster : clusters) {
                double minX = Double.MAX_VALUE, minY = Double.MAX_VALUE;
                double maxX = Double.MIN_VALUE, maxY = Double.MIN_VALUE;

                for (Point2D point : cluster) {
                    minX = Math.min(minX, point.x);
                    minY = Math.min(minY, point.y);
                    maxX = Math.max(maxX, point.x);
                    maxY = Math.max(maxY, point.y);
                }

                // Calculate width and height of the bounding box
                double width = maxY - minY;
                double height = maxX - minX;

                // Skip clusters that are smaller than 12x12 pixels
                if (width < 12 || height < 12) {
                    Log.d("ClusterSkipping", "Skipping cluster with dimensions: " + width + "x" + height);
                    continue;
                }

                // Calculate text position at the bottom middle of the bounding box
                int textX = (int) ((minY + maxY) / 2);  // Horizontal center
                int textY = (int) maxX - 5;  // 5 pixels from the bottom of the bounding box

                // Get current real-time timestamp
                String timestampText = formatTimestamp();


                // Extract the image inside the bounding box
                Rect boundingRect = new Rect((int) minY, (int) minX, (int) (maxY - minY), (int) (maxX - minX));
                Mat croppedImage = new Mat(image, boundingRect);
                Mat croppedMask = new Mat(mask, boundingRect);
                Mat croppedImageAlpha = new Mat();
                Imgproc.cvtColor(croppedImage, croppedImageAlpha, Imgproc.COLOR_BGR2BGRA);
                List<Mat> channels = new ArrayList<>();
                Core.split(croppedImageAlpha, channels);
                channels.set(3, croppedMask);
                Core.merge(channels, croppedImageAlpha);
                Imgproc.cvtColor(croppedImage, croppedImage, Imgproc.COLOR_RGB2BGR);
                saveImage(context, croppedImage, (int) minY, (int) minX, (int) width, (int) height);
                Imgproc.cvtColor(croppedImage, croppedImage, Imgproc.COLOR_BGR2RGB);

                // Draw bounding box
                Imgproc.rectangle(image, new Point(minY, minX), new Point(maxY, maxX), new Scalar(0, 255, 0), 2);

                // Perform color quantization to get the six most frequent colors
                List<Scalar> topColors = getTopColors(croppedImageAlpha, 6);

                // Find or create an object label based on colors
                ObjectColorLabel objectLabel = findOrCreateObjectLabel(topColors);

                // Draw small boxes for the most frequent colors
                int boxSize = 10; // Size of the small color boxes
                for (int i = 0; i < topColors.size(); i++) {
                    Scalar color = topColors.get(i);
                    int x = (int) minY + 5 + (i * (boxSize + 5)); // Adjust spacing between boxes
                    int y = (int) minX + 5;
                    Imgproc.rectangle(image, new Point(x, y), new Point(x + boxSize, y + boxSize), color, -1);
                }

                // Add label text above the bounding box
                Imgproc.putText(image, "Obj " + objectLabel.label,
                        new Point(minY, minX - 10),
                        Core.FONT_HERSHEY_SIMPLEX,
                        0.5,
                        new Scalar(255, 255, 255),
                        2);

                // Draw timestamp text
                Imgproc.putText(image, timestampText,
                        new Point(textX, textY),
                        Core.FONT_HERSHEY_SIMPLEX,
                        0.3,  // Smaller font size
                        new Scalar(255, 255, 255),  // White color
                        1);  // Thinner line width

                // Release Mat
                croppedImage.release();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }




    // MINOR IMAGE RELATED FUNCTIONS

    // Formats the timestamp for displaying within bounding boxes
    private String formatTimestamp() {
        try {
            // Create a SimpleDateFormat with the desired pattern
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss", Locale.getDefault());

            // Get the current time
            return sdf.format(new Date());
        } catch (Exception e) {
            // Fallback in case of any formatting issues
            Log.e("TimestampFormat", "Error formatting timestamp", e);
            return "00:00:00";
        }
    }

    // Image saving functionality
    public void saveImage(Context context, Mat image, int minX, int minY, int width, int height) {
        if (image == null || image.empty()) {
            Log.e("ImageSaving", "Input Mat is null or empty.");
            return;
        }

        // Convert Mat to Bitmap
        Bitmap bitmap = Bitmap.createBitmap(image.cols(), image.rows(), Bitmap.Config.ARGB_8888);
        Utils.matToBitmap(image, bitmap);

        // Calculate the elapsed time since the timer started
        long elapsedMilliseconds = 0;
        if (MainActivity.start != null) {
            Instant now = Instant.now();
            elapsedMilliseconds = Duration.between(MainActivity.start, now).toMillis() + ImageData.time;
        } else {
            Log.e("ImageSaving", "Timer start time is null. Unable to synchronize timestamps.");
        }

        // Define the internal storage directory
        File directory = new File(context.getFilesDir(), "ExtractedImages");
        if (!directory.exists()) {
            boolean created = directory.mkdirs();
            if (!created) {
                Log.e("ImageSaving", "Failed to create directory: " + directory.getAbsolutePath());
                return;
            }
        }

        // Create a filename with the elapsed time as part of the name
        String filename = "extracted_" + elapsedMilliseconds + ".png";
        File file = new File(directory, filename);

        // Save the image
        try (FileOutputStream out = new FileOutputStream(file)) {
            bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
            Log.d("ImageSaving", "Saved image with timestamp to: " + file.getAbsolutePath());
        } catch (Exception e) {
            Log.e("ImageSaving", "Failed to save image: " + e.getMessage());
            return;
        }

        // Add metadata to the global list
        ImageData.imageMetadataList.add(new Metadata(elapsedMilliseconds, minX, minY, width, height, file.getAbsolutePath()));

        // Clean up
        if (bitmap != null && !bitmap.isRecycled()) {
            bitmap.recycle();
        }
    }




    // DB CLUSTERING FUNCTIONS AND CLASS

    // DB Scan implementation
    public class ManualDBSCAN {
        private List<Point2D> points;
        private double eps;
        private int minPts;
        private Point2DDistanceMetric distanceMetric;

        public ManualDBSCAN(List<Point2D> points, double eps, int minPts, Point2DDistanceMetric distanceMetric) {
            this.points = points;
            this.eps = eps;
            this.minPts = minPts;
            this.distanceMetric = distanceMetric;
        }

        public List<List<Point2D>> performClustering() {
            List<List<Point2D>> clusters = new ArrayList<>();
            Set<Point2D> visited = new HashSet<>();
            Set<Point2D> noise = new HashSet<>();

            for (Point2D point : points) {
                if (visited.contains(point)) {
                    continue;
                }

                visited.add(point);
                List<Point2D> neighborPoints = regionQuery(point);

                if (neighborPoints.size() < minPts) {
                    noise.add(point);
                } else {
                    List<Point2D> cluster = expandCluster(point, neighborPoints, visited, noise);
                    clusters.add(cluster);
                }
            }

            return clusters;
        }

        private List<Point2D> expandCluster(Point2D point, List<Point2D> neighborPoints,
                                            Set<Point2D> visited, Set<Point2D> noise) {
            List<Point2D> cluster = new ArrayList<>();
            cluster.add(point);

            for (int i = 0; i < neighborPoints.size(); i++) {
                Point2D neighborPoint = neighborPoints.get(i);

                if (!visited.contains(neighborPoint)) {
                    visited.add(neighborPoint);
                    List<Point2D> newNeighborPoints = regionQuery(neighborPoint);

                    if (newNeighborPoints.size() >= minPts) {
                        neighborPoints.addAll(newNeighborPoints);
                    }
                }

                if (!isPointInAnyCLuster(neighborPoint, cluster)) {
                    cluster.add(neighborPoint);
                    noise.remove(neighborPoint);
                }
            }

            return cluster;
        }

        private List<Point2D> regionQuery(Point2D point) {
            List<Point2D> neighbors = new ArrayList<>();
            for (Point2D other : points) {
                if (distanceMetric.calculateDistance(point, other) <= eps) {
                    neighbors.add(other);
                }
            }
            return neighbors;
        }

        private boolean isPointInAnyCLuster(Point2D point, List<Point2D> cluster) {
            return cluster.contains(point);
        }
    }




    // COLOR RELATED FUNCTIONS

    // Object color label class
    public static class ObjectColorLabel {
        private static final AtomicInteger labelCounter = new AtomicInteger(1);

        public int label;
        public List<Scalar> colors;

        public ObjectColorLabel(List<Scalar> topColors) {
            this.label = labelCounter.getAndIncrement();
            this.colors = topColors;
        }
    }

    // Method to find a matching object label or create a new one
    public static ObjectColorLabel findOrCreateObjectLabel(List<Scalar> topColors) {
        // Check against existing labels
        for (ObjectColorLabel existingLabel : knownObjectColors) {
            if (areColorsSimilar(existingLabel.colors, topColors, 50)) {
                return existingLabel;
            }
        }

        // If no similar label found, create a new one
        ObjectColorLabel newLabel = new ObjectColorLabel(topColors);
        knownObjectColors.add(newLabel);
        return newLabel;
    }

    // Obtain top six colors within bounding boxes using our K-means implementation
    private List<Scalar> getTopColors(Mat image, int n) {
        // Collect color points
        List<Scalar> pixels = new ArrayList<>();
        for (int y = 0; y < image.rows(); y++) {
            for (int x = 0; x < image.cols(); x++) {
                double[] pixel = image.get(y, x);
                if (pixel != null && pixel[3] > 0) { // Check alpha channel to ignore transparent pixels
                    pixels.add(new Scalar(pixel[0], pixel[1], pixel[2])); // Blue, Green, Red
                }
            }
        }

        // K-means clustering
        int k = Math.min(10, pixels.size());
        List<Scalar> centroids = performKMeans(pixels, k);

        // Calculate color frequencies and sort
        Map<Scalar, Integer> colorFrequency = new HashMap<>();
        for (Scalar pixel : pixels) {
            Scalar closestCentroid = findClosestCentroid(pixel, centroids);
            colorFrequency.put(closestCentroid, colorFrequency.getOrDefault(closestCentroid, 0) + 1);
        }

        return centroids.stream()
                .sorted((c1, c2) -> colorFrequency.getOrDefault(c2, 0).compareTo(colorFrequency.getOrDefault(c1, 0)))
                .limit(n)
                .collect(Collectors.toList());
    }

    // K-means implementation
    private List<Scalar> performKMeans(List<Scalar> pixels, int k) {
        List<Scalar> centroids = new ArrayList<>();
        Random random = new Random();
        for (int i = 0; i < k; i++) {
            centroids.add(pixels.get(random.nextInt(pixels.size())));
        }

        boolean changed;
        do {
            changed = false;
            Map<Scalar, List<Scalar>> clusters = new HashMap<>();

            for (Scalar pixel : pixels) {
                Scalar closestCentroid = findClosestCentroid(pixel, centroids);
                clusters.computeIfAbsent(closestCentroid, key -> new ArrayList<>()).add(pixel);
            }

            for (int i = 0; i < centroids.size(); i++) {
                Scalar oldCentroid = centroids.get(i);
                Scalar newCentroid = calculateMeanCentroid(clusters.get(oldCentroid));
                if (!isSameScalar(newCentroid, oldCentroid)) {
                    centroids.set(i, newCentroid);
                    changed = true;
                }
            }
        } while (changed);

        return centroids;
    }

    // Centroid finding for K-means
    private Scalar findClosestCentroid(Scalar pixel, List<Scalar> centroids) {
        return centroids.stream()
                .min(Comparator.comparingDouble(c -> euclideanDistance(pixel, c)))
                .orElse(null);
    }

    // Mean centroid calculation
    private Scalar calculateMeanCentroid(List<Scalar> cluster) {
        if (cluster == null || cluster.isEmpty()) return null;
        double blue = cluster.stream().mapToDouble(p -> p.val[0]).average().orElse(0);
        double green = cluster.stream().mapToDouble(p -> p.val[1]).average().orElse(0);
        double red = cluster.stream().mapToDouble(p -> p.val[2]).average().orElse(0);
        return new Scalar(blue, green, red);
    }

    // Euclidean distance helper function for color comparison
    private double euclideanDistance(Scalar p1, Scalar p2) {
        double bDiff = p1.val[0] - p2.val[0];
        double gDiff = p1.val[1] - p2.val[1];
        double rDiff = p1.val[2] - p2.val[2];

        return Math.sqrt(bDiff * bDiff + gDiff * gDiff + rDiff * rDiff);
    }

    // Helper method to compare Scalars
    private boolean isSameScalar(Scalar s1, Scalar s2) {
        return s1.val[0] == s2.val[0] &&
                s1.val[1] == s2.val[1] &&
                s1.val[2] == s2.val[2];
    }

    // Check similarity between two sets of colors using Euclidean distance
    public static boolean areColorsSimilar(List<Scalar> existingColors, List<Scalar> newColors, int tolerance) {
        if (existingColors == null || newColors == null ||
                existingColors.isEmpty() || newColors.isEmpty()) {
            return false;
        }

        int matchCount = 0;

        for (int i = 0; i < Math.min(existingColors.size(), newColors.size()); i++) {
            Scalar existingColor = existingColors.get(i);
            Scalar newColor = newColors.get(i);

            double distance = Math.sqrt(
                    Math.pow(existingColor.val[0] - newColor.val[0], 2) +
                            Math.pow(existingColor.val[1] - newColor.val[1], 2) +
                            Math.pow(existingColor.val[2] - newColor.val[2], 2)
            );

            if (distance <= tolerance) {
                matchCount++;
            }
        }

        return matchCount >= 3; // If 3 out of 6 colors match within the tolerance
    }




    // 2D POINT RELATED FUNCTIONS

    // 2D point class
    public static class Point2D {
        public double x;
        public double y;

        public Point2D(double x, double y) {
            this.x = x;
            this.y = y;
        }

        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Point2D point2D = (Point2D) obj;
            return Double.compare(point2D.x, x) == 0 && Double.compare(point2D.y, y) == 0;
        }

        public int hashCode() {
            return java.util.Objects.hash(x, y);
        }
    }

    // 2D point distance
    public class Point2DDistanceMetric {
        public double calculateDistance(Point2D point1, Point2D point2) {
            double dx = point1.x - point2.x;
            double dy = point1.y - point2.y;
            return Math.sqrt(dx * dx + dy * dy);
        }
    }
}


