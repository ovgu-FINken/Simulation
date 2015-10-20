package velinov.java.finken.drone.virtual;

import java.util.List;

import fr.dgac.ivy.IvyException;
import velinov.java.finken.aircraft.Aircraft;
import velinov.java.ivybus.AbsIvyBusNode;
import velinov.java.ivybus.IvyBusNode;
import velinov.java.ivybus.message.Message;
import velinov.java.ivybus.message.MessageField;

/**
 * An {@link IvyBusNode} for {@link StandardVirtualFinkenDrone}s.
 * 
 * @author Vladimir Velinov
 * @since 04.05.2015
 */
public class VirtualDroneBusNode extends AbsIvyBusNode {
  
  @SuppressWarnings("nls")
  private static final String NODE_TITLE = "Link";
  
  private final Aircraft aircraft;
  private final int      ac_id;

  /**
   * default constructor.
   * @param _aircraft 
   */
  @SuppressWarnings("nls")
  public VirtualDroneBusNode(Aircraft _aircraft) {
    super(NODE_TITLE, _aircraft.getName() + " joined the bus");
    
    this.aircraft = _aircraft;
    this.ac_id    = this.aircraft.getId();
  }
  
  /**
   * Publish a {@link Message} to the Ivy bus.
   * @param _message 
   * @throws IvyException 
   */
  @SuppressWarnings("nls")
  public void publishMessage(Message _message) throws IvyException {
    String             message;
    List<MessageField> fields;
    
    fields  = _message.getMessageFields();
    message = this.ac_id + " " + _message.getName() + " ";
    
    for (MessageField field : fields) {
      String value = field.getValue();
      message = message + " " + value;
    }
    
    this.ivyBus.sendMsg(message);
  }

}
