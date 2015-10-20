package velinov.java.ivybus.message;


/**
 * A double implementation of {@link FieldValue}.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public class DoubleFieldValue implements FieldValue {
  
  private double value;

  @Override
  public String getValue() {
    return String.valueOf(this.value);
  }

  @SuppressWarnings("nls")
  @Override
  public void setValue(String _value) {
    if (_value == null) {
      throw new NullPointerException("null double value");
    }
    this.value = Double.valueOf(_value);
  }

}
