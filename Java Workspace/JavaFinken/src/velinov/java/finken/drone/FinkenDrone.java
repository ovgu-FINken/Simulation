package velinov.java.finken.drone;

import java.util.List;

import velinov.java.finken.drone.sensoric.FinkenProxSensor;
import velinov.java.finken.drone.sensoric.ProxSensorType;
import velinov.java.vrep.objects.Shape;
import velinov.java.vrep.objects.VrepObject;

/**
 * Represents a FINKEN Quadrocopter.
 * 
 * @author Vladimir Velinov
 * @since 27.04.2015
 *
 */
public interface FinkenDrone extends VrepObject {
  
  /**
   * join the {@code FinkenDrone} to the Ivy-bus.
   */
  public void joinIvyBus();
  
  /**
   * @return {@code true} if the {@code FinkenDrone} had joined the bus.
   */
  public boolean isConnectedToBus();
  
  /**
   * leave the Ivy-bus.
   */
  public void leaveIvyBus();
  
  /**
   * @return the <code>Shape</code> of the <code>FinkenDrone</code>.
   */
  public Shape getShape();
  
  /**
   * @return a <code>List</code>, containing the four 
   * <code>FinkenProxSensor</code>s.
   */
  public List<FinkenProxSensor> getProximitySensors();
  
  /**
   * @param _type 
   *     the <code>ProxSensorType</code>.
   * @return 
   *     the <code>ProxSensorType</code>.
   */
  public FinkenProxSensor getProxSensor(ProxSensorType _type);
  
  /**
   * 
   * @param _type
   *     the <code>ProxSensorType</code> which value will be retrieved.
   * @return 
   *     the value of the proximity sensor - distance in centimeter.
   */
  public float getProxSensorValue(ProxSensorType _type);
  
  /**
   * set a new value for the distance measured by the specified proximity sensor.
   * 
   * @param _type
   *     the <code>ProxSensorType</code> of the sensor, for which to set 
   *     the new value.
   * @param _value
   *     the new distance value.
   */
  public void setProxSensorValue(ProxSensorType _type, float _value);

}
