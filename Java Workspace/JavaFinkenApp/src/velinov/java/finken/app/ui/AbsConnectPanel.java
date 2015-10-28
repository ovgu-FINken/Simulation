package velinov.java.finken.app.ui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JPanel;

import velinov.java.event.AbsEventDispatchable;

/**
 * An abstract implementation of {@link ConnectPanel}.
 * 
 * @author Vladimir Velinov
 * @since 21.04.2015
 */
public abstract class AbsConnectPanel extends AbsEventDispatchable 
    implements ConnectPanel 
{  
  private final JPanel     mainPanel;
  private final JPanel     leftPanel;
  private final JPanel     rightPanel;
  
  private final JButton    connectButton;
  private boolean          connected;
  
  private ConnectRequestor hadnler;
  
  private ConnectListener  listener;
  
  protected AbsConnectPanel() {
    this.mainPanel = new JPanel();
    this.mainPanel.setLayout(new BorderLayout());
    this.mainPanel.setPreferredSize(this.getPanelSize());
    this.mainPanel.setBorder(BorderFactory.createTitledBorder(
        this.getBorderTitle()));
    
    this.leftPanel     = new JPanel(new FlowLayout(FlowLayout.LEFT, 20, 0));
    this.rightPanel    = new JPanel(new FlowLayout(FlowLayout.RIGHT, 20, 0));
    
    this.connectButton = new JButton(this.getBtnDisconnectedLabel());
    this.hadnler       = new ConnectRequestor();
    this.listener      = new ConnectListener();
    
    this.rightPanel.add(this.connectButton);
    this._initLeftPanel();
    
    this.connectButton.addActionListener(this.hadnler);
    this.connectButton.setPreferredSize(this.getConnectBtnSize());
    
    this.mainPanel.add(this.leftPanel, BorderLayout.WEST);
    this.mainPanel.add(this.rightPanel, BorderLayout.EAST);
  }
  
  @Override
  public JPanel getPanel() {
    return this.mainPanel;
  }
  
  @Override
  public PropertyChangeListener getPropertyChangeListener() {
    return this.listener;
  }
  
  private void _initLeftPanel() {
    for (JComponent cmp : this.getLeftPanelComponents()) {
      this.leftPanel.add(cmp);
    }
  }
  
  protected abstract Dimension getPanelSize();
  
  protected abstract Dimension getConnectBtnSize();
  
  protected abstract String getBorderTitle();
  
  protected abstract String getBtnConnectedLabel();
  
  protected abstract String getBtnDisconnectedLabel();
  
  protected abstract Object getConnectObject();
  
  protected abstract String getPropertyConnected();
  
  protected abstract String getPropertyDisconnected();
  
  protected abstract List<JComponent> getLeftPanelComponents();
  
  /**
   * handles the updating on connection/disconnection.
   */
  private class ConnectListener implements PropertyChangeListener {
    
    private String property;
    
    @Override
    public void propertyChange(PropertyChangeEvent _event) {
      this.property = _event.getPropertyName();
      
      if (this.property.equals(getPropertyConnected())) {
        UIUtils.setText(AbsConnectPanel.this.connectButton,
            getBtnConnectedLabel());
        
        AbsConnectPanel.this.connected = true;
      }
      else if (this.property.equals(getPropertyDisconnected())) {
        UIUtils.setText(AbsConnectPanel.this.connectButton,
            getBtnDisconnectedLabel());
        
        AbsConnectPanel.this.connected = false;
      }
    }
  }
  
  
  private class ConnectRequestor implements ActionListener {
    @Override
    public void actionPerformed(ActionEvent _event) {
      if (_event.getSource() == AbsConnectPanel.this.connectButton) {
        if (!AbsConnectPanel.this.connected) {
          AbsConnectPanel.this.firePropertyChange(
              ConnectPanel.PROPERTY_CONNECT, null, getConnectObject());
        }
        else {
          AbsConnectPanel.this.firePropertyChange(
              ConnectPanel.PROPERTY_DISCONNECT, null, null);
        }
      }
    }
  }


}
