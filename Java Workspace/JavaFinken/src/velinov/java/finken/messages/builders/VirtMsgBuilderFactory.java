package velinov.java.finken.messages.builders;

import velinov.java.ivybus.message.Message;


/**
 * A factory that retrieves the correct {@link VirtualMessageBuilder} 
 * for a given {@link Message} name.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public class VirtMsgBuilderFactory {
  
  /**
   * @param _msgName
   * @return the {@link VirtualMessageBuilder}.
   */
  @SuppressWarnings("nls")
  public static VirtualMessageBuilder getMessageBuilder(String _msgName) {
    if (_msgName == null) {
      throw new NullPointerException("Null message name");
    }
    
    switch(_msgName) {
    case ("FINKEN_SENSOR_MODEL"):
      return new FinkenSensorModelBuilder();
    default:
      return null;
      //throw new IllegalArgumentException("Illegal message name");
    }
    
  }

}
