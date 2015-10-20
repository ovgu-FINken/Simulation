package velinov.java.finken.aircraft;


/**
 * Represents an aircraft as defined in {@code paparazzi/conf/conf.xml} file.
 * 
 * @author Vladimir Velinov
 * @since 19.05.2015
 */
public class Aircraft {
  
  /**
   * the tag identifying the aircraft element in the 
   * {@code paparazzi/conf/conf.xml} file.
   */
  @SuppressWarnings("nls")
  public static final String TAG = "aircraft";
  
  private String  name;
  private int     ac_id;
  private String  gui_color;
  private boolean isVirtual;
  
  /**
   * @return {@code true} if the aircraft is virtual.
   */
  public boolean isVirtual() {
    return this.isVirtual;
  }
  
  /**
   * set {@code true} if the aircraft is virtual.
   * @param _virtual
   */
  public void setIsVirtual(boolean _virtual) {
    this.isVirtual = _virtual;
  }
  
  /**
   * @return the gui_color
   */
  public String getGuiColor() {
    return this.gui_color;
  }

  /**
   * @param _gui_color the gui_color to set
   */
  public void setGuiColor(String _gui_color) {
    this.gui_color = _gui_color;
  }

  /**
   * @return the name
   */
  public String getName() {
    return this.name;
  }
  
  /**
   * @param _name the name to set
   */
  public void setName(String _name) {
    this.name = _name;
  }
  
  /**
   * @return the id
   */
  public int getId() {
    return this.ac_id;
  }
  
  /**
   * @return the aircraft id as a String.
   */
  public String getStrId() {
    return String.valueOf(this.ac_id);
  }
  
  /**
   * @param _id the id to set
   */
  public void setId(int _id) {
    this.ac_id = _id;
  }

}
