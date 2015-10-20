package velinov.java.vrep.objects;

import velinov.java.vrep.VrepConnection;


/**
 * An Enum describing the different types of <code>VrepObject</code>s.
 * 
 * @author Vladimir Velinov
 * @since Jul 7, 2015
 *
 */
public enum VrepObjectType {
  
  /**
   * represents a <code>Shape</code> object type.
   */
  SHAPE(VrepConnection.sim_object_shape_type),
  
  /**
   * represents a joint sciene object type.
   */
  JOINT(VrepConnection.sim_object_joint_type),
  
  /**
   * represents a camera sciene object type.
   */
  CAMERA(VrepConnection.sim_object_camera_type),
  
  /**
   * represents a vision sensor sciene object type.
   */
  VISION_SENSOR(VrepConnection.sim_object_visionsensor_type),
  
  /**
   * represents a force-sensor sciene object type.
   */
  FORCE_SENSOR(VrepConnection.sim_object_forcesensor_type),
  
  /**
   * represents a proximity scene object type.
   */
  PROXIMITY_SENSOR(VrepConnection.sim_object_proximitysensor_type),
  
  /**
   * represents a compound object type that can consist of others object types.
   */
  COMPOUND(15);
  
  /**
   * TODO complete the other types...
   */
  
  private int type;
  
  private VrepObjectType(int _type) {
    this.type = _type;
  }
  
  /**
   * @return the integer value representing this <code>ObjectType</code>.
   */
  public int getType() {
    return this.type;
  }
  
  /**
   * an utility method that returns the <code>ObjectType</code> coresponding
   * to the specified integer value.
   * 
   * @param _type 
   *     an integer representing a <code>ObjectType</code>.
   * @return 
   *     the corresponding <code>ObjectType</code> or <code>null</code> if the
   *     specified integer value does not represent a valid ObjectType.
   */
  public static VrepObjectType fromInt(int _type) {
    for (VrepObjectType type : VrepObjectType.values()) {
      if (type.getType() == _type) {
        return type;
      }
    }
    
    return null;
  }

}
