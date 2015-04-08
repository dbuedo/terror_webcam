

public static class Util {
 
public static String getCurrentDateTime() {
  return year() + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
}

public static String getCurrentTime() {
  return nf(hour(),2) + ":" + nf(minute(),2) + ":" + nf(second(),2);
}

public static int getLocation(int x, int y, int wide) {
  return x + y*wide;
}

public static int getLocationMirrored(int x, int y, int wide) {
  int loc = (wide - x - 1) + y*wide; // Reversing x to mirror the image
  return loc;
}

public static float getGreyScaleValue(color rgbPixel) {
  // Extract the red, green, and blue components of the current pixel's color
  int pixR = (rgbPixel >> 16) & 0xFF;
  int pixG = (rgbPixel >> 8) & 0xFF;
  int pixB = rgbPixel & 0xFF;

  // RGB to GREYSCALE FORMULA: 0.3R + 0.59G + 0.11B
  float pixGrey = 0.3*pixR + 0.59*pixG + 0.11*pixB;
  return pixGrey;       
}

}
