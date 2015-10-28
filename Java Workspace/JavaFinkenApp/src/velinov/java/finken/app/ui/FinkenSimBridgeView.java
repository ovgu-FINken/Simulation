package velinov.java.finken.app.ui;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import javax.swing.JTabbedPane;

import velinov.java.event.AbsEventDispatchable;
import velinov.java.event.EventDispatchDelegate;
import velinov.java.finken.app.ui.tabs.connection.ConnectionTab;
import velinov.java.finken.app.ui.tabs.messages.MessagesTab;
import velinov.java.finken.app.ui.tabs.settings.SettingsTab;


/**
 * defines the central view of the app.
 * 
 * @author Vladimir Velinov
 * @since Oct 11, 2015
 *
 */
public class FinkenSimBridgeView extends AbsEventDispatchable 
    implements PropertyChangeListener
{
  private final JTabbedPane           pane;
  private final ConnectionTab         connectionTab;
  private final SettingsTab           settingsTab;
  private final MessagesTab           messagesTab;
  private final EventDispatchDelegate eventDelegate;
  
  /**
   * default constructor.
   */
  public FinkenSimBridgeView() {
    this.pane          = new JTabbedPane();
    this.connectionTab = new ConnectionTab();
    this.settingsTab   = new SettingsTab();
    this.messagesTab   = new MessagesTab();
    this.eventDelegate = new EventDispatchDelegate(this.listeners);
    
    this.pane.addTab(this.connectionTab.getTabLabel(), this.connectionTab);
    this.pane.addTab(this.messagesTab.getTabLabel(), this.messagesTab);
    this.pane.addTab(this.settingsTab.getTabLabel(), this.settingsTab);
    
    this.connectionTab.getVrepConnectionPanel().addPropertyChangeListener(
        this.eventDelegate);
    
    this.settingsTab.getTelemetryChooserPanel().addPropertyChangeListener(
        this.eventDelegate);
  }
  
  /**
   * @return the view.
   */
  public JTabbedPane getView() {
    return this.pane;
  }
  
  /**
   * @return the <code>PropertyChangeListener</code> of the 
   *     <code>VrepConnectPanel</code>.
   */
  public PropertyChangeListener getVrepConnectionListener() {
    return this.connectionTab.getVrepConnectionPanel().
        getPropertyChangeListener();
  }

  @Override
  public void propertyChange(PropertyChangeEvent _event) {
  
  }
}
