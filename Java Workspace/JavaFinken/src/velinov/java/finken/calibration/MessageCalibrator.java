package velinov.java.finken.calibration;

import velinov.java.bean.EventDispatchable;
import velinov.java.ivybus.message.Message;


/**
 * Defines a calibrator, that takes a bunch of <code>Message</code>s and filters
 * the values of its <code>MessageField</code>s.
 * 
 * @author Vladimir Velinov
 * @since Jun 9, 2015
 */
public interface MessageCalibrator extends EventDispatchable {
  
  /**
   * a property, that is fired when the calibration has finished.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_CALIBRATION_FINISHED = "calibDone";
//  
  /**
   * add a <code>Message</code> to the calibration list.
   * @param _message
   */
  public void addMessage(Message _message);
  
  /**
   * @return <code>true</code> if the calibration has finished.
   */
  public boolean finished();
  
  /**
   * Returns the calibrated value of the specified, by its name, 
   * <code>MessageField</code>. Throws an <code>IllegalStateException</code>
   * if the calibrator has not finished.
   * 
   * @param _fieldName - the name of the <code>MessageField</code>.
   * @return the calibrated value.
   */
  public Float getCalibratedValue(String _fieldName);

}
