package velinov.java.ivybus.message;

import java.util.List;


/**
 * Represents a message that is sent over the IVYBus. A Message is a chunk of
 * data containing {@link MessageField}s.
 * 
 * @author Vladimir Velinov
 * @since 18.04.2015
 *
 */
public interface Message {
  
  /**
   * the tag identifying the message in the xml documetns.
   */
  @SuppressWarnings("nls")
  public static final String TAG = "message";
  
  /**
   * @return the name of the {@code Message}.
   */
  public String getName();
  
  /**
   * set the name of the message.
   * @param _name 
   */
  public void setName(String _name);
  
  /**
   * @return the id of the {@code Message}.
   */
  public int getId();
  
  /**
   * set the id.
   * @param _id 
   */
  public void setId(int _id);
  
  /**
   * @param _period
   */
  public void setPeriod(double _period);
  
  /**
   * @return the period in seconds in which the message is published.
   */
  public double getPeriod();
  
  /**
   * @return return the regular expression used to subscribe to this message.
   */
  public String getRegExp();
  
  /**
   * @param _fieldName 
   * @return the {@link MessageField} corresponding to the specified field name.
   */
  public MessageField getMessageField(String _fieldName);
  
  /**
   * adds a {@link MessageField} to the {@code Message}.
   * @param _field
   */
  public void addMessageField(MessageField _field);
  
  /**
   * update the values of the {@link MessageField}s with the {@code String}
   * value returned by {@code IvyMessageListener#receive} method.
   * @param _str
   */
  public void updateFieldValues(String _str);
  
  /**
   * @return a {@code List} of all {@link MessageField}s.
   */
  public List<MessageField> getMessageFields();

}
