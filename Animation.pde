

public class Animation {
  PImage[] images;
  int imageCount;
  public int frame;
  
  Animation(String imagePrefix, int count, String type) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      String filename = imagePrefix + nf(i, 4) + type;
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    blend(images[frame], (int)xpos, (int)ypos, images[frame].width,  images[frame].height, (int)xpos, (int)ypos, images[frame].width,  images[frame].height, ADD);
  }
  
  void display(float xpos, float ypos, int destWidth, int destHeight) {
    frame = (frame+1) % imageCount;
    blend(images[frame], (int)xpos, (int)ypos, images[frame].width,  images[frame].height, (int)xpos, (int)ypos, destWidth,  destHeight, BLEND);
  }
  
  int getWidth() {
    return images[0].width;
  }
  
  class AnimationType {
    public static final String PNG = ".png";
    public static final String JPG = ".jpg";
    public static final String GIF = ".gif";
  }
}
