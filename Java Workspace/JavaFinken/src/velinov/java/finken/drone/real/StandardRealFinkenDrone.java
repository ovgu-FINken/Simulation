package velinov.java.finken.drone.real;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import org.xml.sax.SAXException;

import fr.dgac.ivy.IvyException;
import velinov.java.finken.aircraft.Aircraft;
import velinov.java.finken.calibration.MessageCalibrator;
import velinov.java.finken.calibration.RotorFPCalibrator;
import velinov.java.finken.drone.AbsFinkenDrone;
import velinov.java.finken.telemetry.Telemetry;
import velinov.java.finken.telemetry.TelemetryXmlReader;
import velinov.java.ivybus.message.Message;
import velinov.java.ivybus.message.MessageField;
import velinov.java.vrep.VrepConnection;
import velinov.java.vrep.objects.Shape;


/**
 * a standard implementation of <code>RealFinkenDrone</code>.
 * 
 * @author Vladimir Velinov
 * @since May 24, 2015
 */
public class StandardRealFinkenDrone extends AbsFinkenDrone 
    implements RealFinkenDrone, PropertyChangeListener
{
  /*
   * TODO Aircraft is common for Virtual and Real drone 
   * -> move it to AbsFinkenDrone.
   */
  private final Aircraft         aircraft;
  private final RealDroneBusNode busNode;
  private Telemetry              telemetry;
  private MessageCalibrator      calibrator;
  private Thread                 thread;
  private volatile boolean       publish;
  
  /**
   * default constructor.
   * 
   * @param _aircraft
   * @param _shape
   */
  @SuppressWarnings("nls")
  public StandardRealFinkenDrone(Aircraft _aircraft, Shape _shape) {
    super(_shape, _aircraft);
    
    if (_aircraft == null || _shape == null) {
      throw new NullPointerException("null aircraft or shape");
    }
    
    this.aircraft   = _aircraft;
    this.busNode    = new RealDroneBusNode(this.aircraft);
    this.calibrator = new RotorFPCalibrator(10);
    this.busNode.addPropertyChangeListener(this);
  }

  @Override
  public void joinIvyBus() {
    this.busNode.connect();
  }

  @Override
  public boolean isConnectedToBus() {
    return this.busNode.isConnected();
  }

  @Override
  public void leaveIvyBus() {
    this.busNode.disconnect();
  }
  
  @Override
  public void startPublish() {
    if (this.publish) {
      return;
    }
    this.thread  = new Thread(this);
    this.thread.start();
    this.publish = true;
  }

  @Override
  public void stopPublish() {
    if (!this.publish) {
      return;
    }
    this.publish = false;
    this.thread  = null;
  }
  
  @Override
  public boolean isPublishing() {
    return this.publish;
  }

  @SuppressWarnings("nls")
  @Override
  public void loadTelemetryData(File _telemetryXml)
      throws FileNotFoundException, SAXException, IOException, IvyException
  {
    TelemetryXmlReader reader;
    Message            rotorMessage;
    Message            systModelMsg;
    
    reader         = new TelemetryXmlReader(_telemetryXml, "vrep");
    reader.parseXmlDocument();
    this.telemetry = reader.getTelemetry();
    rotorMessage   = this.telemetry.getMessage("ROTORCRAFT_FP");
    systModelMsg   = this.telemetry.getMessage("FINKEN_SENSOR_MODEL");
    
    if (rotorMessage == null) {
      throw new NullPointerException("subscribe message not found in "
          + "the current configuration");
    }
    if (systModelMsg == null) {
      throw new NullPointerException("the subscribed message not found");
    }
    
    this.busNode.subscribeToIdMessage(this.aircraft.getStrId(), rotorMessage);
    this.busNode.subscribeToIdMessage(this.aircraft.getStrId(), systModelMsg);
  }

  @SuppressWarnings("nls")
  @Override
  public void propertyChange(PropertyChangeEvent _evt) {
    Message msg;
    
    if (!(_evt.getNewValue() instanceof Message)) {
      return;
    }
    
    msg = (Message) _evt.getNewValue();
    
    switch (msg.getName()) {
    
    case "ROTORCRAFT_FP":
      if (!this.calibrator.finished()) {
        this.calibrator.addMessage(msg);
        return;
      }

      this._handleActuatorsModel(msg);
      break;
      
    case "FINKEN_SYSTEM_MODEL":
      this._handleSensorModel(msg);
      break;
      
      default:
        return;
    }
  }
  
  @SuppressWarnings("nls")
  private void _handleSensorModel(Message _msg) {
    MessageField distField;
    float        distance;
    
    distField = _msg.getMessageField("distance_z");
    distance  = Float.valueOf(distField.getValue());
    
    //System.out.println("height" + distance);
    
    this.vrepConnection.simxSetFloatSignal(this.client.getClientId(), "height",
        distance, VrepConnection.simx_opmode_oneshot);
  }
  
  @SuppressWarnings("nls")
  private void _handleActuatorsModel(Message _msg) {
    MessageField alpha, beta, theta, throttle;
    float        alphaValue;
    float        betaValue;
    float        thetaValue;
    float        throttleValue;
    
    alpha      = _msg.getMessageField("phi"); // roll
    beta       = _msg.getMessageField("theta"); // pitch
    theta      = _msg.getMessageField("psi"); // yaw
    throttle   = _msg.getMessageField("thrust");
    
    alphaValue    = (Float.valueOf(alpha.getValue()) * 0.0139882f) 
        - this.calibrator.getCalibratedValue("phi");
    betaValue     = (Float.valueOf(beta.getValue()) * 0.0139882f) 
        - this.calibrator.getCalibratedValue("theta");
    thetaValue    = (Float.valueOf(theta.getValue()) * 0.0139882f) 
        - this.calibrator.getCalibratedValue("psi");
    
    throttleValue = Float.valueOf(throttle.getValue());
    throttleValue = ((Float.valueOf(throttle.getValue()) + 1350)) / 100;
    
    /*
     * umbau
     */
    //thetaValue = 0.0f;
    
    this.vrepConnection.simxSetFloatSignal(this.client.getClientId(), "roll",
        alphaValue, VrepConnection.simx_opmode_oneshot);
    
    this.vrepConnection.simxSetFloatSignal(this.client.getClientId(), "pitch",
        betaValue, VrepConnection.simx_opmode_oneshot);
    
    this.vrepConnection.simxSetFloatSignal(this.client.getClientId(), "yaw",
        thetaValue, VrepConnection.simx_opmode_oneshot);

    /*
     * TODO to support multiple real quadrocopters manage the names of the 
     * signals throttle, throttle0, throttle1 .. throttlen
     */
    this.vrepConnection.simxSetFloatSignal(this.client.getClientId(), "throttle",
        throttleValue, VrepConnection.simx_opmode_oneshot);
    
    /*
    System.out.println("alpha " + alphaValue + " beta " + betaValue 
        + " theta " + thetaValue + " thrust " + throttleValue);
        */
    
    this.fireBooleanPropertyChanged(PROPERTY_SIGNALS_UPDATED, true);
  }

  @Override
  public void run() {
    while (this.publish) {
      try {
        this.busNode.publishProxSensMessage(this.proxSensors);
      }
      catch (IvyException _e1) {
        _e1.printStackTrace();
      }
      
      try {
        Thread.sleep(50);
      }
      catch (InterruptedException _e) {
        // ignored
      }
    }
    
  }

}
