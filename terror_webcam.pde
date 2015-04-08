import processing.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;


boolean DEBUG=false;
boolean INIT_ON=false;
boolean FULL_SCREEN=true;

boolean isMirror=INIT_ON;
boolean isFlick=INIT_ON;
boolean isBlackAndWhite=INIT_ON;
boolean isScanLines=INIT_ON;
boolean isVerticalInterference=INIT_ON;
boolean isCameraView=INIT_ON;
boolean isScare=INIT_ON;
boolean isFire=INIT_ON;
boolean isFace=INIT_ON;

boolean isRecordingVideo=false;

//int CAM_WIDTH=800;
int CAM_WIDTH=320;
//int CAM_HEIGHT=600;
int CAM_HEIGHT=240;
int CAM_FRAME_RATE=30;
float DISPLAY_RATIO=0.8;

color black = color(0,0,0);
color white = color(255,255,255);


ScenesConfigurator scenes = null;
SceneConfig currentScene = null;


Capture cam;
PFont font;
GlitchP5db glitchP5;
color[] aux;
PImage img;
//PImage imgScare;
//Animation fire;
Animation face;


Minim minim;
AudioSample scream;
AudioPlayer backgroundSound;

int NUM_PIXELS, MARGIN, FRAME_LENGTH;
int TIME_FONT_SIZE, TIME_WIDTH, TIME_HEIGHT, TIME_MARGIN;

int startInterferenceTime;
int startFlickTime;
int startIterationTime;

void setup() {
  showAvailableCameras();   
  scenes = new ScenesConfigurator();
  scenes.loadScenes();
  setSceneConfig(scenes.nextScene());
  
  setDisplaySize(DISPLAY_RATIO, CAM_WIDTH, CAM_HEIGHT);
  initProportionalSizes();
  frameRate(CAM_FRAME_RATE);
  font = createFont("Courier New",TIME_FONT_SIZE,true);
  background(black);
  noStroke();
  aux = new color[NUM_PIXELS];
  cam = new Capture(this, CAM_WIDTH, CAM_HEIGHT, CAM_FRAME_RATE);  
  cam.start();
  glitchP5 = new GlitchP5db(this);
  startInterferenceTime=millis();
  startFlickTime=millis();
  startIterationTime=millis();
 // imgScare = loadImage("input/susto.jpg");
  //imgScare = loadImage("fire.gif");
  //fire = new Animation("input/fire", 25);
  //face = new Animation("input/fantasma", 20);
  face = new Animation("input/mama-", 10, Animation.AnimationType.PNG);
  
  minim = new Minim(this);
  scream = minim.loadSample("input/scream.mp3", 2048);
  //backgroundSound = minim.loadFile("input/backgroundCorto.mp3", 2048);
  backgroundSound = minim.loadFile("input/backgroundLargo.mp3", 2048);
  backgroundSound.loop();  
}

void draw() {
  int iterationMillis = millis() - startIterationTime;
  if(currentScene!= null && iterationMillis > currentScene.millis) {
    setSceneConfig(scenes.nextScene());
  }
  paint();
}


void paint() {
  if(cam.available()) {
    cam.read();
    img = cam.get();
    //image(cam, 0, 0, width, height);
    if(isMirror) reversePixelsVerticalMirror();
    if(isFlick) flick();
    if(isScanLines || isVerticalInterference) {
      img.loadPixels();
      for(int y=0;y<img.height;y++) {
        for(int x=0;x<img.width;x++) {     
          int pos = Util.getLocation(x, y, img.width);   
          if(isScanLines) drawScanTvLines(x, y, img.width, img.pixels);
          if(isVerticalInterference) drawVerticalInterference(x, y, img.width, img.height, img.pixels);
        }
      }
      img.updatePixels();
    }
    if(isBlackAndWhite) switchColorOff();
    image(img, 0, 0, width, height);
//background(img);
//    if(isScare) {
//      blend(imgScare, 0, 0, imgScare.width,  imgScare.height, 0, 0, imgScare.width,  imgScare.height, HARD_LIGHT);
//    }
//    if(isFire) {
//      fire.display(0, 0);
//    }
    if(isFace) {
      face.display(0, 0, width, height);
     //face.display(0, 0);
    }
      
    glitchP5.run();
    
    if(isCameraView) {    
      drawCurrentTime();
      drawSecurityCamCorners();
    }
//    if(isRecordingVideo) videoFrame();
    if(DEBUG) { text(frameRate,0,height); }
  }
}


void stop()
{ 
  glitchP5.close();
  backgroundSound.close();
  scream.close();
  minim.stop();

  super.stop(); 
}


void showAvailableCameras(){
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    System.exit(1);
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  } 
}



void setSceneConfig(SceneConfig scene) {
   this.currentScene = scene;
   if(scene!=null) {
     this.isMirror=scene.isMirror;
     this.isFlick=scene.isFlick;
     this.isBlackAndWhite=scene.isBlackAndWhite;
     this.isScanLines=scene.isScanLines;
     this.isVerticalInterference=scene.isVerticalInterference;
     this.isCameraView=scene.isCameraView;
     
     this.isScare=scene.isScare;
     this.isFire=scene.isFire;
     this.isFace=scene.isFace;
   
     if(scene.trigger!=null) {
       trigger(scene.trigger);
     }  
   }
}



void restartIteration() {
  startIterationTime=millis();
  System.out.println("Starting new iteration " + startIterationTime);
  currentScene = null;
  scenes.restart();
  setSceneConfig(scenes.nextScene());
  face.frame = 0;  
}


void setDisplaySize(float displayRatio, int camWidth, int camHeight) {
  float camRatio = (float) camWidth / camHeight;
  //size((int)(displayHeight*displayRatio*camRatio),(int)(displayHeight*displayRatio));
  if(FULL_SCREEN) {
    size(displayWidth,displayHeight-1);
  } else {
    size(CAM_WIDTH, CAM_HEIGHT);
  }
  //size((int)(displayHeight*camRatio),displayHeight-1);
}

void initProportionalSizes() {
  //NUM_PIXELS = width * height;
  NUM_PIXELS = CAM_WIDTH * CAM_HEIGHT;
  MARGIN = (int)(height*0.05);
  FRAME_LENGTH = (int)(height*0.15);
  TIME_FONT_SIZE = (int)(height*0.05);
  TIME_WIDTH = (int)(TIME_FONT_SIZE*5);
  TIME_HEIGHT = (int)(TIME_FONT_SIZE*0.9);
  TIME_MARGIN = (int)(height*0.05);
}

void drawCurrentTime() {
  int timeX = width-MARGIN-TIME_WIDTH-TIME_MARGIN;
  int timeY = height-MARGIN-TIME_HEIGHT;
  fill(black);
  rect(timeX,timeY-TIME_HEIGHT,TIME_WIDTH,TIME_HEIGHT);
  textFont(font,TIME_FONT_SIZE);
  fill(white); 
  text(Util.getCurrentTime(),timeX,timeY);
}

void drawSecurityCamCorners() {
  stroke(white);
  // top left corner
  line(MARGIN,MARGIN,MARGIN,MARGIN+FRAME_LENGTH);
  line(MARGIN,MARGIN,MARGIN+FRAME_LENGTH,MARGIN);
  // top right corner
  line(width-MARGIN,MARGIN,width-MARGIN-FRAME_LENGTH,MARGIN);
  line(width-MARGIN,MARGIN,width-MARGIN,MARGIN+FRAME_LENGTH);
  // bottom left corner
  line(MARGIN,height-MARGIN,MARGIN,height-(MARGIN+FRAME_LENGTH));
  line(MARGIN,height-MARGIN,MARGIN+FRAME_LENGTH,height-MARGIN);
  // bottom right corner
  line(width-MARGIN,height-MARGIN,width-MARGIN,height-(MARGIN+FRAME_LENGTH));
  line(width-MARGIN,height-MARGIN,width-(MARGIN+FRAME_LENGTH),height-MARGIN);
  noStroke();  
}


void drawScanTvLines(int x, int y, int wide, color[] pixs) {
  int pos = Util.getLocation(x, y, wide); 
  if(y%2==0) {
    pixs[pos] = addPixelBrightness(-30, pixs[pos]);
  }
}

void drawVerticalInterference(int x, int y, int wide, int high, color[] pixs ) {
  int INTF_COLOR_CLARIFICATION = 10;
  int INTF_VELOCITY = 15;
  float INTF_SCREEN_PERCENT = 0.2; 
  
  int startY = high - ((millis() - startInterferenceTime)/INTF_VELOCITY);
  int endY = startY + (int)(high*INTF_SCREEN_PERCENT);
  if(endY<0) {
     startY = high;
     startInterferenceTime = millis();
  }
  
  int pos = Util.getLocation(x, y, wide);
  if(y>startY && y <= endY) {
    pixs[pos] = addPixelBrightness(INTF_COLOR_CLARIFICATION, pixs[pos]);
  }  
}


void drawHalfVerticalMirrorStyle(int x, int y, int wide, color[] pixs) {
  int pos = Util.getLocation(x, y, wide);
  color pixel = pixs[pos];
  int mirrorLoc = Util.getLocationMirrored(x, y, wide);
  pixs[mirrorLoc]=pixel; 
}

void reversePixelsVerticalMirror() {
  img.loadPixels();
  //color[] mirror = new color[NUM_PIXELS];
    
  for(int y=0;y<img.height;y++) {
    for(int x=0;x<img.width;x++) {
      int pos = Util.getLocation(x, y, img.width); 
      color pixel = img.pixels[pos];
      int mirrorLoc = Util.getLocationMirrored(x, y, img.width);
      aux[mirrorLoc]=pixel;
    }
  }
  arrayCopy(aux,img.pixels);
  img.updatePixels();  
}

void flick() {
  int FLCK_VELOCITY_MAX=10;
  
  float flickVelocity=noise(frameCount*0.05)*FLCK_VELOCITY_MAX;
  if(flickVelocity!=0) {
    int startY = (int)((millis() - startFlickTime)/flickVelocity);
    if(startY>img.height) {
       startY = 0;
       startFlickTime = millis();
    }
    
    displacePixelsVertically(startY);
  }
}

void displacePixelsVertically(int displacement) {
  img.loadPixels();
  for(int y=0;y<img.height;y++) {
    for(int x=0;x<img.width;x++) {
      int pos = Util.getLocation(x, y, img.width); 
      color pixel = img.pixels[pos];
      int flickedY = (y-displacement<0?img.height+(y-displacement):y-displacement); 
      int flickedPos = Util.getLocation(x, flickedY, img.width);
      aux[flickedPos]=pixel;
    }
  }
  arrayCopy(aux,img.pixels);
  img.updatePixels();  
}

void switchColorOff() {
  img.loadPixels();
  for(int i=0;i<NUM_PIXELS;i++) {
    img.pixels[i] = color(Util.getGreyScaleValue(img.pixels[i]));
  }
  img.updatePixels();  
}

color addPixelBrightness(int brightness, color pixel) {
  int pixR = (pixel >> 16) & 0xFF;
  int pixG = (pixel >> 8) & 0xFF;
  int pixB = pixel & 0xFF;
  return color(pixR+brightness, pixG+brightness, pixB+brightness);
}

void mousePressed()
{
  /*
  // trigger a glitch: glitchP5.glitch(  posX,       // 
  //                               posY,       // position on screen(int)
  //          posJitterX,     // 
  //          posJitterY,     // max. position offset(int)
  //          sizeX,       // 
  //          sizeY,       // size (int)
  //          numberOfGlitches,   // number of individual glitches (int)
  //          randomness,     // this is a jitter for size (float)
  //          attack,     // max time (in frames) until indiv. glitch appears (int)
  //          sustain      // max time until it dies off after appearing (int)
  //              );

  glitchP5.glitch(0, mouseY, 0, 0, width*2, height/5, 3, 1.0f, 10, 20);
  */
}

void triggerRandomGlitch() {
  int rndPosY=(int)random(0,height);
  int rndPosOffsetY=0;
  int rndSizeY=(int)random(height/4,height*2);
  int rndNoGlitches=(int)random(2,3);
  glitchP5.glitch(0, rndPosY, 0, rndPosOffsetY, width*2, rndSizeY, rndNoGlitches, 1.0f, 5, 10);
}

void triggerGlitch() {
  int rndPosY=0;
  int rndPosOffsetY=0;
  int rndSizeY=height*2;
  int rndNoGlitches=1;
  glitchP5.glitch(0, rndPosY, 0, rndPosOffsetY, width*2, rndSizeY, rndNoGlitches, 1.0f, 0, 1);

}

void keyPressed() {
  simpleKeyPressed();
  //complexKeyPressed();
}


void simpleKeyPressed() {
  restartIteration();   
}

void complexKeyPressed() {
  if(key == '7') {
    triggerRandomGlitch();
  } else if(key == 'g') {
    triggerGlitch();
  } else if(key == 's') {
    triggerScream();
  } else if(key == 'p') {
    snapshot();
  } else if(key == 'r') {
    restartIteration();    
  } else {
    toggleFeature(key);
  }
}

void toggleFeature(char key) {
  if(key == '1') {
    isMirror = !isMirror;
  } else if(key == '6') {
    isFlick = !isFlick;
  } else if(key == '2') {
    isBlackAndWhite = !isBlackAndWhite;
  } else if(key == '3') {
    isScanLines = !isScanLines;
  } else if(key == '4') {
    isVerticalInterference = !isVerticalInterference;
  } else if(key == '5') {
    isCameraView = !isCameraView;
  } else if(key == '9') {
//    isRecordingVideo = !isRecordingVideo;
  } else if(key == 'z') {
    isScare = !isScare;
  } else if(key == 'x') {
    isFire = !isFire;
  } else if(key == 'c') {
    isFace = !isFace;
  }
}

void snapshot() {
  String dateTime = Util.getCurrentDateTime(); 
  saveFrame("output/snapshot-" + dateTime + ".jpg");
}

void videoFrame() { 
  saveFrame("output/frame-#######.tif");
}

boolean sketchFullScreen() {
  return true;
}

void triggerScream() {
  scream.trigger();
  isFace = true;
}

void trigger(String trigger) {
  if("shortGlitch".equals(trigger)) {
     triggerGlitch();
  } else if("longGlitch".equals(trigger)) {
     triggerRandomGlitch();
  } else if("scream".equals(trigger)) {
     triggerScream();
  } else if("photo".equals(trigger)) {
     snapshot();
  }     
}



