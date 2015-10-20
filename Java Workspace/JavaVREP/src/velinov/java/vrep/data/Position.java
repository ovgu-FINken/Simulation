package velinov.java.vrep.data;

import velinov.java.vrep.objects.VrepObject;


/**
 * Represents a 3D position of an {@link VrepObject}.
 * 
 * @author Vladimir Velinov
 * @since 04.05.2015
 */
public class Position {
  
  private float x;
  private float y;
  private float z;
  
  /**
   * default constructor.
   * @param _x
   * @param _y
   * @param _z
   */
  public Position(float _x, float _y, float _z) {
    this.x = _x;
    this.y = _y;
    this.z = _z;
  }
  
  /**
   * @return the x position of the object.
   */
  public float getX() {
    return this.x;
  }
  
  /**
   * @return the y position of the object.
   */
  public float getY() {
    return this.y;
  }
  
  /**
   * @return the z position of the object.
   */
  public float getZ() {
    return this.z;
  }

}
