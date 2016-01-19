package velinov.java.finken.calibration;

import java.util.ArrayList;
import java.util.List;

/**
 * Calibration of <code>Rotorcraft_FP</code> <code> Message</>.
 * 
 * @author Vladimir Velinov
 * @since Jun 10, 2015
 *
 */
public class RotorFPCalibrator extends AbsMessageCalibrator {

  /**
   * default constructor.
   * @param _msgNumber
   */
  public RotorFPCalibrator(int _msgNumber) {
    super(_msgNumber);
    
  }

  @SuppressWarnings("nls")
  @Override
  protected List<String> getCalibrationFields() {
    List<String> fields;
    
    fields = new ArrayList<String>();
    
    fields.add("imu_phi");
    fields.add("imu_theta");
    fields.add("imu_psi");
    
    return fields;
  }

}
