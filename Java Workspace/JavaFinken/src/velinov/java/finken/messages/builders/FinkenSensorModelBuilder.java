package velinov.java.finken.messages.builders;

import velinov.java.finken.drone.virtual.VirtualFinkenDrone;
import velinov.java.ivybus.message.Message;
import velinov.java.ivybus.message.MessageField;
import velinov.java.vrep.data.AngularVelocity;
import velinov.java.vrep.data.LinearVelocity;
import velinov.java.vrep.data.Position;

/**
 * @author Vladimir Velinov
 * @since May 26, 2015
 */
public class FinkenSensorModelBuilder extends VirtualMessageBuilder {

  @SuppressWarnings("nls")
  @Override
  public void buildMessage(Message _msg, VirtualFinkenDrone _drone) {
    AngularVelocity angV;
    LinearVelocity  linV;
    Position        position;
    MessageField    alphaField;
    MessageField    betaField;
    MessageField    gamaField;
    MessageField    distZField;
    MessageField    velXField;
    MessageField    velYField;
    float           distZ;
    float           vAlpha;
    float           vBeta;
    float           vGama;
    float           linVelX;
    float           linVelY;
    
    distZField  = _msg.getMessageField("distance_z");
    alphaField  = _msg.getMessageField("velocity_alpha");
    betaField   = _msg.getMessageField("velocity_beta");
    gamaField   = _msg.getMessageField("velocity_theta");
    velXField   = _msg.getMessageField("velocity_x");
    velYField   = _msg.getMessageField("velocity_y");
    
    
    position    = _drone.getPosition();
    angV        = _drone.getAngularVelocity();
    linV        = _drone.getLinearVelocity();
    
    vAlpha      = angV.getdAlpha();
    vBeta       = angV.getdBetha();
    vGama       = angV.getdGamma();
    distZ       = position.getZ();
    linVelX     = linV.getVx();
    linVelY     = linV.getVy();
    
    alphaField.setValue(String.valueOf(vAlpha));
    betaField.setValue(String.valueOf(vBeta));
    gamaField.setValue(String.valueOf(vGama));
    distZField.setValue(String.valueOf(distZ));
    velXField.setValue(String.valueOf(linVelX));
    velYField.setValue(String.valueOf(linVelY));
  }

}
