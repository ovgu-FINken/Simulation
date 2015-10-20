package velinov.java.finken.messages.builders;

import velinov.java.finken.drone.virtual.VirtualFinkenDrone;
import velinov.java.ivybus.message.Message;
import velinov.java.ivybus.message.MessageField;


/**
 * An abstract class to initialize the {@link MessageField}s of a 
 * particular {@link Message}, given the current state 
 * of the {@link VirtualFinkenDrone}.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public abstract class VirtualMessageBuilder {
  
  /**
   * initialize the message from the current state of the drone.
   * @param _msg 
   * @param _drone
   */
  public abstract void buildMessage(Message _msg, VirtualFinkenDrone _drone);

}
