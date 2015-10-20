package velinov.java.ivybus.message;



/**
 * factory class to determine the correct data type of a {@link MessageField}.
 * 
 * @author Vladimir Velinov
 * @since May 23, 2015
 */
public class FieldValueType {
  
  /**
   * @param _type 
   *     the type as a String
   * @return 
   *     the correct {@link FieldValue}.
   */
  @SuppressWarnings("nls")
  public static FieldValue getValueType(String _type) {
    switch (_type) {
    case ("int8"): 
      return new IntegerFieldValue();
    case ("uint8"): 
      return new IntegerFieldValue();
    case ("int16"): 
      return new IntegerFieldValue();
    case ("uint16"):
      return new IntegerFieldValue();
    case ("int32"): 
      return new IntegerFieldValue();
    case ("uint32"): 
      return new IntegerFieldValue();
    case ("double"):
      return new DoubleFieldValue();
    case ("float"): 
      return new FloatFieldValue();
    case("string"):
      return new StringFieldValue();
    default:
      return new IntegerFieldValue();
      }
    
  }

}
