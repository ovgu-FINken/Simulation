package velinov.java.ivybus.message;


/**
 * A String implementation of {@link FieldValue}.
 * 
 * @author Vladimir Velinov
 * @since May 23, 2015
 */
public class StringFieldValue implements FieldValue {
  
  private String value;

  @Override
  public String getValue() {
    return this.value;
  }

  @Override
  public void setValue(String _value) {
    this.value = _value;
  }

}
