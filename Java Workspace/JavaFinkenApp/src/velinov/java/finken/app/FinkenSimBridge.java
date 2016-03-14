package velinov.java.finken.app;

import javax.swing.SwingUtilities;


/**
 * main method of the {@code FinkenSimBridge}.
 * 
 * @author Vladimir Velinov
 * @since 12.04.2015
 *
 */
public class FinkenSimBridge {
  
  /**
   * main method.
   * 
   * @param _args
   *          input parameters
   */
  public static void main(String[] _args) {
    SwingUtilities.invokeLater(new Runnable() {
      @Override
      public void run() {
        new FinkenSimBridgeController();
      }
    });
  }

}
