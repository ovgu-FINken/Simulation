package velinov.java.vrep;

import velinov.java.event.AbsEventDispatchable;

/**
 * Standard implementation of {@link VrepClient}.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public class StandardVrepClient extends AbsEventDispatchable 
    implements VrepClient 
{  
  private final VrepConnection vrepConnection;
  private VrepServer           server;
  private boolean              isConnected;
  private int                  id;
  
  private boolean              wait;
  private int                  commRate;
  
  /**
   * default constructor.
   * @param _vrepConnection 
   */
  public StandardVrepClient(VrepConnection _vrepConnection) {
    if (_vrepConnection == null) {
      _vrepConnection = VrepConnectionUtils.getConnection();
    }
    this.vrepConnection  = _vrepConnection;
    this.commRate        = DEFAULT_COMMUNICATION_CICLE;
    this.isConnected     = false;
    
    this.waitUntilConnected(true);
  }

  @Override
  public int getClientId() {
    return this.id;
  }
  
  @Override
  public boolean isConnected() {
    return this.isConnected;
  }
  
  @Override
  public void waitUntilConnected(boolean _wait) {
    this.wait = _wait;
  }
  
  @SuppressWarnings("nls")
  @Override
  public void connectToServer(VrepServer _server) {
    if (_server == null) {
      throw new NullPointerException("null server");
    }
    
    if (!_server.isFree()) {
      throw new IllegalStateException("server is not free");
    }
    
    if (this.isConnected) {
      return;
    }
    
    this.server = _server;
    
    this.vrepConnection.simxFinish(-1);
    
    this.id = this.vrepConnection.simxStart(this.server.getIpAddress(), 
        this.server.getPort(), this.wait, true, 5000, this.commRate);
    
    if (this.id != -1) {
      this.isConnected = true;
      this.fireBooleanPropertyChanged(PROPERTY_CONNECTED, this.isConnected);
    }
    
  }
  
  @Override
  public void close() {
    if (!this.isConnected) {
      return;
    }

    this.vrepConnection.simxFinish(this.id);
    
    this.isConnected = false;
    this.fireBooleanPropertyChanged(PROPERTY_DISCONNECTED, this.isConnected);
  }
  
}