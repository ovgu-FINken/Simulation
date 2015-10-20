package velinov.java.finken.telemetry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import velinov.java.finken.drone.FinkenDrone;
import velinov.java.finken.messages.VirtualMessage;
import velinov.java.ivybus.message.Message;

/**
 * Represents the telemtry used by the {@link FinkenDrone}.
 * 
 * @author Vladimir Velinov
 * @since 16.05.2015
 */
public class Telemetry {
  
  private final List<TelemetryProcess>            telemetryProcesses;
  private final Map<Double, List<VirtualMessage>> timeMap;
  
  /**
   * default constructor.
   */
  public Telemetry() {
    this.telemetryProcesses = new ArrayList<TelemetryProcess>();
    this.timeMap            = new HashMap<Double, List<VirtualMessage>>();
  }
  
  /**
   * initialize the time-map.
   */
  public void initTimeMap() {
    TelemetryProcess process;
    TelemetryMode    mode;
    List<Message>    messages;
    
    /*
     * TODO fix this static initialization later.
     */
    process  = this.telemetryProcesses.get(0);
    mode     = process.getModes().get(0);
    messages = mode.getMessages();
    
    for (Message message : messages) {
      VirtualMessage vm         = new VirtualMessage(message);
      Double         period     = message.getPeriod();
      
      if (this.timeMap.containsKey(period)) {
        this.timeMap.get(period).add(vm);
      }
      else {
        List<VirtualMessage> list = new ArrayList<VirtualMessage>();
        list.add(vm);
        this.timeMap.put(period, list);
      }
    }
    
  }
  
  /**
   * @return the time-map.
   */
  public Map<Double, List<VirtualMessage>> getTimeMap() {
    return this.timeMap;
  }
  
  /**
   * @param _process
   */
  @SuppressWarnings("nls")
  public void addProcess(TelemetryProcess _process) {
    if (_process == null) {
      throw new NullPointerException("null telemetry process");
    }
    this.telemetryProcesses.add(_process);
  }
  
  /**
   * @return a list of all {@link TelemetryProcess}es.
   */
  public List<TelemetryProcess> getProcesses() {
    return this.telemetryProcesses;
  }
  
  /**
   * @return the configured {@link Message}s.
   */
  public List<Message> getMessages() {
    /*
     * takes the first telemetry process and mode.
     * TODO change later with xml parsing of the desired 
     * process and mode.
     */
    TelemetryProcess process;
    TelemetryMode    mode;
    
    process  = this.telemetryProcesses.get(0);
    mode     = process.getModes().get(0);
    
    return mode.getMessages();
  }
  
  /**
   * @param _msgName
   * @return the {@link Message} corresponding to the specified name 
   *     or {@code null} if no such message exists.
   */
  @SuppressWarnings("nls")
  public Message getMessage(String _msgName) {
    List<Message> messages;
    
    if (_msgName == null) {
      throw new NullPointerException("null message name");
    }
    
    messages = this.getMessages();
    
    for (Message message : messages) {
      if (message.getName().equals(_msgName)) {
        return message;
      }
    }
    
    return null;
  }
  
}
