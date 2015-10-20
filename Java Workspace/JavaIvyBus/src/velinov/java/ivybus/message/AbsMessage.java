package velinov.java.ivybus.message;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


/**
 * Represents a telemetry {@link Message}.
 * 
 * @author Vladimir Velinov
 * @since 12.05.2015
 */
public class AbsMessage implements Message {
  
  private String                    name;
  private int                       id;
  private double                    period;
  private List<MessageField>        fields;
  private Map<String, MessageField> fieldsMap;
  
  /**
   * default constructor.
   * @param _name 
   */
  public AbsMessage(String _name) {
    this.fields    = new LinkedList<MessageField>();
    this.fieldsMap = new HashMap<String, MessageField>();
    this.setName(_name);
  }

  @Override
  public String getName() {
    return this.name;
  }
  
  @SuppressWarnings("nls")
  @Override
  public void setName(String _name) {
    if (_name == null) {
      throw new NullPointerException("null message name");
    }
    this.name = _name;
  }

  @Override
  public int getId() {
    return this.id;
  }
  
  @Override
  public void setId(int _id) {
    this.id = _id;
  }
  
  @Override
  public void setPeriod(double _period) {
    this.period = _period;
  }

  @Override
  public double getPeriod() {
    return this.period;
  }
  
  @Override
  @SuppressWarnings("nls")
  public String getRegExp() {
    return this.getName()+ " (.*)";
  }

  @SuppressWarnings("nls")
  @Override
  public void addMessageField(MessageField _field) {
    if (_field == null) {
      throw new NullPointerException("Null messagefield");
    }
    
    this.fields.add(_field);
    this.fieldsMap.put(_field.getName(), _field);
  }
  
  @SuppressWarnings("nls")
  @Override
  public void updateFieldValues(String _valuesStr) {
    String       valueStr;
    List<String> items;

    if (_valuesStr == null) {
      throw new NullPointerException("null values");
    }
    
    valueStr = _valuesStr.trim();
    items    = Arrays.asList(valueStr.split("\\s"));
    
    
    int i = 0;
    for (String value : items) {
      MessageField field;
      
      field = this.fields.get(i);
      
      if (value == null || value.isEmpty()) {
        continue;
      } 
      
      field.setValue(value);
      i++;
    }
    
  }

  @Override
  public List<MessageField> getMessageFields() {
    return this.fields;
  }
  
  @Override
  public boolean equals(Object _other) {
    if (!(_other instanceof Message)) {
      return false;
    }
    return this.name.equals(((Message) _other).getName()) ? true : false;
  }

  @SuppressWarnings("nls")
  @Override
  public MessageField getMessageField(String _fieldName) {
    if (_fieldName == null) {
      throw new NullPointerException("null field name");
    }
    return this.fieldsMap.get(_fieldName);
  }
  
}
