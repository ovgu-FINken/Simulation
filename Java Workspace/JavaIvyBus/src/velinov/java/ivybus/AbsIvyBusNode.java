package velinov.java.ivybus;

import java.util.ArrayList;
import java.util.List;

import fr.dgac.ivy.Ivy;
import fr.dgac.ivy.IvyClient;
import fr.dgac.ivy.IvyException;
import fr.dgac.ivy.IvyMessageListener;
import velinov.java.bean.AbsEventDispatchable;
import velinov.java.ivybus.message.Message;


/**
 * represents an abstract Ivy-bus node, implementing {@link IvyBusNode}.
 * 
 * @author Vladimir Velinov
 * @since 07.04.2015
 */
public abstract class AbsIvyBusNode extends AbsEventDispatchable implements IvyBusNode {
  
  protected final Ivy           ivyBus;
  protected final List<Message> subscribedMessages;
  private volatile boolean      isConnected;
  
  
  @SuppressWarnings("nls")
  protected AbsIvyBusNode(String _nodeTitle, String _initMessage) {
    if (_nodeTitle == null || _nodeTitle.isEmpty()) {
      throw new IllegalArgumentException("NodeTitle is null or empty");
    }
    
    if (_initMessage == null || _initMessage.isEmpty()) {
      throw new IllegalArgumentException("InitMessage is null or empty");
    }
    
    this.ivyBus             = new Ivy(_nodeTitle, _initMessage, null);
    this.subscribedMessages = new ArrayList<Message>();
  }
  
  @Override
  public void connect() {
    try {
      this.ivyBus.start(null);
    }
    catch (IvyException _e) {
      this.firePropertyChange(IVY_NODE_FAILED, null, _e);
    }
    this.isConnected = true;
    this.fireBooleanPropertyChanged(IVY_NODE_CONNECTED, this.isConnected);
  }
  
  @Override
  public void disconnect() {
    this.ivyBus.stop();
    this.isConnected = false;
    this.fireBooleanPropertyChanged(IVY_NODE_DISCONNECTED, this.isConnected);
  }
  
  @Override
  public boolean isConnected() {
    return this.isConnected;
  }
  
  @Override
  public List<String> getSubscribedMassageNames() {
    List<String> messageNames;
    String       name;
    
    messageNames = new ArrayList<String>(this.subscribedMessages.size());
    
    for (Message message : this.subscribedMessages) {
      name = message.getName();
      messageNames.add(name);
    }
    
    return messageNames;
  }

  @Override
  public void subscribeToMessage(Message _message) throws IvyException {
    String[] topic = {_message.getRegExp()};
    this.subscribe(_message, topic);
  }
  
  @SuppressWarnings("nls")
  @Override
  public void subscribeToIdMessage(String _id, Message _msg) 
      throws IvyException 
  {
    
    String[] topic = {"("+_id+")", _msg.getRegExp()};
   
    this.subscribe(_msg, topic);
  }
  
  @SuppressWarnings("nls")
  private void subscribe(Message _msg, String... _topic) throws IvyException {
    final Message message;
    String        topic;
    
    if (_msg == null || _topic == null) {
      throw new NullPointerException("null message or topics");
    }
    
    message = _msg;
    topic   = "";
    
    for (int i = 0; i < _topic.length; i ++) {
      topic = topic + _topic[i];
      if (i < (_topic.length - 1)) {
        topic = topic + " ";
      }
    }
    
    this.ivyBus.bindMsg(topic, new IvyMessageListener() {
      @Override
      public void receive(IvyClient _client, String[] _msgVal) {
        message.updateFieldValues(_msgVal[1]);

        firePropertyChange(IvyBusNode.MESSAGE_RECEIVED, null, message);
      }
    });
    
    this.subscribedMessages.add(message);
  }

}
