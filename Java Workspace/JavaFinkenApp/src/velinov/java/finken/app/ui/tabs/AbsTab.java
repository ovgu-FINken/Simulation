package velinov.java.finken.app.ui.tabs;

import javax.swing.JPanel;


/**
 * defines an abstract <code>JPanel</code> representing a Tab 
 * in the <code>FinkenSimBridgeView</code>.
 * 
 * @author Vladimir Velinov
 * @since Oct 11, 2015
 *
 */
public abstract class AbsTab extends JPanel {
  
  /**
   * @return the label of the tab.
   */
  public abstract String getTabLabel();
}