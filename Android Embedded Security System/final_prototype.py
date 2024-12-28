# FINAL PROTOTYPE VERSION MERGING BOTH COLOR/OBJECT IDENTIFICATION WITH IMAGE SAVING (our final additions to prototype)
# ALSO COMMENTED AND REFACTORED SOME CODE, GENERALLY CLEANED EVERYTHING UP FOR SUBMISSION
import cv2
import numpy as np
import colorsys
import pandas as pd
import os
import time

from sklearn.cluster import DBSCAN
from sklearn.cluster import KMeans
from scipy import ndimage
from collections import Counter
from scipy.spatial.distance import euclidean

# CSV file setup
stored_objects_csv = "bounding_box_colors.csv"
if not os.path.exists(stored_objects_csv):
    df = pd.DataFrame(columns = ["Label", "Color1", "Color2", "Color3", "Color4", "Color5", "Color6"])
    df.to_csv(stored_objects_csv, index = False)

# Edge detection using a pre-trained model
global edge_detector
edge_detector = cv2.ximgproc.createStructuredEdgeDetection('model.yml')

def detect_edges(image):
    # Ensure the image is in RGB format and has 3 channels
    if len(image.shape) == 2 or image.shape[-1] != 3:
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    # Convert image to float32 type and scale pixel values to [0, 1]
    image_float = np.float32(image) / 255.0
    edges = edge_detector.detectEdges(image_float)
    edges_clipped = np.where(edges > 0.1, edges, 0.0)
    edges_clipped = (edges_clipped * 255).astype(np.uint8)
    return edges_clipped

# Gradient and orientation calculation
def calculate_orientations(edges_clipped):
    grad_x, grad_y = np.gradient(edges_clipped.astype(np.float32))
    grad_x = ndimage.gaussian_filter(grad_x, 1.5)
    grad_y = ndimage.gaussian_filter(grad_y, 1.5)
    
    valid = edges_clipped != 0
    orientations = np.zeros_like(edges_clipped, dtype=np.float32)
    orientations[valid] = np.arctan2(grad_y[valid], grad_x[valid])

    return orientations

# Flood-fill algorithm for grouping edges
def group_edges(i, j, orientations, base_orientation, thresh, visited):
    edge_group = []
    stack = [(i, j)]
    while stack:
        x, y = stack.pop()
        if x < 0 or x >= orientations.shape[0] or y < 0 or y >= orientations.shape[1]:
            continue
        if visited[x, y] == 1 or orientations[x, y] == 0:
            continue
        angle_diff = np.abs(orientations[x, y] - base_orientation)
        if angle_diff > np.pi:
            angle_diff = 2 * np.pi - angle_diff
        if angle_diff > thresh:
            continue
        visited[x, y] = 1
        edge_group.append([x, y])
        stack.extend([(x, y + 1), (x + 1, y), (x - 1, y), (x, y - 1)])
    return edge_group

# Group edges using the flood-fill algorithm
def group_all_edges(orientations):
    visited = np.zeros(orientations.shape)
    edge_groups = []
    for i in range(orientations.shape[0]):
        for j in range(orientations.shape[1]):
            if orientations[i, j] != 0 and visited[i, j] == 0:
                base_orientation = orientations[i, j]
                edge_group = group_edges(i, j, orientations, base_orientation, thresh=1.5, visited=visited)
                if edge_group:
                    edge_groups.append(edge_group)

    edge_groups.sort(key = len)
    num_to_delete = int(len(edge_groups) * 0.9)
    edge_groups = edge_groups[num_to_delete:]  # deleting all the insignificant tiny edge groups
    return edge_groups

# Create a continuous rainbow-like color palette based on the number of groups
def generate_rainbow_palette(num_colors):
    palette = []
    for i in range(num_colors):
        hue = i / num_colors  # Distribute hues across the full range
        r, g, b = colorsys.hsv_to_rgb(hue, 1.0, 1.0)
        palette.append([int(r * 255), int(g * 255), int(b * 255)])
    return palette

# Calculate multiple bounding boxes based on clustering edges
def calculate_multiple_bounding_boxes(edge_groups, distance_threshold = 100, min_samples = 20):
    all_points = np.array([point for group in edge_groups for point in group])
    if all_points.size == 0:
        return []

    # Apply DBSCAN to find clusters of edge points
    clustering = DBSCAN(eps = distance_threshold, min_samples = min_samples).fit(all_points)

    # Find bounding boxes for each cluster (excluding noise points labeled as -1)
    bounding_boxes = []
    for cluster_id in set(clustering.labels_):
        if cluster_id == -1:  # Skip noise points
            continue
        cluster_points = all_points[clustering.labels_ == cluster_id]
        
        # Define bounding box for this cluster
        x_min = int(cluster_points[:, 0].min())
        y_min = int(cluster_points[:, 1].min())
        x_max = int(cluster_points[:, 0].max())
        y_max = int(cluster_points[:, 1].max())
        
        # Filter out very small boxes likely to be noise
        if (x_max - x_min) > 20 and (y_max - y_min) > 20:
            bounding_boxes.append((x_min, y_min, x_max, y_max))

    return bounding_boxes

# Calculate the six most frequent colors in an image / bounding box
def get_most_frequent_colors(image, num_colors = 6, kmeans_clusters = 10):
    # Reshape the image into a 2D array of pixels
    reshaped_image = image.reshape(-1, 3)
    reshaped_image = np.float32(reshaped_image)

    # Apply KMeans clustering to find k clusters of colors
    kmeans = KMeans(n_clusters=kmeans_clusters, random_state=42)
    kmeans.fit(reshaped_image)

    # Get the center of each cluster and convert into tuples
    cluster_centers = kmeans.cluster_centers_
    cluster_centers = np.round(cluster_centers).astype(int)
    color_counts = Counter(tuple(color) for color in cluster_centers)

    # Sort the colors based on frequency and return top 'num_colors' amount
    most_common_colors = color_counts.most_common(num_colors)
    return [color for color, _ in most_common_colors]

# Check similarity between an image's color sets
def are_colors_similar(existing_colors, new_colors, tolerance = 50):
    # Check if at least 4 colors match overall in the tolerance range using euclidean distance
    match_count = 0
    for i in range(6):
        if euclidean(existing_colors[i], new_colors[i]) <= tolerance:
            match_count += 1

    # If 4 out of 6 colors match, return True (object matches with stored one)
    return match_count >= 4

# Webcam functionality and edge processing pipeline
cv2.namedWindow("Edge Detection Side-by-Side", cv2.WINDOW_NORMAL)
cv2.resizeWindow("Edge Detection Side-by-Side", 1600, 600)  # Adjusted for side-by-side view
video = cv2.VideoCapture(0)
calibration_image = None

# Initialize important variables
threshold = 0.375 # Used for masking background later
masked_background = np.array([0, 255, 0], dtype = np.uint8)
start_time = time.time()
frame_counter = 0
n = 4

# Always run the following code (main loop)
while True:
    # Obtain video data
    ret, image = video.read()
    if not ret:
        break

    edge_groups = []

    # Wait until a calibration image is taken manually
    key = cv2.waitKey(1) & 0xFF
    if key == ord('c'):
        calibration_image = image.copy()

    # Run all this once a calibration image is present
    if calibration_image is not None:
        # Resize images
        new_size = (image.shape[1] // 2, image.shape[0] // 2)
        image = cv2.resize(image, new_size)
        calibration_image = cv2.resize(calibration_image, new_size)

        # Take the difference between the calibration image and the current frame
        diff = cv2.absdiff(calibration_image, image)
        diff_magnitude = np.sqrt(np.sum(np.square(diff.astype(np.float32)), axis=-1))
        diff_normalized = diff_magnitude / np.sqrt(255**2 * 3)

        # Create a bitmask where the difference in frames is beyond the masking threshold
        mask = (diff_normalized > threshold).astype(np.uint8)
        mask_color = cv2.merge([mask, mask, mask])
        masked_background_img = np.full_like(image, masked_background) # Set background to the calibration background
        masked_foreground = np.where(mask_color == 1, image, masked_background_img) # Separate the foreground / detected objects

        # Perform edge detection of only masked objects that differ from the calibration image
        edges_clipped = detect_edges(masked_foreground) 
        orientations = calculate_orientations(edges_clipped)
        edge_groups = group_all_edges(orientations)
        palette = generate_rainbow_palette(len(edge_groups))
        edge_colored = np.zeros_like(masked_foreground)

        for idx, group in enumerate(edge_groups):
            color = palette[idx]
            for (x, y) in group:
                edge_colored[x, y] = color
    else:
        # If calibration image is not taken yet, display everything as is
        masked_foreground = image
        edge_colored = masked_foreground

    # If edge groups are formed then find bounding boxes and perform remainder of operations
    if edge_groups:
        # Find the bounding boxes using DBScan clustering of edge groups
        bounding_boxes = calculate_multiple_bounding_boxes(edge_groups, distance_threshold = 100, min_samples = 20)

        # Loop through all bounding boxes
        for (x_min, y_min, x_max, y_max) in bounding_boxes:
            # Extract bounding box region from image
            bounding_box_image = image[x_min:x_max, y_min:y_max]

            # Get the sorted and six most frequent colors in the region 
            frequent_colors = sorted(get_most_frequent_colors(bounding_box_image))

            # Load existing data from stored object colors
            df = pd.read_csv(stored_objects_csv)
            matched_label = None

            # Check for similar color sets in the existing data
            for _, row in df.iterrows():
                existing_colors = [eval(row[f"Color{i + 1}"]) for i in range(6)]

                # If colors are similar enough to something already stored, then set the current match as the stored label
                if are_colors_similar(existing_colors, frequent_colors, tolerance = 50):
                    matched_label = row["Label"]
                    break
            
            # If there isn't a match to any of the stored labels and color swatches
            if matched_label is None:
                # Assign a new label and store color values
                matched_label = f"Object_{len(df) + 1}"
                new_entry = {"Label": matched_label}

                for i in range(len(frequent_colors)):
                    color_key = f"Color{i + 1}" 
                    new_entry[color_key] = str(frequent_colors[i])

                df = df.append(new_entry, ignore_index = True)
                df.to_csv(stored_objects_csv, index = False)

            # Draw current bounding box and label
            cv2.rectangle(edge_colored, (y_min, x_min), (y_max, x_max), (0, 255, 0), 2) # For left frame boxes
            cv2.putText(edge_colored, matched_label, (y_min, x_min - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2) 

            cv2.rectangle(image, (y_min, x_min), (y_max, x_max), (0, 255, 0), 2)  # Overlay on original frame on right
            cv2.putText(image, matched_label, (y_min, x_min - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2) 

            # Draw the frequent colors in small boxes above the bounding box
            for idx, color in enumerate(frequent_colors):
                # Ensure color is in the right format 
                if isinstance(color, tuple) and len(color) == 3:
                    color = tuple(map(int, color))  

                    # Draw a small rectangle (color box)
                    color_box_start = (y_min + idx * (10 + 5), x_min - 30)
                    color_box_end = (y_min + (idx + 1) * 10 + 5 * idx, x_min - 30 + 10)
                    cv2.rectangle(image, color_box_start, color_box_end, color, -1)  # Fill with color

            # Save images to folder for person storage (more image redundancy can be handled here later)
            if 0 <= y_min and y_max <= image.shape[1] and 0 <= x_min and x_max <= image.shape[0] and frame_counter % n == 0:
                if bounding_box_image.size > 0:
                    # Upscale bounding box for storage
                    upscale = (bounding_box_image.shape[1] * 4, bounding_box_image.shape[0] * 4)
                    cv2.resize(bounding_box_image, upscale)

                    # Place text to indicate image storage
                    box_center = [(x_max - x_min) / 2, (y_max - y_min) / 2]
                    timestamp = time.time() - start_time
                    cv2.putText(bounding_box_image, f"TIME: {timestamp:.2f} LOC: {box_center}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, .3, (0, 0, 255), 1)

                    # Ensure storage directory / folder exists
                    os.makedirs('extracted_images', exist_ok = True)
                    filename = f"extracted_images/extracted_{int(timestamp * 1000)}.jpg"
                    cv2.imwrite(filename, bounding_box_image)
                else:
                    print("Extracted image is empty.")
            else:
                print("Invalid bounding box coordinates.")

    
    # Stack images side by side
    side_by_side = np.hstack((edge_colored, image))

    # Display the side-by-side result
    cv2.imshow("Edge Detection Side-by-Side", side_by_side)

    if key == ord('q'):
        break

video.release()
cv2.destroyAllWindows()