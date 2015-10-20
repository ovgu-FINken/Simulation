package velinov.java.finken.telemetry;

import java.util.ArrayList;
import java.util.List;


/**
 * Represents a {@link Telemetry} process as described in the "telemetry.dtd".
 * 
 * @author Vladimir Velinov
 * @since 16.05.2015
 */
public class TelemetryProcess {
  
  /**
   * the tag that identifies the process in the xml file.
   */
  @SuppressWarnings("nls")
  public static final String TAG = "process";
  
  private String              name;
  private List<TelemetryMode> modes;
  
  /**
   * default constructor.
   */
  public TelemetryProcess() {
    this.modes = new ArrayList<TelemetryMode>();
  }
  
  /**
   * @param _name
   */
  public void setName(String _name) {
    this.name = _name;
  }
  
  /**
   * @return the name of the process.
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @param _mode
   */
  @SuppressWarnings("nls")
  public void addMode(TelemetryMode _mode) {
    if (_mode == null) {
      throw new NullPointerException("null telemetry mode");
    }
    this.modes.add(_mode);
  }
  
  /**
   * @return a list of {@link TelemetryMode}s contained in the telemetry process.
   */
  public List<TelemetryMode> getModes() {
    return this.modes;
  }
  
  @Override
  public boolean equals(Object _object) {
    if (_object == null || !(_object instanceof TelemetryProcess)) {
      return false;
    }
    return this.name.equals(((TelemetryProcess) _object).getName()) ? true : false;
  }

}
