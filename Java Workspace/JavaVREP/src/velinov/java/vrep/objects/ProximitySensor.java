package velinov.java.vrep.objects;

import velinov.java.vrep.VrepClient;


/**
 * Represents <code>VrepObject</code> of type 
 * <code>VrepObjectType#PROXIMITY_SENSOR</code>.
 * 
 * @author Vladimir Velinov
 * @since Jul 8, 2015
 *
 */
public class ProximitySensor extends AbsVrepObject {
  
  protected float distance;

  /**
   * default constructor.
   * @param _name
   *     the name of the sciene object representing the ProximitySensor.
   * @param _client
   *     the <code>VrepClient</code>.
   */
  public ProximitySensor(String _name, VrepClient _client) {
    super(VrepObjectType.PROXIMITY_SENSOR, _name, _client);
    
  }
  
  /**
   * @return the distance measured by the proximity sensor.
   */
  public float getDistance() {
    return this.distance;
  }
  
  /**
   * set a new value for the distance measutred by the prox. sensor.
   * @param _distance
   */
  public void setDistance(float _distance) {
    this.distance = _distance;
  }

}
