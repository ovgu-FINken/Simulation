package velinov.java.ivybus.message;



/**
 * Represents a field in a {@link Message}.
 * 
 * @author Vladimir Velinov 
 * @since 18.04.2015
 *
 */
public class MessageField {
  
  /**
   * 
   */
  @SuppressWarnings("nls")
  public static final String TAG = "field";
  
  private String     name;
  private String     type;
  private String     unit;
  private String     format;
  private float      coeff;
  private FieldValue value;
  
  /**
   * @return the unit
   */
  public String getUnit() {
    return this.unit;
  }

  /**
   * @return the format
   */
  public String getFormat() {
    return this.format;
  }
  
  /**
   * @param _name
   * @param _type 
   */
  @SuppressWarnings("nls")
  public MessageField(String _name, String _type) {
    if (_type == null || _type == null) {
      throw new NullPointerException("null name or type");
    }
    this.value = FieldValueType.getValueType(_type);
    this.setName(_name);
  }
  
  /**
   * @return the name of the field.
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @return the type of the message field.
   */
  public String getType() {
    return this.type;
  }
  
  /**
   * @return the value of the message field.
   */
  public String getValue() {
    return this.value.getValue();
  }
  
  /**
   * @return the <code>alt_unit_coef</code> or <code> null </code>.
   */
  public float getCoeffitient() {
    return this.coeff;
  }
  
  /**
   * set name of the field.
   * @param _name
   */
  @SuppressWarnings("nls")
  public void setName(String _name) {
    if (_name == null || _name.isEmpty()) {
      throw new IllegalArgumentException("Ilelgal name");
    }  
    this.name = _name;
  }
  
  /**
   * set the type of the message field.
   * @param _type
   */
  public void setType(String _type) {
    this.type  = _type;
    this.value = FieldValueType.getValueType(_type);
  }
  
  /**
   * set the unit of the message field.
   * @param _unit
   */
  public void setUnit(String _unit) {
    this.unit = _unit;
  }
  
  /**
   * Set the format of the field e.g "%.2f".
   * @param _format
   */
  public void setFormat(String _format) {
    if (this.value instanceof FloatFieldValue) {
      ((FloatFieldValue) this.value).setFormat(_format);
    }
    this.format = _format;
  }
  
  /**
   * set the <code>alt_unit_coef</code>. 
   * 
   * @param _coeff
   */
  public void setCoeff(String _coeff) {
    if (_coeff != null) {
      this.coeff = Float.valueOf(_coeff);
    }
  }
  
  /**
   * Set the value of the message field.
   * @param _value
   */
  public void setValue(String _value) {
    this.value.setValue(_value);
  }
  
  @Override
  public boolean equals(Object _other) {
    if (_other == null || !(_other instanceof MessageField)) {
      return false;
    }
    
    return this.name.equals(((Message) _other).getName()) ? true : false;
  }

}
