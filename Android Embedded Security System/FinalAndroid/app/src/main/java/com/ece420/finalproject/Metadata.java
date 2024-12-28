// CODE WRITTEN BY PAUL JABLONSKI AND JUN HAYAKAWA
package com.ece420.finalproject;

public class Metadata {
    private long timestamp;  // Timestamp of the image
    private int topX;     // X-coordinate of the center
    private int topY;     // Y-coordinate of the center
    private int width;
    private int height;
    private String filePath; // Path to the saved image

    // setter
    public Metadata(long timestamp, int topX, int topY, int width, int height, String filePath) {
        this.timestamp = timestamp;
        this.topX = topX;
        this.topY = topY;
        this.width = width;
        this.height = height;
        this.filePath = filePath;
    }

    // getters
    public long getTimestamp() {
        return timestamp;
    }

    public int getTopX() {
        return topX;
    }

    public int getTopY() {
        return topY;
    }

    public int getWidth() {
        return width;
    }

    public int getHeight() {
        return height;
    }

    public String getFilePath() {
        return filePath;
    }
}
