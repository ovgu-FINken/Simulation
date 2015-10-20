package velinov.java.ivybus.message;


/**
 * Float implementation of {@link FieldValue}.
 * 
 * @author Vladimir Velinov
 * @since May 23, 2015
 */
public class FloatFieldValue implements FieldValue {
  
  private float  value;
  private String format;

  @Override
  public String getValue() {
    return (this.format != null) ? String.format(this.format, this.value) : 
      String.valueOf(this.value);
  }

  @Override
  public void setValue(String _value) {
    this.value = Float.valueOf(_value);
  }
  
  /**
   * set the format of the float value.
   * @param _format
   */
  public void setFormat(String _format) {
    this.format = _format;
  }

}
