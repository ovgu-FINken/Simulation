package velinov.java.ivybus.message;

import java.util.ArrayList;
import java.util.List;


/**
 * Represents a message class from the messages.xml file.
 * 
 * @author Vladimir Velinov
 * @since 12.05.2015
 */
public class MessageClass {
  
  /**
   * 
   */
  @SuppressWarnings("nls")
  public static final String TAG = "class";
  
  private String        name;
  private List<Message> messages;
  
  /**
   * default constructor.
   */
  public MessageClass() {
    this.messages = new ArrayList<Message>();
  }
  
  /**
   * set the name of the message class.
   * @param _name
   */
  public void setName(String _name) {
    this.name = _name;
  }
  
  /**
   * @return the name of the message class.
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @return the messages for this class.
   */
  public List<Message> getMessages() {
    return this.messages;
  }
  
  /**
   * @return the number of messages.
   */
  public int getMessageCount() {
    return this.messages.size();
  }
  
  /**
   * add message to the message class.
   * @param _msg
   */
  @SuppressWarnings("nls")
  public void addMessage(Message _msg) {
    if (_msg == null) {
      throw new NullPointerException("null message");
    }
    
    this.messages.add(_msg);
  }

}
