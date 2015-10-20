package velinov.java.finken.telemetry;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Map;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import velinov.java.finken.messages.MessageXmlReader;
import velinov.java.ivybus.message.Message;
import velinov.java.xml.sax.AbsXmlSaxReader;
import velinov.java.xml.sax.StopParsingException;


/**
 * A {@link AbsXmlSaxReader} that creates a {@link Telemetry} from a xml file.
 * 
 * @author Vladimir Velinov
 * @since 17.05.2015
 */
public class TelemetryXmlReader extends AbsXmlSaxReader {
  
  private final MessageXmlReader msgReader;
  private Map<String, Message>   allMessages;
  private Telemetry              telemetry;
  
  // temp objects
  private TelemetryProcess       tempProcess;
  private TelemetryMode          tempMode;
  private Message                tempMessage;
  
  private final String           mode;
  
  /**
   * default constructor.
   * 
   * @param _xmlFile
   *          the file containing the telemetry.
   * @param _mode 
   * @throws SAXException
   * @throws FileNotFoundException
   */
  @SuppressWarnings("nls")
  public TelemetryXmlReader(File _xmlFile, String _mode)
      throws SAXException, FileNotFoundException
  {
    super(_xmlFile);
    
    if (_mode == null || _mode.isEmpty()) {
      throw new IllegalArgumentException("illegal mode");
    }
    
    this.msgReader = new MessageXmlReader();
    this.telemetry = new Telemetry();
    this.mode      = _mode;
  }
  
  @Override
  public void parseXmlDocument() throws IOException, SAXException {
    if (this.allMessages == null) {
      // parse messages first.
      this.msgReader.parseXmlDocument();
      this.allMessages = this.msgReader.getMessageMap();
    }
    
    try {
      this.reader.parse(this.xmlSource);
    }
    catch (StopParsingException _e) {
      return;
    }
  }
  
  @SuppressWarnings("nls")
  @Override
  public void onStartElementRead(String _uri, String _localName, String _qName, 
      Attributes _attributes) throws SAXException 
  {
    if (_localName.equals(TelemetryProcess.TAG)) {
      this.tempProcess = new TelemetryProcess();
      String name      = _attributes.getValue("name");
      this.tempProcess.setName(name);
    }
    if (_localName.equals(TelemetryMode.TAG)) {
      this.tempMode = new TelemetryMode();
      String name      = _attributes.getValue("name");
      this.tempMode.setName(name);
      
      
    }
    if (_localName.equals(Message.TAG)) {
      String msgName   = _attributes.getValue("name");
      String msgPeriod = _attributes.getValue("period");
      this.tempMessage = this.allMessages.get(msgName);
      
      if (this.tempMessage != null) {
        // message not found -> inconsistent xml files.
        this.tempMessage.setPeriod(Double.parseDouble(msgPeriod));
      }
    }
    
  }
  
  @Override
  public void onEndElementRead(String _uri, String _localName, String _qName) 
      throws SAXException 
  {
    if (_localName.equals(TelemetryProcess.TAG)) {
      this.telemetry.addProcess(this.tempProcess);
      this.tempProcess = null;
    }
    if (_localName.equals(TelemetryMode.TAG)) {
      this.tempProcess.addMode(this.tempMode);
      
      if (this.tempMode.getName().equals(this.mode)) {
        this.telemetry.addProcess(this.tempProcess);
        this.stopParsing();
      }
      
      this.tempMode = null;
    }
    if (_localName.equals(Message.TAG)) {
      this.tempMode.addMessage(this.tempMessage);
      this.tempMessage = null;
    }
  }
  
  /**
   * @return the initialized {@link Telemetry}.
   */
  public Telemetry getTelemetry() {
    return this.telemetry;
  }

  @Override
  protected void onParsingFinished() {
    this.allMessages.clear();
    this.allMessages = null;
  }

}
