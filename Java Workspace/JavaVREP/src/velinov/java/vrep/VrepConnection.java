package velinov.java.vrep;

import coppelia.remoteApi;


/**
 * 
 * Extension of {@link remoteApi}.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
public class VrepConnection extends remoteApi {
  
  /**
   * a key to derive the names of objects in the scene.
   */
  public static final int GET_OBJECT_NAMES                      = 0;
  
  /**
   * a key to derive the absolute position of objects.
   */
  public static final int GET_ABSOLUTE_POSITION                 = 3;
  
  /**
   * a key to derive the absolute object orientation as Euler angle
   */
  public static final int GET_ABSOLUTE_ORIENTATION              = 5;
  
  /**
   * a key to derive the local object orientation as Euler angles.
   */
  public static final int GET_LOCAL_ORIENTATION                 = 6;
  
  /**
   * retrieves the absolute object positions and orientations (as Euler angles)
   * (in floatData. There are 6 values for each object (x,y,z,alpha,beta,gamma)
   */
  public static final int GET_ABSOLUTE_POSITION_AND_ORIENTATION = 9;
  
  /**
   * retrieves the local object positions and orientations (as Euler angles) 
   * (in floatData. There are 6 values for each object (x,y,z,alpha,beta,gamma)
   */
  public static final int GET_LOCAL_POSITION_AND_ORIENTATION    = 10;
  
  /**
   * retrieves the object linear velocity (in floatData. There are 3 values 
   * for each object (vx,vy,vz))
   */
  public static final int GET_LINEAR_VELOCITY                   = 17;
  
  /**
   * retrieves the object angular velocity as Euler angles per seconds 
   * (in floatData. There are 3 values for each object (dAlpha,dBeta,dGamma))
   */
  public static final int GET_ANGULAR_VELOCITY                  = 18;
  
  /**
   * retrieves the object linear and angular velocity (in floatData. 
   * There are 6 values for each object (vx,vy,vz,dAlpha,dBeta,dGamma))
   */
  public static final int GET_LINEAR_AND_ANGULAR_VELOCITY       = 19;
  
  /**
   * default constructor.
   */
  public VrepConnection() {
    super();
  }

}
