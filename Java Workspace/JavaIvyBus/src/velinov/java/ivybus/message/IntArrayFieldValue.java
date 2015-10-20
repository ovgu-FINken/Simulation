package velinov.java.ivybus.message;

import java.util.Arrays;


/**
 * An integer array implementation of {@link FieldValue}.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public class IntArrayFieldValue implements FieldValue {

  private int[] value;
  
  @Override
  public String getValue() {
    return Arrays.toString(this.value);
  }

  @Override
  public void setValue(String _value) {
    // TODO Auto-generated method stub
    
  }
  
  

}
