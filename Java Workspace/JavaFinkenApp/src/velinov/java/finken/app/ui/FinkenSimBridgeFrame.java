package velinov.java.finken.app.ui;

import java.awt.Dimension;

import javax.swing.JFrame;

import velinov.java.finken.app.FinkenSimBridge;


/**
 * Defines a simple {@code JFrame} for {@link FinkenSimBridge}.
 * 
 * @author Vladimir Velinov
 * @since 27.04.2015
 */
public class FinkenSimBridgeFrame extends JFrame {
  
  private static final Dimension FRAME_SIZE  = new Dimension(800, 500);
  
  /**
   * default constructor.
   */
  public FinkenSimBridgeFrame() {
    super(UIConstants.FRAME_LABEL);
    
    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    this.setSize(FRAME_SIZE);
    this.setLocationRelativeTo(null);
    this.setVisible(true);
  }
}
