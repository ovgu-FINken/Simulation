package velinov.java.finken;

import java.io.Closeable;
import java.io.IOException;

/**
 * Utility class for IO operations.
 * 
 * @author vladimir velinov
 * @since 23.10.2014
 *
 */
public class IOUtilities {
  
  /**
   * Utility method to close an {@code InputStream} without handling
   * the thrown {@code IOException}.
   * 
   * @param _stream
   *          the {@code Closable} to be silently closed.
   */
  @SuppressWarnings("nls")
  public static void closeSilently(Closeable _stream) {
    if (_stream == null) {
      throw new NullPointerException("Null Inputstream");
    }
    
    try {
      _stream.close();
    }
    catch (IOException _e) {
      // Dummy
    }
  }
  
}
