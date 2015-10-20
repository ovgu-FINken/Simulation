package velinov.java.vrep.objects;

import velinov.java.bean.EventDispatchable;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.data.AngularVelocity;
import velinov.java.vrep.data.LinearVelocity;
import velinov.java.vrep.data.Orientation;
import velinov.java.vrep.data.Position;
import velinov.java.vrep.scene.VrepScene;
import coppelia.IntW;


/**
 * an interface describing a V-REP scene object.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public interface VrepObject extends EventDispatchable {
  
  /**
   * @return the <code>ObjectType</code> of the <code>VrepObject</code>.
   */
  public VrepObjectType getObjectType();
  
  /**
   * @return the <code>VrepObjectName</code>.
   */
  public VrepObjectName getObjectName();

  /**
   * set the index of this {@code VrepObject} in the {@link VrepScene}.
   * the index is a constant and does not change as long as the scene 
   * does not change.
   * 
   * @param _index
   *          the index used to retrieve the object from the scene.
   */
  public void setSceneIndex(int _index);
  
  /**
   * @return the index of this {@code VrepObject} in the {@link VrepScene}.
   */
  public int getSceneIndex();
  
  /**
   * @return the object handle.
   */
  public IntW getObjectHandle();
  
  /**
   * @return the object handle as an {@code int} value.
   */
  public int getIntObjectHandle();
  
  /**
   * @return the {@link VrepClient}.
   */
  public VrepClient getCLient();
  
  /**
   * @return the 3D position of the object in V-REP coordinate system.
   */
  public Position getPosition();
  
  /**
   * @return the euler angles 
   */
  public Orientation getOrientation();
  
  /**
   * set the Euler angles.
   * @param _engle
   */
  public void setOrientation(Orientation _engle);
  
  /**
   * Set the 3D position of the object
   * @param _position
   */
  public void setPosition(Position _position);
  
  /**
   * Set the linear velocity of the object.
   * @param _linV 
   */
  public void setLinearVelocity(LinearVelocity _linV);
  
  /**
   * Set the angular velocity of the object.
   * @param _angV
   */
  public void setAngularVelocity(AngularVelocity _angV);
  
  /**
   * @return the {@link AngularVelocity} of the {@link VrepObject}.
   */
  public AngularVelocity getAngularVelocity();
  
  /**
   * @return the {@link LinearVelocity} of the {@link LinearVelocity}.
   */
  public LinearVelocity getLinearVelocity();

}
