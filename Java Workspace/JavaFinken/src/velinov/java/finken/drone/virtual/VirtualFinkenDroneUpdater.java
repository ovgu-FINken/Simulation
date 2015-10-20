package velinov.java.finken.drone.virtual;

import java.util.ArrayList;
import java.util.List;

import coppelia.FloatWA;
import coppelia.IntWA;
import coppelia.StringWA;
import velinov.java.vrep.data.AngularVelocity;
import velinov.java.vrep.data.LinearVelocity;
import velinov.java.vrep.data.Orientation;
import velinov.java.vrep.data.Position;
import velinov.java.vrep.objects.AbsObjectUpdater;
import velinov.java.vrep.objects.ObjectUpdater;
import velinov.java.vrep.objects.VrepObjectType;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.VrepConnection;

/**
 * An implementation of {@link ObjectUpdater}, updating the 
 * <code>VirtualFinkenDrone</code>s with dynamic data from V-Rep.
 * 
 * @author Vladimir Velinov
 * @since 04.05.2015
 */
public class VirtualFinkenDroneUpdater extends AbsObjectUpdater {

  private final List<VirtualFinkenDrone> virtualDrones;
  
  /**
   * default constructor.
   * @param _vrepClient 
   */
  public VirtualFinkenDroneUpdater(VrepClient _vrepClient) {
    super(_vrepClient);
    
    this.virtualDrones = new ArrayList<VirtualFinkenDrone>();
  }

  /**
   * add a {@link VirtualFinkenDrone} to the update list.
   * @param _object
   */
  @SuppressWarnings("nls")
  public void addVirtualDrone(StandardVirtualFinkenDrone _object) {
    if (_object == null) {
      throw new NullPointerException("null object");
    }
    this.virtualDrones.add(_object);
  }

  /**
   * add a list of <code>VirtualFinkenDrone</code>s to the update list.
   * @param _objects
   */
  @SuppressWarnings("nls")
  public void addVirtualDrones(List<VirtualFinkenDrone> _objects) {
    if (_objects == null) {
      throw new NullPointerException("null objects");
    }
    this.virtualDrones.addAll(_objects);
  }
  
  @Override
  protected void onObjectUpdate() {
    this.updateVirtualDrones();
  }
  
  
  private void updateVirtualDrones() {
    boolean success = true;
    boolean updated = false;
    
    updated = this.updateParameters(
        VrepConnection.GET_ABSOLUTE_POSITION_AND_ORIENTATION);
    success = success && updated;
    updated = this.updateParameters(
        VrepConnection.GET_LINEAR_AND_ANGULAR_VELOCITY);
    success = success && updated;
    
    if (success) {
      this.fireBooleanPropertyChanged(PROPERTY_OBJECTS_UPDATED, true);
    }
  }
  
  private boolean updateParameters(int _paramType) {
    IntWA    handles;
    IntWA    intData;
    FloatWA  floatData;
    StringWA stringData;
    int      ret;
    
    handles    = new IntWA(1);
    intData    = new IntWA(1);
    floatData  = new FloatWA(1);
    stringData = new StringWA(1);
    
    ret = this.vrepConnection.simxGetObjectGroupData(
        this.vrepClient.getClientId(), VrepObjectType.SHAPE.getType(),
        _paramType, handles, intData, floatData, 
        stringData, VrepConnection.simx_opmode_oneshot_wait);
    
    if (ret != VrepConnection.simx_return_ok) {
      return false;
    }
    
    for (VirtualFinkenDrone drone : this.virtualDrones) {
      int inx;
      
      inx = drone.getSceneIndex();
      inx = inx * 6;
      
      float x  = floatData.getArray()[inx];
      float y  = floatData.getArray()[inx + 1];
      float z  = floatData.getArray()[inx + 2];
      float xx = floatData.getArray()[inx + 3];
      float yy = floatData.getArray()[inx + 4];
      float zz = floatData.getArray()[inx + 5];
      
      switch (_paramType) {
      case VrepConnection.GET_ABSOLUTE_POSITION_AND_ORIENTATION:
        Position    position;
        Orientation orientation;
        
        position    = new Position(x, y, z);
        orientation = new Orientation(xx, yy, zz);
        
        drone.setOrientation(orientation);
        drone.setPosition(position);
        break;
        
      case VrepConnection.GET_LINEAR_AND_ANGULAR_VELOCITY:
        LinearVelocity  linVelocity;
        AngularVelocity angularVelocity;
        
        linVelocity     = new LinearVelocity(x, y, z);
        angularVelocity = new AngularVelocity(xx, yy, zz);
        
        drone.setLinearVelocity(linVelocity);
        drone.setAngularVelocity(angularVelocity);
        break;
      
      }
      
    }
    
    return true;
  }

}
