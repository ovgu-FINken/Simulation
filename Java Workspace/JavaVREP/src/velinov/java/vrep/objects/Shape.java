package velinov.java.vrep.objects;

import velinov.java.vrep.VrepClient;

/**
 * Represents a Shape {@link VrepObject}.
 * 
 * @author Vladimir Velinov
 * @since 27.04.2015
 */
public class Shape extends AbsVrepObject {

  /**
   * initialize a shape.
   * @param _name
   * @param _client
   */
  public Shape(String _name, VrepClient _client) {
    super(VrepObjectType.SHAPE, _name, _client);
  }
  
  /**
   * @param _name
   * @param _handle
   * @param _client
   */
  public Shape(String _name, int _handle, VrepClient _client) {
    super(VrepObjectType.SHAPE, _name, _handle, _client);
  }

}
