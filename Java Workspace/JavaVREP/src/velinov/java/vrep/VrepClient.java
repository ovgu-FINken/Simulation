package velinov.java.vrep;

import velinov.java.event.EventDispatchable;

/**
 * Describes a VREP-Client which connects to a VREP-Server.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public interface VrepClient extends EventDispatchable {
  
  /**
   * the default communication cicle in milli-seconds.
   */
  public final static int DEFAULT_COMMUNICATION_CICLE = 2;
  
  /**
   * A property, that is fired when the client has connected successfully
   * to a server.
   */
  @SuppressWarnings("nls")
  public final static String PROPERTY_CONNECTED       = "connected";
  
  /**
   * A property, that is fired when the client has disconnected 
   * from the server.
   */
  @SuppressWarnings("nls")
  public final static String PROPERTY_DISCONNECTED    = "disconnected";
  
  /**
   * @return the id of the client, created when connected 
   * to a particular server.
   */
  int getClientId();
  
  /**
   * @return {@code true} if the client is connected to the server.
   */
  boolean isConnected();
  
  /**
   * Set if the calling thread should be suspended when calling
   * {@code VrepClient#connectToServer(VrepServer)} until it connects.
   *  
   * @param _wait {@code true} if should wait.
   */
  void waitUntilConnected(boolean _wait);
  
  /**
   * connects to server.
   * @param _server the server to connect to.
   */
  void connectToServer(VrepServer _server);

  /**
   * closes the connection with the server.
   */
  void close();
  

}
