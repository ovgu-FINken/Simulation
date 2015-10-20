package velinov.java.finken.app.ui;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;


/**
 * Provides basic user-interface utilities.
 * 
 * @author Vladimir Velinov
 * @since 13.04.2015
 */
public class UIUtils { 
  
  /**
   * Set the text of the specified button in a new EDT thread.
   * @param _component 
   * @param _text
   */
  @SuppressWarnings("nls")
  public static void setText(final JComponent _component, final String _text) {
    
    if (_text == null || _text.isEmpty()) {
      throw new IllegalArgumentException("Illegal text");
    }
    
    SwingUtilities.invokeLater(new Runnable() {
      @Override
      public void run() {
        if (_component instanceof JButton) {
          ((JButton)_component).setText(_text);
        }
        else if (_component instanceof JLabel) {
          ((JLabel)_component).setText(_text);
        }
        else {
          throw new IllegalArgumentException("Unsuported JComponent");
        }
      }
    });
  }

}
