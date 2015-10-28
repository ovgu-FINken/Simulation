package velinov.java.finken.app.ui;

import java.beans.PropertyChangeListener;

import javax.swing.JPanel;

import velinov.java.event.EventDispatchable;


/**
 * Defines a {@code JPanel} that manages the opening and closing 
 * of a connection.
 * 
 * @author Vladimir Velinov
 * @since 25.04.2015
 *
 */
public interface ConnectPanel extends EventDispatchable {
  
  /**
   * a property-key, that is fired when a connect request has been initiated.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_CONNECT    = "connect";
  
  /**
   * a property-key, that is fired when a disconnect request has been initiated.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_DISCONNECT = "disconnect";
  
  
  /**
   * @return the {@code JPanel}.
   */
  public JPanel getPanel();
  
  /**
   * @return the {@code PropertyChangeListener} that updates the state of 
   * the {@code ConnectPanel} when the controlled object gets 
   * connected/disconnected.
   */
  public PropertyChangeListener getPropertyChangeListener();
}
