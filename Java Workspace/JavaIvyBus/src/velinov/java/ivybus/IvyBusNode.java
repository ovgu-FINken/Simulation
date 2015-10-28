package velinov.java.ivybus;

import java.util.List;

import fr.dgac.ivy.IvyException;
import velinov.java.event.EventDispatchable;
import velinov.java.ivybus.message.Message;

/**
 * an interface to describe a basic node on the Ivy-bus.
 * 
 * @author Vladimir Velinov
 * @since 07.04.2015
 *
 */
public interface IvyBusNode extends EventDispatchable {
  
  /**
   * a property-key, that is fired when the {@code IvyBusNode} gets
   * connected to the bus.
   */
  @SuppressWarnings("nls")
  public static final String IVY_NODE_CONNECTED    = "ivyNodeConnected";
  
  /**
   * a property-key, that is fired when the {@code IvyBusNode} disconnects
   * from the bus.
   */
  @SuppressWarnings("nls")
  public static final String IVY_NODE_DISCONNECTED = "ivyNodeDisconnected";
  
  /**
   * a property that is fired when a {@link Message} has been received.
   */
  @SuppressWarnings("nls")
  public static final String MESSAGE_RECEIVED      = "messageReceived";
  
  /**
   * a property-key that is fired when the {@code IvyBus} fails to connect 
   * to the bus.
   */
  @SuppressWarnings("nls")
  public static final String IVY_NODE_FAILED       = "ivyNodeFailed";
  
  /**
   * a property-key that is fired when the {@code IvyBus} fails to 
   * subscribe to a message.
   */
  @SuppressWarnings("nls")
  public static final String IVY_SUBSCRIBE_ERROR   = "errorSubscribe";
  
  /**
   * connect to the bus.
   */
  void connect();
  
  /**
   * 
   */
  void disconnect();
  
  /**
   * @return {@code true} if connected to the bus.
   */
  boolean isConnected();
  
  /**
   * Add a {@link Message} to subscribe to.
   * @param _message
   * @throws IvyException if an error occurs.
   */
  void subscribeToMessage(Message _message) throws IvyException;
  
  /**
   * subscribe to {@link Message} and id of the sender.
   * @param _id
   * @param _msg
   * @throws IvyException 
   */
  void subscribeToIdMessage(String _id, Message _msg) throws IvyException;
  
  /**
   * @return the names of the {@link Message}s that this node has subscribed to.
   */
  List<String> getSubscribedMassageNames();

}
