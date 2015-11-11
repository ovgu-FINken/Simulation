package velinov.java.finken.drone;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.SAXException;

import velinov.java.event.AbsEventDispatchable;
import velinov.java.finken.drone.real.RealFinkenDrone;
import velinov.java.finken.drone.virtual.VirtualFinkenDrone;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.scene.VrepScene;


/**
 * a singleton pool that holds the <code>FinkenDrone</code>s.
 * 
 * @author Vladimir Velinov
 * @since Oct 27, 2015
 *
 */
public class DronePool extends AbsEventDispatchable {
  
  /**
   * a property that is fired when the new <code>VirtualFinkenDrone</code>s are
   * retrieved from the V-REP scene.
   */
  @SuppressWarnings("nls")
  public static final String      VIRTUAL_DRONES_RETRIEVED = "virtDorones";
  
  /**
   * a property that is fired when the new <code>RealFinkenDrone</code>s are
   * retrieved from the V-REP scene.
   */
  @SuppressWarnings("nls")
  public static final String      REAL_DRONES_RETRIEVED    = "realDrones";
  
  private List<VirtualFinkenDrone> virtualDrones;
  private List<RealFinkenDrone>    realDrones;
  private VrepScene                scene;
  private VrepClient               client;
  
  private static DronePool         instance;
  
  private DronePool(VrepScene _scene, VrepClient _client) {
    this.virtualDrones = new ArrayList<VirtualFinkenDrone>();
    this.realDrones    = new ArrayList<RealFinkenDrone>();
    this.scene         = _scene;
    this.client        = _client;
  }
  
  /**
   * @param _scene 
   * @param _client 
   * 
   * @return the singleton instance.
   */
  public static DronePool getInstance(VrepScene _scene, VrepClient _client) {
    if (instance == null) {
      instance = new DronePool(_scene, _client);
    }
    
    return instance;
  }
  
  /**
   * @return a <code>List</code> containing all 
   *     <code>VirtualFinkenDrone</code>s in the <code>VrepScene</code>.
   */
  public List<VirtualFinkenDrone> getVirtualDrones() {
    return this.virtualDrones;
  }
  
  /**
   * @return a <code>List</code> containing all 
   *     <code>RealFinkenDrones</code> in the <code>VrepScene</code>.
   */
  public List<RealFinkenDrone> getRealDrones() {
    return this.realDrones;
  }
  
  /**
   * starts a new scann for <code>VirtualFinkenDrone</code>s and returns the
   * retrieved virtual drones.
   * 
   * @return a <code>List</code> containing all 
   *     <code>VirtualFinkenDrone</code>s in the <code>VrepScene</code>.
   * 
   * @throws SAXException
   * @throws IOException
   */
  @SuppressWarnings("nls")
  public List<VirtualFinkenDrone> retrieveVirtualDrones() 
      throws SAXException, IOException 
  {
    if (!this.client.isConnected()) {
      throw new IllegalStateException("Vrep client not connected");
    }
    
    this.virtualDrones = FinkenDroneScanner.retrieveVirtualDrones(
        this.scene, this.client);
    
    this.firePropertyChange(VIRTUAL_DRONES_RETRIEVED, null, this.virtualDrones);
    
    return this.virtualDrones;
  }
  
  /**
   * 
   * starts a new scann for <code>RealFinkenDrone</code>s and returns the
   * retrieved real drones.
   * 
   * @return a <code>List</code> containing all 
   *     <code>RealFinkenDrone</code>s in the <code>VrepScene</code>.
   * 
   * 
   * @throws SAXException
   * @throws IOException
   */
  @SuppressWarnings("nls")
  public List<RealFinkenDrone> retrieveRealDrones() 
      throws SAXException, IOException 
  {
    if (!this.client.isConnected()) {
      throw new IllegalStateException("Vrep client not connected");
    }
    this.realDrones = FinkenDroneScanner.retrieveRealDrones(
        this.scene, this.client);
    
    this.firePropertyChange(REAL_DRONES_RETRIEVED, null, this.realDrones);
    
    return this.realDrones;
  }

}
