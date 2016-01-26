package velinov.java.jinput;

import velinov.java.event.AbsEventDispatchable;
import net.java.games.input.Component;
import net.java.games.input.Component.Identifier;
import net.java.games.input.Controller.Type;
import net.java.games.input.Controller;


/**
 * @author Vladimir Velinov
 * @since Jan 18, 2016
 */
public class Joystick extends AbsEventDispatchable implements Runnable {
  
  public final static String JOYSTICK_DATA_UPDATED = "dataUpdated";
  
  private final Controller controller;
  private Component        xAxis;
  private Component        yAxis;
  private Component        throttle;
  private float            xAxisValue;
  private float            yAxisValue;
  private float            throttleValue;
  private Thread           thread;
  private volatile boolean run;
  
  public Joystick(Controller _controller) {
    if (_controller.getType() != Type.STICK) {
      throw new IllegalArgumentException("illegal controller");
    }
    
    this.controller = _controller;
    
    for (Component comp : this.controller.getComponents()) {
      Identifier ident;
      
      ident = comp.getIdentifier();
      
      if (comp.isAnalog()) {
        if (ident == Component.Identifier.Axis.X) {
          this.xAxis = comp;
        }
        else if (ident == Component.Identifier.Axis.Y) {
          this.yAxis = comp;
        }
        else if (ident == Component.Identifier.Axis.Z) {
          this.throttle = comp;
        }
      }
      
    }
  }
  
  public void start() {
    this.run    = true;
    this.thread = new Thread(this);
    this.thread.start();
  }
  
  public void stop() {
    this.run    = false;
    this.thread = null;
  }

  @Override
  public void run() {
    if (!this.run) {
      return;
    }
    
    while (this.run) {
      
    this.controller.poll();
    this.xAxisValue    = this.xAxis.getPollData();
    this.yAxisValue    = this.yAxis.getPollData();
    this.throttleValue = this.throttle.getPollData();
    
    this.firePropertyChange(JOYSTICK_DATA_UPDATED,
        null, new Axes(this.xAxisValue, this.yAxisValue, this.throttleValue));
    
    try {
      Thread.sleep(50);
    }
    catch (InterruptedException _e) {
      // TODO Auto-generated catch block
      _e.printStackTrace();
    }
    
    }

  }
  
  class Axes {
    
    public float xAxis;
    public float yAxis;
    public float throttle;
    
    public Axes(float _xAxis, float _yAxis, float _throttle) {
      this.xAxis    = _xAxis;
      this.yAxis    = _yAxis;
      this.throttle = _throttle;
    }
  }

}