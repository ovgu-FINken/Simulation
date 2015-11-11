package velinov.java.vrep;


/**
 * holds a static singleton instance of the <code>VrepClient</code>.
 * 
 * @author Vladimir Velinov
 * @since Oct 28, 2015
 *
 */
public class VrepClientUtils {
  
  private static VrepClient vrepClient;
  
  private VrepClientUtils() {
    // no instances
  }
  
  /**
   * @return the instance of <code>VrepClient</code>.
   */
  public static VrepClient getVrepClient() {
    if (vrepClient == null) {
      vrepClient = new StandardVrepClient(null);
    }
    
    return vrepClient;
  }
}
