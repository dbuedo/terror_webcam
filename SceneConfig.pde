

public class SceneConfig {
  
  public boolean isMirror=false;
  public boolean isFlick=false;
  public boolean isBlackAndWhite=false;
  public boolean isScanLines=false;
  public boolean isVerticalInterference=false;
  public boolean isCameraView=false;
 
  
  public boolean isScare=false;
  public boolean isFire=false;
  public boolean isFace=false;

  
  public String trigger = null;
  public long millis = 0;
  
  public SceneConfig(String line) {
    // line Format:  SECOND;FLAGS;TRIGGER
    // FLAGS Format: mirror=true,flick=false,byn=true,scan=true,vertInt=true,camera=true
    if(line!=null && !"".equals(line)) {
      String[] linePart = line.split(";");
      this.millis = Long.parseLong(linePart[0])*1000;
      this.trigger = ("null".equals(linePart[2])?null:linePart[2]);
      String[] flags = linePart[1].split(",");
      for(String flag : flags) {
         String[] flagPart = flag.split("=");
         if("mirror".equals(flagPart[0])) {
             isMirror = Boolean.parseBoolean(flagPart[1]);
         } else if("flick".equals(flagPart[0])) {
             isFlick = Boolean.parseBoolean(flagPart[1]);
         } else if("byn".equals(flagPart[0])) {
             isBlackAndWhite = Boolean.parseBoolean(flagPart[1]);
         } else if("scan".equals(flagPart[0])) {
             isScanLines = Boolean.parseBoolean(flagPart[1]);
         } else if("vertInt".equals(flagPart[0])) {
             isVerticalInterference = Boolean.parseBoolean(flagPart[1]);
         } else if("camera".equals(flagPart[0])) {
             isCameraView = Boolean.parseBoolean(flagPart[1]);
         }
      }      
    }     
  }
  
  

}
