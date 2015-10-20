package velinov.java.finken.app.ui;


/**
 * Define string constants used in the UI.
 * 
 * @author Vladimir Velinov
 * @since 19.04.2015
 *
 */
@SuppressWarnings({ "nls", "javadoc" })
public interface UIConstants {
  
  /***********************frame title ********************/
  
  public final static String FRAME_LABEL   = "Finken Simulation Bridge";
  
  /********************** borders *******************/

  public final static String BORDER_VREP             = "V-REP Server";
  public final static String BORDER_IVYBUS           = "Ivy-Bus Node";
  public final static String BORDER_TELEMETRY        = "Telemetry file";
  public final static String BORDER_AIRCRAFT         = "Aircraft file";
  
  /********************** button labels *******************/
  
  public final static String LBL_VREP_CONNECT_BTN    = "connect";
  public final static String LBL_VREP_DISCONNECT_BTN = "disconnect";
  public final static String LBL_IVY_CONNECT         = "connect";
  public final static String LBL_IVY_DISCONNECT      = "disconnect";
  public final static String LBL_FILE_CHOOSE_BTN     = "Open";
  
  
  /********************** action commands *******************/
  
  
  /********************** labels *****************************/
  
  public final static String LBL_VREP_IP           = "IP:";
  public final static String LBL_VREP_PORT         = "Port:";
  public final static String LBL_TELEMETRY_FILE    = "Telemetry file:";
  public final static String LBL_AIRCRAFT_FILE     = "Aircraft file:";
  
}
