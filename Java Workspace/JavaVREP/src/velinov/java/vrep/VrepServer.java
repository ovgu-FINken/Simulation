package velinov.java.vrep;


/**
 * Describes a VREP-server running in the VREP environment, to which
 * a {@link VrepClient} can connect to. Only one {@link VrepClient} can
 * connect to a {@code VrepServer} at a given time. 
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public interface VrepServer {
  
  /**
   * @return {@code true} if the server is free to connect to and 
   *     {@code false} if the server is already used by a {@link VrepClient}.
   */
  boolean isFree();
  
  /**
   * set if the server is free or busy.
   * @param _isFree
   */
  void setIsFree(boolean _isFree);
  
  /**
   * @return the ip address where the server is located.
   */
  String getIpAddress();
  
  /**
   * @return the port number of the server.
   */
  int getPort();

}
