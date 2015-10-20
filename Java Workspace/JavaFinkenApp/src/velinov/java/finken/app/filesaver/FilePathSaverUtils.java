package velinov.java.finken.app.filesaver;

import java.util.HashMap;
import java.util.Map;


/**
 * represents an utility class, used to save the <code>FilePathSaver</code>s
 * in a map for easy access by the other components which need the saved
 * file paths.
 * 
 * @author Vladimir Velinov
 * @since Oct 12, 2015
 *
 */
public class FilePathSaverUtils {
  
  private static FilePathSaverUtils        instance;
  
  private final Map<String, FilePathSaver> map;
  
  private FilePathSaverUtils() {
    this.map = new HashMap<String, FilePathSaver>();
  }
  
  /**
   * @return the singleton instance.
   */
  public static FilePathSaverUtils getInstance() {
    if (instance == null) {
      instance = new FilePathSaverUtils();
    }
    return instance;
  }
  
  /**
   * add a <code>FilePathSaver</code> to the map.
   * 
   * @param _key
   *          the key to identify the <code>FilePathSaver</code>.
   *          
   * @param _pathSaver
   *          the <code>FilePathSaver</code>.
   */
  @SuppressWarnings("nls")
  public void addFilePathSaver(String _key, FilePathSaver _pathSaver) {
    if (_key == null || _pathSaver == null) {
      throw new NullPointerException("null arguments");
    }
    this.map.put(_key, _pathSaver);
  }
  
  /**
   * get a <code>FilePathSaver</code> from the map.
   * 
   * @param _key
   *          the key identifying the <code>FilePathSaver</code>.
   *          
   * @return the <code>FilePathSaver</code> coresponding to the specified key.
   */
  public FilePathSaver getFilePathSaver(String _key) {
    return this.map.get(_key);
  }

}
