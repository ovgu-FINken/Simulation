package velinov.java.jfreechart.realtime;


/**
 * Represents a real-time variable which is plotted on a {@link RealTimePlot}.
 * 
 * @author Vladimir Velinov
 * @since 13.04.2015
 */
public class RealTimeVariable {
  
  private String id;
  private String label;
  
  /**
   * initialize just with id.
   * @param _id
   */
  @SuppressWarnings("nls")
  public RealTimeVariable(String _id) {
    if (_id == null || _id.isEmpty()) {
      throw new IllegalArgumentException("Illegal id");
    }
    
    this.id = _id;
  }
  
  /**
   * default constructor.
   * @param _id identifier of the variable
   * @param _label label which is used for displaying.
   */
  @SuppressWarnings("nls")
  public RealTimeVariable(String _id, String _label) {
    if (_id == null || _id.isEmpty()) {
      throw new IllegalArgumentException("Illegal id");
    }
    
    if (_label == null || _label.isEmpty()) {
      throw new IllegalArgumentException("Illegal label");
    }
    
    this.id    = _id;
    this.label = _label;
  }
  
  /**
   * @return the identifier of the variable.
   */
  public String getId() {
    return this.id;
  }
  
  /**
   * @return the label of the variable.
   */
  public String getLabel() {
    return this.label;
  }
  
  @Override
  public boolean equals(Object _other) {
    RealTimeVariable other;
    
    if (_other == null || !(_other instanceof RealTimeVariable)) {
      return false;
    }
    
    other = (RealTimeVariable) _other;
    
    if (!this.id.equals(other.getId())) {
      return false;
    }
    
    return true;
  }

}
