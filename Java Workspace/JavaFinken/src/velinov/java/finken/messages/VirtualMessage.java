package velinov.java.finken.messages;

import velinov.java.finken.drone.virtual.VirtualFinkenDrone;
import velinov.java.finken.messages.builders.VirtMsgBuilderFactory;
import velinov.java.finken.messages.builders.VirtualMessageBuilder;
import velinov.java.ivybus.message.Message;


/**
 * Describes a {@link VirtualFinkenDrone} {@link Message} - the messages that 
 * are sended from the virtual drones in VREP to the IVY-Bus.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public class VirtualMessage {
  
  private Message               message;
  private VirtualMessageBuilder builder;
  
  /**
   * @param _message
   */
  @SuppressWarnings("nls")
  public VirtualMessage(Message _message) {
    if (_message == null) {
      throw new NullPointerException("null message");
    }
    this.message = _message;
    this.builder = VirtMsgBuilderFactory.getMessageBuilder(
        this.message.getName());
  }
  
  /**
   * @return the {@link Message}.
   */
  public Message getMessage() {
    return this.message;
  }

  /**
   * build the message from the current state of the {@link VirtualFinkenDrone}.
   * @param _drone
   */
  public void buildMessage(VirtualFinkenDrone _drone) {
    if (this.builder == null) {
      return;
    }
    this.builder.buildMessage(this.message, _drone);
  }

}
