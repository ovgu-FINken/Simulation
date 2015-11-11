package velinov.java.event;

import java.beans.PropertyChangeListener;


/**
 * defines an interface to an object that can dispatch events to a list of 
 * registered <code>PropertyChangeListener</code>s.
 * 
 * @author Vladimir Velinov
 * @since 18.03.2015
 *
 */
public interface EventDispatchable {
  
  /**
   * Add a {@link PropertyChangeListener} which will be asynchronously
   * notified when a property has changed it's value.
   * 
   * @param _listener 
   *          a listener implementing the {@link PropertyChangeListener}
   *          interface.
   */
  public void addPropertyChangeListener(PropertyChangeListener _listener);
  
  /**
   * Add a {@link PropertyChangeListener} which will be asynchronously
   * notified when the specified property has changed it's value.
   * 
   * @param _property 
   *          the property to observe.
   * @param _listener 
   *          a listener implementing {@link PropertyChangeListener}.
   *          interface.
   */
  public void addPropertyChangeListener(String _property, 
      PropertyChangeListener _listener);
  
  /**
   * Adds a {@link PropertyChangeListener} which will be asynchronously
   * notified when one of the specified properties has changed its value.
   * 
   * @param _listener 
   *          a listener implementing {@link PropertyChangeListener}.
   * @param _strings 
   *          an array of properties to observe.
   */
  public void addPropertyChangeListener(PropertyChangeListener _listener,
      String... _strings);
  
  /**
   * Removes the specified {@link PropertyChangeListener} from the list of
   * observers.
   * @param _listener 
   *          a listener implementing the {@link PropertyChangeListener}
   *          interface.
   */
  public void removePropertyChangeListener(PropertyChangeListener _listener);
  
  /**
   * Removes the specified {@link PropertyChangeListener}, observing the
   * specified property, from the list of observers.
   * 
   * @param _property 
   *          the property which the listener is observing.
   * @param _listener 
   *          a listener implementing the {@link PropertyChangeListener}
   *          interface.
   */
  public void removePropertyChangeListener(String _property, 
      PropertyChangeListener _listener);

}
