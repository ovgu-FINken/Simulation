package velinov.java.vrep;

/**
 * Wrapping of {@link VrepConnection} into a singleton pattern.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public class VrepConnectionUtils {
  
  private static VrepConnection instance;
  
  private VrepConnectionUtils() {
    // no instances
  }
  
  /**
   * @return the instance of {@link VrepConnection}.
   */
  public static VrepConnection getConnection() {
    if (instance == null) {
      instance = new VrepConnection();
    }
    
    return instance;
  }

}
