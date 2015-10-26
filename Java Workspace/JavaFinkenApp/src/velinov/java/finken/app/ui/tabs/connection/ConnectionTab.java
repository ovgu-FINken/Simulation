package velinov.java.finken.app.ui.tabs.connection;

import javax.swing.Box;
import javax.swing.BoxLayout;

import velinov.java.finken.VREPRealTimePlot;
import velinov.java.finken.app.ui.ConnectPanel;
import velinov.java.finken.app.ui.tabs.AbsTab;
import velinov.java.jfreechart.realtime.RealTimePlot;

/**
 * a <code>JPanel</code> defining the view for the connection tab 
 * of the <code>FinkenSimBridgeView</code>.
 * 
 * @author Vladimir Velinov
 * @since 12.04.2015
 */
public class ConnectionTab extends AbsTab {

  @SuppressWarnings("nls")
  private static final String TAB_LABEL = "Connection";

  private final ConnectPanel          vrepPanel;
  private final ConnectPanel          ivyBusPanel;
  private final VirtualDronePanel     virtualPanel;
  private final RealTimePlot          plot;

  /**
   * defualt constructor.
   */
  public ConnectionTab() {
    this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

    this.plot         = new VREPRealTimePlot();
    this.vrepPanel    = new VrepConnectPanel();
    this.ivyBusPanel  = new IvyBusConnectPanel();
    this.virtualPanel = new VirtualDronePanel();

    this.add(this.vrepPanel.getPanel());
    this.add(Box.createVerticalStrut(10));
    this.add(this.ivyBusPanel.getPanel());
    this.add(Box.createVerticalStrut(200));
    this.add(this.virtualPanel.getPanel());
    this.add(this.plot.getPanel());
  }
  
  @Override
  public String getTabLabel() {
    return ConnectionTab.TAB_LABEL;
  }

  /**
   * @return the vrep connection panel.
   */
  public ConnectPanel getVrepConnectionPanel() {
    return this.vrepPanel;
  }

  /**
   * @return the ivy-bus connection panel.
   */
  public ConnectPanel getIvyBusConnectPanel() {
    return this.ivyBusPanel;
  }

}