// CODE WRITTEN BY PAUL JABLONSKI AND JUN HAYAKAWA
package com.ece420.finalproject;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

// Image metadata storage class and for caching
public class ImageData {
    public static long time = 0;

    public static List<Metadata> imageMetadataList = new ArrayList<>();

    public static void clearCache(Context context) {
        // Get the ExtractedImages directory
        File directory = new File(context.getFilesDir(), "ExtractedImages");

        // Check if the directory exists
        if (directory.exists() && directory.isDirectory()) {
            File[] files = directory.listFiles(); // List all files in the directory
            if (files != null) {
                for (File file : files) {
                    if (file.isFile()) {
                        boolean deleted = file.delete(); // Delete each file
                        if (deleted) {
                            Log.d("ClearCache", "Deleted: " + file.getName());
                        } else {
                            Log.e("ClearCache", "Failed to delete: " + file.getName());
                        }
                    }
                }
            }
            Log.d("ClearCache", "Cache cleared.");
            time = 0;
        } else {
            Log.e("ClearCache", "ExtractedImages directory does not exist.");
        }
    }
}
