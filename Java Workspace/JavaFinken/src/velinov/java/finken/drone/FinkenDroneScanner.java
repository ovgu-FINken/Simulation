package velinov.java.finken.drone;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.SAXException;

import velinov.java.finken.aircraft.Aircraft;
import velinov.java.finken.aircraft.AircraftXmlReader;
import velinov.java.finken.drone.real.RealFinkenDrone;
import velinov.java.finken.drone.real.StandardRealFinkenDrone;
import velinov.java.finken.drone.virtual.StandardVirtualFinkenDrone;
import velinov.java.finken.drone.virtual.VirtualFinkenDrone;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.objects.Shape;
import velinov.java.vrep.scene.VrepScene;

/**
 * A scanner which retrieves all {@link FinkenDrone}s 
 * in a {@link VrepScene}.
 * 
 * @author Vladimir Velinov
 * @since 27.04.2015
 */
public class FinkenDroneScanner {
  
  /**
   * @param _scene
   * @param _client
   * @return all {@link RealFinkenDrone}s available.
   * @throws SAXException
   * @throws IOException
   */
  public static List<RealFinkenDrone> retrieveRealDrones(VrepScene _scene,
      VrepClient _client) throws SAXException, IOException 
  {
    List<Shape>              shapeObjects;
    List<Aircraft>           realAircrafts;
    List<RealFinkenDrone>    realDrones;
    AircraftXmlReader        reader;
    RealFinkenDrone          drone;
    
    realDrones       = new ArrayList<RealFinkenDrone>();
    shapeObjects     = _scene.getShapeObjects();
    reader           = new AircraftXmlReader();
    reader.parseXmlDocument();
    realAircrafts    = reader.getRealAircrafts();
    
    int    i = 0;
    String shapeName;
    for (Shape shape : shapeObjects) {
      for (Aircraft aircraft : realAircrafts) {
        shapeName = shape.getObjectName().getBaseName();
        
        if (aircraft.getName().equals(shapeName)) {
          shape.setSceneIndex(i);
          drone = new StandardRealFinkenDrone(aircraft, shape);
          realDrones.add(drone);
        }
      }
      i ++;
    }

    return realDrones;
  }
  
  /**
   * @param _scene 
   * @param _client 
   * @return alist of all drones.
   * @throws SAXException 
   * @throws IOException 
   */
  public static List<VirtualFinkenDrone> retrieveVirtualDrones(VrepScene _scene,
      VrepClient _client) throws SAXException, IOException 
  {
    List<Shape>              shapeObjects;
    List<Aircraft>           virtualAircrafts;
    List<VirtualFinkenDrone> drones;
    AircraftXmlReader        reader;
    VirtualFinkenDrone       drone;
    
    drones           = new ArrayList<VirtualFinkenDrone>();
    shapeObjects     = _scene.getShapeObjects();
    reader           = new AircraftXmlReader();
    reader.parseXmlDocument();
    virtualAircrafts = reader.getVirtualAircrafts();
 
    int i = 0;
    for (Shape shape : shapeObjects) {
      for (Aircraft aircraft : virtualAircrafts) {
        String shapeName;
        shapeName = shape.getObjectName().getBaseName();
        
        if (aircraft.getName().equals(shapeName)) {
          shape.setSceneIndex(i);
          drone = _createVirtualDrone(aircraft, shape);
          drones.add(drone);
        }
      }
      i ++;
    }

    return drones;
  }
  
  private static StandardVirtualFinkenDrone _createVirtualDrone(
      Aircraft _aircraft, Shape _shape) 
  {
    String droneIdStr;
    String shapeName;
    int    droneId;
    
    shapeName  = _shape.getObjectName().getBaseName();
    
    droneIdStr = shapeName.substring(
        StandardVirtualFinkenDrone.VIRTUAL_FINKEN_DRONE_NAME.length());
    
    droneId    = Integer.parseInt(droneIdStr);
    
    return new StandardVirtualFinkenDrone(_aircraft, _shape, droneId);
  }

}
