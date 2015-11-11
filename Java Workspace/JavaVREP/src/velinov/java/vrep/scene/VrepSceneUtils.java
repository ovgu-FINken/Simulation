package velinov.java.vrep.scene;

import velinov.java.vrep.VrepClient;


/**
 * an utility class that holds a static instance of the <code>VrepScene</code>.
 * 
 * @author Vladimir Velinov
 * @since Oct 28, 2015
 *
 */
public class VrepSceneUtils {
  
  private static VrepScene vrepScene;
  
  private VrepSceneUtils() {
    // no instances.
  }

  /**
   * @param _client
   * 
   * @return the singleton instance to the <code>VrepScene</code>.
   */
  @SuppressWarnings("nls")
  public static VrepScene getVrepScene(VrepClient _client) {
    if (_client == null) {
      throw new NullPointerException("null client");
    }
    
    if (vrepScene == null) {
      vrepScene = new VrepScene(_client);
    }
    
    return vrepScene;
  }
}
