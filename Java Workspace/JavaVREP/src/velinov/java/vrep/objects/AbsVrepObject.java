package velinov.java.vrep.objects;

import velinov.java.event.AbsEventDispatchable;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.VrepConnection;
import velinov.java.vrep.VrepConnectionUtils;
import velinov.java.vrep.data.AngularVelocity;
import velinov.java.vrep.data.LinearVelocity;
import velinov.java.vrep.data.Orientation;
import velinov.java.vrep.data.Position;
import coppelia.IntW;

/**
 * an abstract implementation of {@link VrepObject}.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public abstract class AbsVrepObject extends AbsEventDispatchable implements VrepObject {
  
  protected final VrepClient     client;
  protected final VrepConnection vrepConnection;
  
  private   final VrepObjectType objectType;
  private   final VrepObjectName objectName;
  protected final int            handle;
  private   int                  sceneIndex;
  
  private Position               position;
  private Orientation            orientation;
  private LinearVelocity         linearVelocity;
  private AngularVelocity        angularVelocity;    

  @SuppressWarnings("nls")
  protected AbsVrepObject(VrepObjectType _type, String _name, int _handle, 
      VrepClient _client) 
  {
    if (_name == null || _name.isEmpty()) {
      throw new IllegalArgumentException("Illegal name");
    }
    if (_client == null || !_client.isConnected()) {
      throw new IllegalArgumentException("Illegal client");
    }
    if (_handle < 0) {
      throw new IllegalArgumentException("negative id");
    }
    
    this.vrepConnection = VrepConnectionUtils.getConnection();
    this.objectType     = _type;
    this.objectName     = new VrepObjectName(_name);
    this.client         = _client;
    this.handle         = _handle;
    this.position       = new Position(0, 0, 0);
    this.orientation    = new Orientation(0, 0, 0);
  }

  @SuppressWarnings("nls")
  protected AbsVrepObject(VrepObjectType _type, String _name, VrepClient _client) {
    if (_name == null || _name.isEmpty()) {
      throw new IllegalArgumentException("Illegal name");
    }
    
    if (_client == null || !_client.isConnected()) {
      throw new IllegalArgumentException("Illegal client");
    }
    
    this.vrepConnection = VrepConnectionUtils.getConnection();
    this.objectType     = _type;
    this.objectName     = new VrepObjectName(_name);
    this.client         = _client;
    this.handle         = this._retrieveHandle();
    this.position       = new Position(0, 0, 0);
    this.orientation    = new Orientation(0, 0, 0);
  }
  
  @Override
  public VrepObjectName getObjectName() {
    return this.objectName;
  }
  
  @Override
  public VrepObjectType getObjectType() {
    return this.objectType;
  }
  
  @Override
  public void setSceneIndex(int _index) {
    this.sceneIndex = _index;
  }
  

  @Override
  public int getSceneIndex() {
    return this.sceneIndex;
  }

  @Override
  public IntW getObjectHandle() {
    return new IntW(this.handle);
  }
  
  @Override
  public int getIntObjectHandle() {
    return this.handle;
  }
  
  @Override
  public VrepClient getCLient() {
    return this.client;
  }
  
  @Override
  public Position getPosition() {
    return this.position;
  }
  
  @Override
  public void setPosition(Position _position) {
    this.position = _position;
  }
  
  @Override
  public Orientation getOrientation() {
    return this.orientation;
  }
  
  @Override
  public void setOrientation(Orientation _orientation) {
    this.orientation = _orientation;
  }
  
  /**
   * Set the linear velocity of the object.
   * @param _linV 
   */
  @Override
  public void setLinearVelocity(LinearVelocity _linV) {
    this.linearVelocity = _linV;
  }
  
  /**
   * Set the angular velocity of the object.
   * @param _angV
   */
  @Override
  public void setAngularVelocity(AngularVelocity _angV) {
    this.angularVelocity = _angV;
  }
  
  @Override
  public AngularVelocity getAngularVelocity() {
    return this.angularVelocity;
  }
  
  @Override
  public LinearVelocity getLinearVelocity() {
    return this.linearVelocity;
  }
  
  @SuppressWarnings("nls")
  private int _retrieveHandle() {
    IntW handle = new IntW(0);
    int  ret;
    
    ret = this.vrepConnection.simxGetObjectHandle(this.client.getClientId(),
        this.objectName.getFullName(), handle, 
        VrepConnection.simx_opmode_oneshot_wait);
    
    if (ret==VrepConnection.simx_return_ok) {
      return handle.getValue();
    }
    else {
      throw new IllegalArgumentException("Object not found");
    }
  }
  
  @Override
  public boolean equals(Object _other) {
    VrepObject     object;
    VrepObjectName objectName;
    
    if (!(_other instanceof VrepObject)) {
      return false;
    }
    
    object     = (VrepObject) _other;
    objectName = object.getObjectName();
    
    return this.objectName.equals(objectName);
  }

}
