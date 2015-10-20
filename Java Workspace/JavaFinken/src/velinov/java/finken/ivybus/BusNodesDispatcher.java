package velinov.java.finken.ivybus;

import java.util.ArrayList;
import java.util.List;

import velinov.java.finken.drone.AbsFinkenDrone;

/**
 * Joins and disconnects {@link AbsFinkenDrone}s from the Ivy-bus on request.
 * 
 * @author Vladimi Velinov
 * @since 04.05.2015
 */
public class BusNodesDispatcher {
  
  private final List<AbsFinkenDrone> drones;
  
  /**
   * default constructor.
   */
  public BusNodesDispatcher() {
    this.drones = new ArrayList<AbsFinkenDrone>();
  }
  
  /**
   * Adds drones to the list.
   * Note: modifing the list from outside will not affect this list !
   * @param _drones
   */
  public void addNodes(List<AbsFinkenDrone> _drones) {
    this.drones.addAll(_drones);
  }
  
  /**
   * joins all nodes to the Ivy bus.
   */
  public void joinAllNodes() {
    for (AbsFinkenDrone drone : this.drones) {
      if (drone.isConnectedToBus()) {
        return;
      }
      drone.joinIvyBus();
    }
  }
  
  /**
   * remove all nodes from the bus.
   */
  public void disconnectAllNodes() {
    for (AbsFinkenDrone drone : this.drones) {
      if (!drone.isConnectedToBus()) {
        return;
      }
      drone.leaveIvyBus();
    }
  }
  
  /**
   * @param _drone
   */
  @SuppressWarnings("nls")
  public void joinNode(AbsFinkenDrone _drone) {
    throw new IllegalStateException("not implemented");
  }
  
  /**
   * @param _drone
   */
  @SuppressWarnings("nls")
  public void disconnectNode(AbsFinkenDrone _drone) {
    throw new IllegalStateException("not implemented");
  }

}
