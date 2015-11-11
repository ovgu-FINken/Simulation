package velinov.java.finken.calibration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import velinov.java.event.AbsEventDispatchable;
import velinov.java.ivybus.message.Message;

/**
 * An abstract implementation of <code>MessageCalibrator</code>.
 * 
 * @author Vladimir Velinov
 * @since Jun 9, 2015
 */
public abstract class AbsMessageCalibrator extends AbsEventDispatchable
    implements MessageCalibrator 
{  
  private final List<Message>       messages;
  private final Map<String, Float>  fields;
  private final int                 number;
  private boolean                   finished;
  
  /**
   * default constructor that initializes with the number of maximum
   * <code>Message</code>s to be calibrated.
   * 
   * @param _msgNumber 
   */
  public AbsMessageCalibrator(int _msgNumber) {
    this.messages = new ArrayList<Message>(_msgNumber);
    this.fields   = new HashMap<String, Float>();
    this.number   = _msgNumber;
    this.finished = false;
    
    this._initFields();
  }
  
  @Override
  @SuppressWarnings("nls")
  public void addMessage(Message _message) {
    if (_message == null) {
      throw new NullPointerException("null message");
    }
    this.messages.add(_message);
    
    if (this.messages.size() >= this.number) {
      this._calibrate();
      this.finished = true;
      this.fireBooleanPropertyChanged(
          PROPERTY_CALIBRATION_FINISHED, this.finished);
      System.out.println("calibration done");
    }
  }
  
  @Override
  @SuppressWarnings("nls")
  public Float getCalibratedValue(String _fieldName) {
    if (!this.finished) {
      throw new IllegalStateException("calibration not finished yet");
    }
    
    return this.fields.get(_fieldName);
  }
  
  @Override
  public boolean finished() {
    return this.finished;
  }
  
  private void _initFields() {
   List<String> fieldNames = this.getCalibrationFields(); 
   
   for (String fieldName : fieldNames) {
     this.fields.put(fieldName, 0.0f);
   }
  }
  
  /**
   * performs a calibration by calculating the mean value of the fields.
   */
  private void _calibrate() {
    for (Message msg : this.messages) {
      for (Map.Entry<String, Float> field : this.fields.entrySet()) {
        String valueStr;
        Float  valueSum;
        valueStr = msg.getMessageField(field.getKey()).getValue();
        valueSum = Float.valueOf(valueStr) + field.getValue();
        field.setValue(valueSum);
      }
    }
    
    for (Map.Entry<String, Float> field : this.fields.entrySet()) {
      Float value = field.getValue();
      value       = value / this.messages.size();
      value       = value * 0.0139882f;
      field.setValue(value);
    }
  }
  
  protected abstract List<String> getCalibrationFields();

}
