package velinov.java.finken.drone.sensoric;


/**
 * An Enum to describe the ultrasound sensors on the <code>FinkenDrone</code>.
 * Each sensor type is described by its unique id number and name.
 * The id is used to enable the fast look-ups of the sensors stored in a
 * Collections such as HashMap. The name is used to retrieve the sensors as 
 * <code>VrepObject</code> from the <code>VrepScene</code>.
 * 
 * @author Vladimir Velinov
 * @since Jul 8, 2015
 *
 */
@SuppressWarnings("nls")
public enum ProxSensorType {
  
  /**
   * ultrasound sensor at the front.
   */
  FRONT(0, "SimFinken_sensor_front"),
  
  /**
   * ultrasound sensor at the left.
   */
  LEFT(1, "SimFinken_sensor_left"),
  
  /**
   * ultrasound sensor at the back.
   */
  BACK(2, "SimFinken_sensor_back"),
  
  /**
   * ultrasound sensor at the right.
   */
  RIGHT(3, "SimFinken_sensor_right");
  
  private int    id;
  private String name;
  
  private ProxSensorType(int _id, String _name) {
    if (_name == null) {
      throw new NullPointerException("null name");
    }
    
    this.id   = _id;
    this.name = _name;
  }
  
  /**
   * @return the id of the sensor type.
   */
  public int getId() {
    return this.id;
  }
  
  /**
   * @return the name of the sensor type.
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @return the number of sensors.
   */
  public static int sensorCount() {
    return ProxSensorType.values().length;
  }
  
  /**
   * An utility method that retrieves the <code>ProxSensorType</code> which 
   * name matches the specified, as input parameter, name.
   * 
   * @param _name 
   *     the name to match.
   * @return 
   *     the retrieved <code>ProxSensorType</code> or <code>null</code> if
   *     the specified name matches non of the ProxSensorTypes names.
   */
  public static ProxSensorType fromName(String _name) {
    if (_name == null) {
      throw new NullPointerException("null name");
    }
    
    for (ProxSensorType type : ProxSensorType.values()) {
      if (type.getName().equals(_name)) {
        return type;
      }
    }
    
    return null;
  }
  
  /**
   * an utility method that retrieves the <code>ProxSensorType</code>, which id
   * matches the id specified as an input parameter.
   * 
   * @param _id 
   *     the id to match.
   * @return 
   *     the retrieved <code>ProxSensorType</code>.
   */
  public static ProxSensorType fromId(int _id) {
    for (ProxSensorType type : ProxSensorType.values()) {
      if (type.getId() == _id) {
        return type;
      }
    }
    
    return null;
  }
  
}
