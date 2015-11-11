package velinov.java.finken.app.ui.tabs.messages;

import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.List;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JComboBox;
import javax.swing.SwingUtilities;

import velinov.java.finken.VREPRealTimePlot;
import velinov.java.finken.app.ui.tabs.AbsTab;
import velinov.java.finken.drone.DronePool;
import velinov.java.finken.drone.real.RealFinkenDrone;
import velinov.java.jfreechart.realtime.RealTimeVariable;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.VrepClientUtils;
import velinov.java.vrep.objects.VrepObjectName;
import velinov.java.vrep.scene.VrepScene;
import velinov.java.vrep.scene.VrepSceneUtils;


/**
 * a <code>JPanel</code> defining the view for the messages tab 
 * in the <code>FinkenSimBridgeView</code>. 
 * 
 * @author Vladimir Velinov
 * @since Oct 27, 2015
 *
 */
public class MessagesTab extends AbsTab implements PropertyChangeListener {
  
  private final VREPRealTimePlot plot;
  private final JComboBox        combo;
  private final ItemListener     droneComboListener;
  
  private List<RealFinkenDrone>  realDrones;
  private RealFinkenDrone        drone;
  private RealTimeVariable       variable;
  
  private long                   prevTime;
  private long                   delay;
 
  /**
   * default constructor.
   */
  public MessagesTab() {
    VrepClient client;
    DronePool  dronePool;
    VrepScene  scene;
    
    this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
    
    client                  = VrepClientUtils.getVrepClient();
    scene                   = VrepSceneUtils.getVrepScene(client);
    dronePool               = DronePool.getInstance(scene, client);
    this.droneComboListener = new DroneComboBoxListener();
    dronePool.addPropertyChangeListener(this);
    
    this.plot  = new VREPRealTimePlot();
    this.combo = new JComboBox();
    this.combo.addItemListener(this.droneComboListener);
    
    this.variable = new RealTimeVariable("id", "lag");
    this.plot.addRealTimeVariable(this.variable);
 
    this.add(this.combo);
    this.add(this.plot.getPanel());
    this.add(Box.createVerticalStrut(100));
  }
  
  @SuppressWarnings("nls")
  private static final String TAB_LABEL = "Messages";

  @Override
  public String getTabLabel() {
    return TAB_LABEL;
  }

  @Override
  public void propertyChange(PropertyChangeEvent _evt) {
    String propName;
    
    propName = _evt.getPropertyName();
    
    if (propName.equals(DronePool.REAL_DRONES_RETRIEVED))  {
      List<RealFinkenDrone> drones;
      
      drones          = (List<RealFinkenDrone>) _evt.getNewValue();
      this.realDrones = drones;
      
      this._populateComboBox(drones);
    }
    else if (propName.equals(RealFinkenDrone.PROPERTY_SIGNALS_UPDATED)) {
      long currTime;
      
      currTime      = System.currentTimeMillis();
      this.delay    = currTime - this.prevTime;
      this.prevTime = currTime;
      
      this.plot.updateRealTimeVariables(new float[] {this.delay});
    }
  }
  
  private void _populateComboBox(List<RealFinkenDrone> _drones) {
    SwingUtilities.invokeLater(new Runnable() {
      @Override
      public void run() {
        for (RealFinkenDrone drone : _drones) {
          MessagesTab.this.combo.addItem(drone.getObjectName().getBaseName());
        }
      }
    });
  }
  
  private class DroneComboBoxListener implements ItemListener {
    private final MessagesTab inst = MessagesTab.this;
    
    @Override
    public void itemStateChanged(ItemEvent _event) {
      JComboBox cmbBox;
      String    item;
      
      if (this.inst.realDrones == null) {
        return;
      }
      
      cmbBox = (JComboBox) _event.getSource();
      item   = (String) _event.getItem();

      if (_event.getStateChange() == ItemEvent.SELECTED) {
        for (RealFinkenDrone drone : this.inst.realDrones) {
          VrepObjectName name;
          
          name = drone.getObjectName();
          
          if (name.getBaseName().equals(item)) {
            this.inst._initDrone(drone);
            this.inst.drone = drone;
            break;
          }
        }
      }
      
    }
    
  }
  
  private void _initDrone(RealFinkenDrone _drone) {
    if (this.drone == null) {
      return;
    }
    this.drone.removePropertyChangeListener(this);
    this.drone = _drone;
    this.drone.addPropertyChangeListener(this);
  }

}
