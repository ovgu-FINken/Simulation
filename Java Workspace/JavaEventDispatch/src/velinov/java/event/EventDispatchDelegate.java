package velinov.java.event;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;


/**
 * Redirects the {@code PropertyChangeListener}s from one 
 * {@code PropertyChangeSupport} to another {@code PropertyChangeSupport}.
 * 
 * @author Vladimir Velinov
 * @since 28.03.2015
 *
 */
public class EventDispatchDelegate implements PropertyChangeListener {
  
  private PropertyChangeSupport changeSupport;
  
  /**
   * constructor.
   * 
   * @param _changeSupport 
   *          the destination {@code PropertyChangeSupport} where
   *          to redirect.
   */
  public EventDispatchDelegate(PropertyChangeSupport _changeSupport) {
    this.changeSupport = _changeSupport;
  }

  @Override
  public void propertyChange(PropertyChangeEvent _event) {
    this.changeSupport.firePropertyChange(_event.getPropertyName(), 
        _event.getOldValue(), _event.getNewValue());
  }
}
