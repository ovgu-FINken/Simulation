package velinov.java.vrep;


/**
 * Standard implementation of {@link VrepServer}.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public class StandardVrepServer implements VrepServer {
  
  private String  ipAddress;
  private int     portNumner;
  private boolean isFree;
  
  
  /**
   * default constructor.
   * 
   * @param _ipAddress 
   *     the IP address where the server is situated.
   * @param _port
   *     the port number to conenct to.
   */
  @SuppressWarnings("nls")
  public StandardVrepServer(String _ipAddress, int _port) {
    if (_ipAddress == null || _ipAddress.isEmpty()) {
      throw new IllegalArgumentException("illegal IP address");
    }
    
    this.ipAddress  = _ipAddress;
    this.portNumner = _port;
    
    this.setIsFree(true);
  }

  @Override
  public boolean isFree() {
    return this.isFree;
  }

  @Override
  public void setIsFree(boolean _isFree) {
    this.isFree = _isFree;
  }

  @Override
  public String getIpAddress() {
    return this.ipAddress;
  }

  @Override
  public int getPort() {
    return this.portNumner;
  }

}
