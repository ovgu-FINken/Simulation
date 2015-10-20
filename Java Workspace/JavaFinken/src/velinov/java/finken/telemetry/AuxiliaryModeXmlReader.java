package velinov.java.finken.telemetry;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import velinov.java.xml.sax.AbsXmlSaxReader;


/**
 * an auxiliary <code>AbsXmlSaxReader</code> that reads the names of the modes 
 * in the telemetry xml file. 
 * 
 * @author Vladimir Velinov
 * @since Oct 19, 2015
 *
 */
public class AuxiliaryModeXmlReader extends AbsXmlSaxReader {
  
  private final List<String> modes;

  /**
   * default constructor.
   * 
   * @param _xmlFile
   * @throws SAXException
   * @throws FileNotFoundException
   */
  public AuxiliaryModeXmlReader(File _xmlFile)
      throws SAXException, FileNotFoundException
  {
    super(_xmlFile);
    this.modes = new ArrayList<String>();
  }
  
  /**
   * @return the parsed telemetry mode.
   */
  public List<String> getTelemetryModes() {
    return this.modes;
  }

  @SuppressWarnings("nls")
  @Override
  protected void onStartElementRead(String _uri, String _localName,
      String _qName, Attributes _attributes) throws SAXException
  {
    if (_localName.equals(TelemetryMode.TAG)) {
      String name;
      
      name = _attributes.getValue("name");
      this.modes.add(name);
    }
    
  }

  @Override
  protected void onEndElementRead(String _uri, String _localName,
      String _qName) throws SAXException
  {
    // TODO Auto-generated method stub
    
  }

  @Override
  protected void onParsingFinished() {
    // TODO Auto-generated method stub
  }

}
