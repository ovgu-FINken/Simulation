package velinov.java.finken.drone.sensoric;

import velinov.java.vrep.VrepClient;
import velinov.java.vrep.objects.ProximitySensor;


/**
 * represents a Finken <code>ProximitySensor</code>.
 * 
 * @author Vladimir Velinov
 * @since Jul 8, 2015
 *
 */
public class FinkenProxSensor extends ProximitySensor {
  
  ProxSensorType type;
  
  /**
   * default constructor.
   * @param _type
   * @param _client
   */
  public FinkenProxSensor(ProxSensorType _type, VrepClient _client) {
    super(_type.getName(), _client);
    
    this.type = _type;
  }

  /**
   * constructor to initialize with the sensor type and the index of the
   * parent object name.
   * @param _type
   *     the <code>ProxSensorType</code>.
   * @param _nameSuffix 
   *     the index of the parent <code>VrepObjectName</code>.
   * @param _client
   */
  public FinkenProxSensor(ProxSensorType _type, String _nameSuffix,
      VrepClient _client) 
  {
    super(_type.getName()+_nameSuffix, _client);
    
    this.type = _type;
  }
  
  /**
   * @return the <code>ProxSensorType</code> of the <code>FinkenProxSensor</code>.
   */
  public ProxSensorType getType() {
    return this.type;
  }

}
