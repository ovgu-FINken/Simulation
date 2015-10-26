package velinov.java.vrep.scene;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import coppelia.FloatWA;
import coppelia.IntWA;
import coppelia.StringWA;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.VrepConnection;
import velinov.java.vrep.VrepConnectionUtils;
import velinov.java.vrep.objects.VrepObjectType;
import velinov.java.vrep.objects.Shape;

/**
 * Represents the V-REP scene. Provides information about the objects 
 * in the scene.
 * 
 * @author Vladimir Velinov
 * @since 01.05.2015
 */
public class VrepScene {
  
  private final VrepClient     client;
  private final VrepConnection vrepConnection;
  
  private List<Shape>          shapeObjects;
  private boolean              loaded;
  
  
  /**
   * default constructor.
   * @param _client
   */
  @SuppressWarnings("nls")
  public VrepScene(VrepClient _client) {
    if (_client == null) {
      throw new NullPointerException("client null");
    }
    
    this.client         = _client;
    this.shapeObjects   = new ArrayList<Shape>();
    this.vrepConnection = VrepConnectionUtils.getConnection();
    this.shapeObjects   = new ArrayList<Shape>();
    this.loaded         = false;
  }
  
  /**
   * @return all {@link Shape} objects in the scene.
   */
  public List<Shape> getShapeObjects() {
    return this.shapeObjects;
  }
  
  /**
   * loads the V-REP scene with its objects.
   */
  public void loadScene() {
    if (this.loaded) {
      return;
    }
    
    this.shapeObjects = this.retrieveShapeObjects();
    this.loaded       = true;
  }
  
  /**
   * @return <code>true</code> if the V-REP scene has already been loaded.
   */
  public boolean isLoaded() {
    return this.loaded;
  }
  
  /**
   * @return a list of all {@link Shape} objects.
   */
  @SuppressWarnings("nls")
  public List<Shape> retrieveShapeObjects() {
    List<Shape>            shapeObjects;
    IntWA                  handles;
    IntWA                  intData;
    FloatWA                floatData;
    StringWA               names;
    int                    ret;
    
    if (!this.client.isConnected()) {
      throw new IllegalArgumentException("Client not started");
    }
    
    handles    = new IntWA(1);
    intData    = new IntWA(1);
    floatData  = new FloatWA(1);
    names      = new StringWA(1);
    
    ret = this.vrepConnection.simxGetObjectGroupData(this.client.getClientId(),
        VrepObjectType.SHAPE.getType(), VrepConnection.GET_OBJECT_NAMES, handles,
        intData, floatData, names, VrepConnection.simx_opmode_oneshot_wait);
    
    if (ret != VrepConnection.simx_return_ok) {
      return Collections.EMPTY_LIST;
    }
    
    if (names.getLength() == 0) {
      return Collections.EMPTY_LIST;
    }
    
    shapeObjects = new ArrayList<Shape>();
    
    for (int i = 0; i < names.getLength(); i ++) {
      String name   = (names.getArray()[i]);
      int    handle = handles.getArray()[i];
      Shape  shape  = new Shape(name, handle, this.client);
      
      shapeObjects.add(shape);
    }

    return shapeObjects;
  }

}