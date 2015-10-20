package velinov.java.finken.drone;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import velinov.java.finken.aircraft.Aircraft;
import velinov.java.finken.drone.sensoric.FinkenProxSensor;
import velinov.java.finken.drone.sensoric.ProxSensorType;
import velinov.java.vrep.objects.AbsVrepObject;
import velinov.java.vrep.objects.Shape;
import velinov.java.vrep.objects.VrepObjectType;

/**
 * abstract implementation of {@link FinkenDrone}.
 * 
 * @author Vladimir Velinov
 * @since 27.04.2015
 */
public abstract class AbsFinkenDrone extends AbsVrepObject 
    implements FinkenDrone 
{  
  protected int                                  id;
  protected final Shape                          shape;
  protected final Aircraft                       aircraft;
  protected final List<FinkenProxSensor>         proxSensors;
  protected final Map<Integer, FinkenProxSensor> proxSensMap;
  
  protected AbsFinkenDrone(Shape _shape, Aircraft _aircraft) {
    super(VrepObjectType.COMPOUND, _shape.getObjectName().getFullName(),
        _shape.getIntObjectHandle(), _shape.getCLient());
    
    this.shape       = _shape;
    this.aircraft    = _aircraft;
    
    this.proxSensors = new ArrayList<FinkenProxSensor>(
        ProxSensorType.sensorCount());
    
    this.proxSensMap = new HashMap<Integer, FinkenProxSensor>(
        ProxSensorType.sensorCount());
    
    this._initSensors();
    this.setSceneIndex(this.shape.getSceneIndex());
  }
  
  protected AbsFinkenDrone(Shape _shape, Aircraft _aircraft, int _id) {
    this(_shape, _aircraft);
    
    this.id = _id;
  }
  
  @Override
  public Shape getShape() {
    return this.shape;
  }

  @Override
  public List<FinkenProxSensor> getProximitySensors() {
    return this.proxSensors;
  }
  
  /**
   * initializes the <code>FinkenProxSensor</code>s.
   */
  private void _initSensors() {
    if (this.proxSensors.size() != 0) {
      return;
    }
    
    for (ProxSensorType sensor : ProxSensorType.values()) {
      FinkenProxSensor proxSensor;
      
      if (this.getObjectName().isIndexed()) {
        // need to append the name index to the sensor base name
        proxSensor = new FinkenProxSensor(sensor, 
            this.getObjectName().getNameSuffix(), this.client);
      }
      else {
        proxSensor = new FinkenProxSensor(sensor, this.client);
      }
      
      this.proxSensors.add(proxSensor);
      this.proxSensMap.put(proxSensor.getType().getId(), proxSensor);
    }
  }
  
  @SuppressWarnings("nls")
  @Override
  public FinkenProxSensor getProxSensor(ProxSensorType _type) {
    if (_type == null) {
      throw new NullPointerException("null type");
    }
    
    return this.proxSensMap.get(_type.getId());
  }
  
  @Override
  public float getProxSensorValue(ProxSensorType _type) {
    if (_type == null) {
      throw new NullPointerException("null type"); //$NON-NLS-1$
    }
    
    return this.proxSensMap.get(_type.getId()).getDistance();
  }
  
  @SuppressWarnings("nls")
  @Override
  public void setProxSensorValue(ProxSensorType _type, float _value) {
    if (_type == null) {
      throw new NullPointerException("null type");
    }
    
    this.proxSensMap.get(_type.getId()).setDistance(_value);
  }
  
}
