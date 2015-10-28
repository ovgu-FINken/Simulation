package velinov.java.vrep.objects;


/**
 * Represents a <code>VrepObject</code> name, which consists of a base name and
 * an index. If an object is copy-pasted (multiple instances of an object), then
 * each instance of the object receives the following name, according to V-REP
 * naming scheme: <code>base_name#index</code>
 * Example:
 *   Quad_Lia_ovgu_01   - original object
 *   Quad_Lia_ovgu_02#0 - first copy
 *   Quad_Lia_ovgu_03#1 - second copy
 * 
 * @author Vladimir Velinov
 * @since Jul 8, 2015
 *
 */
public class VrepObjectName {
  
  @SuppressWarnings("nls")
  /**
   * represents the name separator character. Separates the base name from the
   * name index e.g <code>Quad_Lia_ovgu_02#0</code>.
   */
  private static final String SEPARATOR = "#";
  
  private final String  fullName;
  private String        baseName;
  private String        nameSuffix;
  private String        nameIndex;
  private boolean       indexed;
  
  /**
   * default constructor, that initializes with the full name of the object,
   * as retrieved from the V-REP.
   * 
   * @param _fullName 
   *          the full (indexed) object name.
   */
  @SuppressWarnings("nls")
  public VrepObjectName(String _fullName) {
    if (_fullName == null || _fullName.isEmpty()) {
      throw new IllegalArgumentException("null or empty object name");
    }
    
    this.fullName = _fullName;
    this._parseName(this.fullName);
  }
  
  /**
   * @return <code>true</code> if the name is indexed - the object is a copy.
   */
  public boolean isIndexed() {
    return this.indexed;
  }
  
  /**
   * @return the full name of the <code>VrepObject</code>.
   */
  public String getFullName() {
    return this.fullName;
  }
  
  /**
   * @return the base name of the <code>VrepObject</code>. If the name is not
   * indexed, the full name is returned.
   */
  public String getBaseName() {
    return this.baseName;
  }
  
  /**
   * @return the suffix of the name or <code>null</code> if the 
   * name is not indexed.
   */
  public String getNameSuffix() {
    return this.nameSuffix;
  }
  
  /**
   * @return the index of the name or an empty string if not indexed.
   */
  @SuppressWarnings("nls")
  public String getNameIndex() {
    return this.isIndexed() ? this.nameIndex : "";
  }
  
  /**
   * parses the specified full object name into base name, suffix and index
   * if the name is indexed.
   * 
   * @param _name
   *          the full name to parse from.
   */
  private void _parseName(String _name) {
    final int inx;
    
    inx = _name.indexOf(SEPARATOR);
    
    if (inx <= 0) {
      this.indexed  = false;
      this.baseName = _name;
    }
    else {
      this.indexed    = true;
      this.baseName   = _name.substring(0, inx);
      this.nameSuffix = _name.substring(inx, _name.length());
      this.nameIndex  = _name.substring(inx + 1, _name.length());
    }
  }
  
  @Override
  public boolean equals(Object _other) {
    VrepObjectName name;
    String         fullName;
    
    if (!(_other instanceof VrepObjectName)) {
      return false;
    }
    
    name     = (VrepObjectName) _other;
    fullName = name.getFullName();
    
    return fullName.equals(this.fullName);
  }

}
