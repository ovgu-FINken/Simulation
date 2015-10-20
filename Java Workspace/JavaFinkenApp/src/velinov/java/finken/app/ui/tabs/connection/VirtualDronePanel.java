package velinov.java.finken.app.ui.tabs.connection;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;

import javax.swing.BorderFactory;
import javax.swing.JPanel;

import velinov.java.bean.AbsEventDispatchable;


/**
 * @author Vladimir Velinov
 * @since 17.05.2015
 */
public class VirtualDronePanel extends AbsEventDispatchable {
  
  private static final Dimension SIZE = new Dimension(1, 50);
  
  private JPanel mainPanel;
  private JPanel leftPanel;
  private JPanel rightPanel;
  
  /**
   * default constructor.
   */
  public VirtualDronePanel() {
    this.mainPanel = new JPanel();
    this.mainPanel.setLayout(new BorderLayout());
    this.mainPanel.setPreferredSize(SIZE);
    this.mainPanel.setBorder(BorderFactory.createTitledBorder(
        "VirtualDrone0"));
    
    this.leftPanel  = new JPanel(new FlowLayout(FlowLayout.LEFT, 20, 0));
    this.rightPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 20, 0));
    
    this.mainPanel.add(this.leftPanel, BorderLayout.WEST);
    this.mainPanel.add(this.rightPanel, BorderLayout.EAST);
  }
  
  /**
   * @return the main panel.
   */
  public JPanel getPanel() {
    return this.mainPanel;
  }

}
