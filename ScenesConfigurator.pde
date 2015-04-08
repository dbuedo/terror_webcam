

public class ScenesConfigurator {
  
  ArrayList<SceneConfig> scenes;
  int currentScenePos = -1;
  
  void loadScenes() {
    System.out.println("Loading scenes...");
    scenes = new ArrayList<SceneConfig>();
    BufferedReader reader = createReader("config/Scenes.txt");
    try {
      String line = reader.readLine();
      while(line!=null) {
        scenes.add(new SceneConfig(line));
        line = reader.readLine();
      }
    } catch (IOException e) {
      e.printStackTrace();
      exit();
    } finally {
      try {
        reader.close();
      } catch (IOException e) {
        e.printStackTrace();
        exit();
      }
    }
    System.out.println(scenes.size() +" scenes loaded.");
  }
  
  SceneConfig nextScene() {
    if(currentScenePos < scenes.size()-1) {
      currentScenePos++;
      System.out.println("Scene " + currentScenePos);
      return scenes.get(currentScenePos);
    } else {
      return null;
    }
  }
  
  void restart() {
    currentScenePos = -1;
  }
}
