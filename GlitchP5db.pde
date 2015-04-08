import processing.core.PApplet;
import java.util.ArrayList;

/*
 * Modification of a Jacob Penca's library. 
 * http://dl.dropboxusercontent.com/u/1358257/glitchp5/web/index.html
 */
public class GlitchP5db
{
  PApplet parent;
  GlitchFXdb glfx;
  ArrayList<TimedGlitcher> timedGlitchers = new ArrayList<TimedGlitcher>();
  
  Minim minim;
  WhiteNoise wn;
  AudioOutput out;
  boolean glitching = false;

  public GlitchP5db(PApplet parent)
  {
    this.parent = parent;
    glfx = new GlitchFXdb(parent, -1);
    initAudioNoise(parent);
  }    
  
  public GlitchP5db(PApplet parent, int glitchType)
  {
    this.parent = parent;
    glfx = new GlitchFXdb(parent, glitchType);
    initAudioNoise(parent);
  }
  
  private void initAudioNoise(PApplet parent) {
      minim = new Minim(parent);
      out = minim.getLineOut();
      wn = new WhiteNoise(0.01);
  }
  
  public void run()
  {
    glfx.open();
    for(int i=timedGlitchers.size()-1;i>=0;i--)
    {
      TimedGlitcher tg = timedGlitchers.get(i);
      tg.run();
      setNoise();
      if(tg.done())
        timedGlitchers.remove(tg);
    }
    glfx.close();
    if(glitching && timedGlitchers.size()<=0) {
      glitching = false;
      out.removeSignal(wn);
    }
  }
  
  public void close() {
     out.close();
     minim.stop();
  }

  private void setNoise() {
    //float amp = map(mouseY, 0, height, 1, 0);
    //float pan = map(mouseX, 0, width, -1, 1);
    wn.setAmp(noise(frameCount*0.05));
    wn.setPan(noise(frameCount*0.05));
  }
  
  public void glitch(int x, int y, int spreadX, int spreadY, int diaX, int diaY, int amount, float randomness, int attack, int sustain)
  {
    glitching = true;
    out.addSignal(wn);
    for(int i = 0; i < amount; i++) 
    {
      int att = (int)parent.random(attack);
      timedGlitchers.add(new TimedGlitcher(  (int)(x+(parent.random(-spreadX/2, spreadX/2))), 
                          (int)(y+(parent.random(-spreadY/2, spreadY/2))), 
                          (int)(diaX*randomness), (int)(diaY*randomness), 
                          randomness, att,
                         (int)parent.random(sustain))
                        );  
    }

  }
  
  private class TimedGlitcher
  {
    int x, y, diaX, diaY, on;
    int timer;
    float randomness;
    
    int sX, sY;
    
    int onset = 0;
    
    TimedGlitcher(int x, int y, int diaX, int diaY, float randomness, int on, int time)
    {
      this.x = x;
      this.y = y;
      this.diaX = diaX;
      this.diaY = diaY;
      this.randomness = randomness;
      this.on = on;
      this.timer = time;
      
      sX = (int)(parent.random(-10,10));
      sY = (int)(parent.random(-10,10));
    }
    
    void run()
    {
      if(onset >= on)
      {
        glfx.glitch(x, y, diaX, diaY, sX, sY);
        timer--;
      }      
      onset++;
    }
    
    boolean done()
    {
      if (timer <= 0) 
        return true;
      else
        return false;
    }
  }
}
