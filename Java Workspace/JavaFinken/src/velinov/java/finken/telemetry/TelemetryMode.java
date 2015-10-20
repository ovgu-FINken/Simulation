package velinov.java.finken.telemetry;

import java.util.ArrayList;
import java.util.List;

import velinov.java.ivybus.message.Message;


/**
 * Represents a {@link Telemetry} mode as described in the "telemetry.dtd".
 * 
 * @author Vladimir Velinov
 * @since 16.05.2015
 */
public class TelemetryMode {
  
  /**
   * identifying tag in xml documets.
   */
  @SuppressWarnings("nls")
  public final static String TAG = "mode";
  
  private String        name;
  private String        keyPress;
  private List<Message> messages;
  
  /**
   * default constructor.
   */
  public TelemetryMode() {
    this.messages = new ArrayList<Message>();
  }
  
  /**
   * set name
   * @param _name
   */
  @SuppressWarnings("nls")
  public void setName(String _name) {
    if (_name == null) {
      throw new NullPointerException("mode name is null");
    }
    this.name = _name;
  }
  
  /**
   * @return the name of the telemetry mode.
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * set the key press.
   * @param _key
   */
  public void setKeyPress(String _key) {
    this.keyPress = _key;
  }
  
  /**
   * @return the key press.
   */
  public String getKeyPress() {
    return this.keyPress;
  }
  
  /**
   * add a {@link Message}.
   * @param _message
   */
  public void addMessage(Message _message) {
    this.messages.add(_message);
  }
  
  /**
   * @return the list of {@link Message}s that
   * this {@code TelemetryMode} contains.
   */
  public List<Message> getMessages() {
    return this.messages;
  }
  
  @Override
  public boolean equals(Object _object) {
    if (_object == null || !(_object instanceof TelemetryMode)) {
      return false;
    }
    
    return this.name.equals(((TelemetryMode) _object).getName()) ? true : false;
  }
}
