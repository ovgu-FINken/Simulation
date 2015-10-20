package velinov.java.finken.app.ui.tabs.connection;

import java.awt.Dimension;
import java.util.Collections;
import java.util.List;

import velinov.java.finken.app.ui.AbsConnectPanel;
import velinov.java.finken.app.ui.UIConstants;
import velinov.java.ivybus.IvyBusNode;

/**
 * An {@link AbsConnectPanel}, that manages the connection to the IVYBus.
 * 
 * @author Vladimir Velinov
 * @since 25.04.2015
 *
 */
public class IvyBusConnectPanel extends AbsConnectPanel {
  
  @Override
  protected Dimension getPanelSize() {
    return new Dimension(1, 50);
  }

  @Override
  protected Dimension getConnectBtnSize() {
    return new Dimension(120, 25);
  }

  @Override
  protected String getBorderTitle() {
    return UIConstants.BORDER_IVYBUS;
  }

  @Override
  protected String getBtnConnectedLabel() {
    return UIConstants.LBL_IVY_DISCONNECT;
  }

  @Override
  protected String getBtnDisconnectedLabel() {
    return UIConstants.LBL_IVY_CONNECT;
  }

  @Override
  protected Object getConnectObject() {
    return null;
  }

  @Override
  protected String getPropertyConnected() {
    return IvyBusNode.IVY_NODE_CONNECTED;
  }

  @Override
  protected String getPropertyDisconnected() {
    return IvyBusNode.IVY_NODE_DISCONNECTED;
  }

  @Override
  protected List getLeftPanelComponents() {
    return Collections.EMPTY_LIST;
  }

}
