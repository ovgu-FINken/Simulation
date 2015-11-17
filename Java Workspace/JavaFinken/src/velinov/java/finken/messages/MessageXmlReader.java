package velinov.java.finken.messages;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import velinov.java.ivybus.message.AbsMessage;
import velinov.java.ivybus.message.Message;
import velinov.java.ivybus.message.MessageClass;
import velinov.java.ivybus.message.MessageField;
import velinov.java.xml.sax.AbsXmlSaxReader;

/**
 * A {@link AbsXmlSaxReader}, that loads all {@link Message}s from 
 * the {@code paparazzi/conf/messages.xml} file.
 * 
 * @author Vladimir Velinov
 * @since 11.05.2015
 */
public class MessageXmlReader extends AbsXmlSaxReader {
  
  private List<MessageClass>   messageClasses;
  private Map<String, Message> messagesMap;
  
  @SuppressWarnings("nls")
  private static final String DEFAULT_FILE_LOCATION = 
      "/home/ees/paparazzi/conf/messages.xml";
  
  @SuppressWarnings("nls")
  private static final String CLASS                 = "msg_class";
  
  @SuppressWarnings("nls")
  private static final String MESSAGE               = "message";
  
  @SuppressWarnings("nls")
  private static final String FIELD                 = "field";
  
  @SuppressWarnings("nls")
  private static final String TELEMETRY_CLASS       = "telemetry";
  
  private MessageClass tempMsgClass;
  private Message      tempMessage;
  private MessageField tempField;
  
  /**
   * default constructor.
   * 
   * @throws FileNotFoundException
   * @throws SAXException
   */
  public MessageXmlReader() throws FileNotFoundException, SAXException {
    this(new File(DEFAULT_FILE_LOCATION));
    
    this.messageClasses = new ArrayList<MessageClass>();
    this.messagesMap    = new HashMap<String, Message>();
  }

  /**
   * @param _xmlFile
   * @throws SAXException
   * @throws FileNotFoundException
   */
  public MessageXmlReader(File _xmlFile)
      throws SAXException, FileNotFoundException
  {
    super(_xmlFile);
  }
  
  /**
   * @return all massages
   */
  public List<MessageClass> getMessageList() {
    return this.messageClasses;
  }
  
  /**
   * @return all {@link Message}s stored in a {@link Map}.
   */
  public Map getMessageMap() {
    return this.messagesMap;
  }
  
  @SuppressWarnings("nls")
  @Override
  public void onStartElementRead(String _uri, String _localName, String _qName, 
      Attributes _attributes) throws SAXException 
  {
    
    if (_localName.equals(CLASS)) {
      this.tempMsgClass = new MessageClass();
      String className  = _attributes.getValue("name");
      
      this.tempMsgClass.setName(className);
    }
    
    if (_localName.equals(MESSAGE)) {
      this.tempMessage = this._initMessage(_attributes);
    }
    
    if (_localName.equals(FIELD)) {
      this.tempField = this._initField(_attributes);
    }
    
  }
  
  @Override
  public void onEndElementRead(String _uri, String _localName, String _qName) 
      throws SAXException 
  {
    if (_localName.equals(CLASS)) {
      this.messageClasses.add(this.tempMsgClass);
      this.tempMessage = null;
      
      if (this.tempMsgClass.getName().equals(TELEMETRY_CLASS)) {
        /*
         * just telemetry needed -> no need to parse the other messages
         */
        this.stopParsing();
      }
    }
    
    if (_localName.equals(MESSAGE)) {
      this.tempMsgClass.addMessage(this.tempMessage);
      this.messagesMap.put(this.tempMessage.getName(), this.tempMessage);
      this.tempMessage = null;
    }
    
    if (_localName.equals(FIELD)) {
      this.tempMessage.addMessageField(this.tempField);
      this.tempField = null;
    }
  }
  
  @SuppressWarnings("nls")
  private Message _initMessage(Attributes _attributes) {
    Message msg;
    String  name;
    String  idStr;
    
    name  = _attributes.getValue("name");
    idStr = _attributes.getValue("id"); 
    msg   = new AbsMessage(name);
    
    if (idStr != null) {
      msg.setId(Integer.valueOf(idStr));
    }
    
    return msg;
  }
  
  @SuppressWarnings("nls")
  private MessageField _initField(Attributes _attributes) {
    final MessageField field;
    final String       name;
    final String       type;
    final String       format;
    final String       coeff;
    final String       unit;
    
    name   = _attributes.getValue("name");
    type   = _attributes.getValue("type");
    format = _attributes.getValue("format");
    coeff  = _attributes.getValue("alt_unit_coef");
    unit   = _attributes.getValue("alt_unit");
    
    field  = new MessageField(name, type);
    
    field.setFormat(format);
    field.setUnit(unit);
    field.setCoeff(coeff);
    
    return field;
  }

  @Override
  protected void onParsingFinished() {
    // the list is not used -> empty or remove completely ?
    this.messageClasses.clear();
  }

}