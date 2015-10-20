package velinov.java.vrep.data;

import velinov.java.vrep.objects.VrepObject;


/**
 * Represents the anhular velocity of an {@link VrepObject} as 
 * Euler angles per seconds.
 * 
 * @author Vladimir Velinov
 * @since 18.05.2015
 */
public class AngularVelocity {
  
  private float dAlpha;
  private float dBetha;
  private float dGamma;
  
  /**
   * default constructor.
   * 
   * @param _dAlpha
   * @param _dBeta
   * @param _dGamma
   */
  public AngularVelocity(float _dAlpha, float _dBeta, float _dGamma) {
    this.dAlpha = _dAlpha;
    this.dBetha = _dBeta;
    this.dGamma = _dGamma;
  }
  
  /**
   * @return the dAlpha
   */
  public float getdAlpha() {
    return this.dAlpha;
  }
  
  /**
   * @param _dAlpha the dAlpha to set
   */
  public void setdAlpha(float _dAlpha) {
    this.dAlpha = _dAlpha;
  }
  
  /**
   * @return the dBetha
   */
  public float getdBetha() {
    return this.dBetha;
  }
  
  /**
   * @param _dBetha the dBetha to set
   */
  public void setdBetha(float _dBetha) {
    this.dBetha = _dBetha;
  }
  
  /**
   * @return the dGamma
   */
  public float getdGamma() {
    return this.dGamma;
  }
  
  /**
   * @param _dGamma the dGamma to set
   */
  public void setdGamma(float _dGamma) {
    this.dGamma = _dGamma;
  }
  
}
