package velinov.java.finken.drone.real;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.xml.sax.SAXException;

import fr.dgac.ivy.IvyException;
import velinov.java.finken.drone.FinkenDrone;
import velinov.java.ivybus.message.Message;

/**
 * Describes a V-REP model of a real-world finken drone. The V-REP model of a 
 * real drone behaves like the real, physical flying quadrocopter. It subscribes
 * to its telemetry messages - ROTORCRAFT_FP and FINKEN_SYSTEM_MODEL and 
 * retrieves the live parametars: pitch, yaw, roll, throttle and height from 
 * the messages to update the V-REP model with them.
 * The <code>RealFinkenDrone</code> gets updated with the proximity sensor 
 * values from the V-REP model and sends them as a SONAR_UPLINK 
 * <code>Message</code> on the Ivy-Bus to the real-drone.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public interface RealFinkenDrone extends FinkenDrone, Runnable {
  
  public static final String PROPERTY_SIGNALS_UPDATED = "updated";
  
  /**
   * start to publish data on the Ivy-bus.
   */
  public void startPublish();
  
  /**
   * stop to publish data on the Ivy-bus.
   */
  public void stopPublish();
  
  /**
   * @return {@code true} if the {@code RealFinkenDrone} is currently
   *     publishing {@link Message}s on the IvyBus. 
   */
  public boolean isPublishing();
  
  /**
   * loads the telemetry from an xml file.
   * 
   * @param _telemetryXml
   * @throws SAXException 
   * @throws FileNotFoundException 
   * @throws IOException 
   * @throws IvyException 
   */
  public void loadTelemetryData(File _telemetryXml) 
      throws FileNotFoundException, SAXException, IOException, IvyException;
}
