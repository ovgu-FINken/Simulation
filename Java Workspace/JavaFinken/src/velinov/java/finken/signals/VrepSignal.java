package velinov.java.finken.signals;

import velinov.java.ivybus.message.FieldValue;
import velinov.java.ivybus.message.FieldValueType;


/**
 * Represents a Vrep-signal that can be manipulated by the VREP functions 
 * <code>simxSetFloatSignal</code>, <code>simxGetFloatSignal</code> etc. 
 * 
 * @author Vladimir Velinov
 * @since Jun 23, 2015
 *
 */
public class VrepSignal {
  
  private String     name;
  private FieldValue minValue;
  private FieldValue maxValue;
  private FieldValue defaultValue;

  /**
   * default constructor, that initializes with the name and 
   * the data-type of the signal.
   * 
   * @param _name
   *          the name identifying the signal.
   * @param _type
   *          the data type of the signal.
   */
  @SuppressWarnings("nls")
  public VrepSignal(String _name, String _type) {
    if (_name == null || _name.isEmpty()) {
      throw new IllegalArgumentException("illegal name");
    }
    if (_type == null || _type.isEmpty()) {
      throw new IllegalArgumentException("illegal type");
    }
    
    this.name         = _name;
    this.minValue     = FieldValueType.getValueType(_type);
    this.maxValue     = FieldValueType.getValueType(_type);
    this.defaultValue = FieldValueType.getValueType(_type);
  }
  
  /**
   * @return the name
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @return the default minimum value as specified in the xml file.
   */
  public String getMinValue() {
    return this.minValue.getValue();
  }
  
  /**
   * @return the default maximum value as specified in the xml file.
   */
  public String getMaxValue() {
    return this.maxValue.getValue();
  }
  
  /**
   * @return the default value of the signal as specified in the xml file.
   */
  public String getDefaultValue() {
    return this.defaultValue.getValue();
  }
  
  /**
   * @param _name the name to set
   */
  public void setName(String _name) {
    this.name = _name;
  }
  
  /**
   * @param _minValue the default minimum value.
   */
  @SuppressWarnings("nls")
  public void setMinValue(String _minValue) {
    if (_minValue == null || _minValue.isEmpty()) {
      throw new IllegalArgumentException("illegal min value");
    }
    this.minValue.setValue(_minValue);
  }
  
  /**
   * @param _maxValue the default maximum value.
   */
  @SuppressWarnings("nls")
  public void setMaxValue(String _maxValue) {
    if (_maxValue == null || _maxValue.isEmpty()) {
      throw new IllegalArgumentException("illegal max value");
    }
    this.maxValue.setValue(_maxValue);
  }
  
  /**
   * @param _defaultValue the default value of the signal.
   */
  @SuppressWarnings("nls")
  public void setDefaultValue(String _defaultValue) {
    if (_defaultValue == null || _defaultValue.isEmpty()) {
      throw new IllegalArgumentException("illegal default value");
    }
    this.defaultValue.setValue(_defaultValue);
  }
  

}
