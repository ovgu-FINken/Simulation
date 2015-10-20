package velinov.java.vrep.data;

import velinov.java.vrep.objects.VrepObject;


/**
 * Represents the linear velocity of an {@link VrepObject}.
 * 
 * @author Vladimir Velinov
 * @since 18.05.2015
 */
public class LinearVelocity {
  
  float vx;
  float vy;
  float vz;
  
  /**
   * default constructor.
   * @param _vx
   * @param _vy
   * @param _vz
   */
  public LinearVelocity(float _vx, float _vy, float _vz) {
    this.vx = _vx;
    this.vy = _vy;
    this.vz = _vz;
  }
  
  /**
   * @return the x-component of the linear velocity.
   */
  public float getVx() {
    return this.vx;
  }
  
  /**
   * @param _vx
   */
  public void setVx(float _vx) {
    this.vx = _vx;
  }
  
  /**
   * @return the y-component of the linear velocity.
   */
  public float getVy() {
    return this.vy;
  }
  
  /**
   * @param _vy
   */
  public void setVy(float _vy) {
    this.vy = _vy;
  }
  
  /**
   * @return the z-component of the linear velocity.
   */
  public float getVz() {
    return this.vz;
  }
  
  /**
   * @param _vz
   */
  public void setVz(float _vz) {
    this.vz = _vz;
  }
  
}
