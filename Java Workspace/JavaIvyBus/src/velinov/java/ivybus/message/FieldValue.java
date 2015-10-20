package velinov.java.ivybus.message;



/**
 * Defines the value of a {@link MessageField}.
 * 
 * @author Vladimir Velinov
 * @since May 23, 2015
 */
public interface FieldValue {
  
  /**
   * @return the value as a String.
   */
  public String getValue();
  
  /**
   * Set the value from String value.
   * @param _value
   */
  public void setValue(String _value);

}
