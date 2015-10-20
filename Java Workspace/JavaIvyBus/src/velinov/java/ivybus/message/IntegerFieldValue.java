package velinov.java.ivybus.message;


/**
 * Integer implementation of {@link FieldValue}.
 * 
 * @author Vladimir Velinov
 * @since May 23, 2015
 */
public class IntegerFieldValue implements FieldValue {
  
  private int value;
  
  /**
   * set the value
   * @param _value
   */
  public void setValueInt(int _value) {
    this.value = _value;
  }
  
  /**
   * @return the value as integer.
   */
  public int getValueInt() {
    return this.value;
  }

  @Override
  public String getValue() {
    return String.valueOf(this.value);
  }

  @SuppressWarnings("nls")
  @Override
  public void setValue(String _value) {
    try {
      this.value = Integer.valueOf(_value);
    }
    catch (NumberFormatException _e) {
      System.out.println("error expected number, but got" + " " + _value);
      return;
    }
    
  }

}
