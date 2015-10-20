package velinov.java.vrep.data;

import velinov.java.vrep.objects.VrepObject;


/**
 * Represents the orientation of an {@link VrepObject}.
 * 
 * @author Vladimir Velinov
 * @since 04.05.2015
 */
public class Orientation {
  
  private float alpha;
  private float betta;
  private float gamma;
  
  /**
   * default constructor.
   * @param _alpha
   * @param _betta
   * @param _gamma
   */
  public Orientation(float _alpha, float _betta, float _gamma) {
    this.alpha = _alpha;
    this.betta = _betta;
    this.gamma = _gamma;
  }
  
  /**
   * @return tha alpha angle.
   */
  public float getAlpha() {
    return this.alpha;
  }
  
  /**
   * @return the betta angle.
   */
  public float getBetta() {
    return this.betta;
  }
  
  /**
   * @return the gamma angle.
   */
  public float getGamma() {
    return this.gamma;
  }

}
