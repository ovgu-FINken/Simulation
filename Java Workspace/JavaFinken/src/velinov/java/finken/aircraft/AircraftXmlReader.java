package velinov.java.finken.aircraft;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import velinov.java.xml.sax.AbsXmlSaxReader;


/**
 * An {@link AbsXmlSaxReader} that parses all {@link Aircraft}s 
 * from "paparazzi/conf/conf.xml".
 * 
 * @author Vladimir Velinov
 * @since 19.05.2015
 */
public class AircraftXmlReader extends AbsXmlSaxReader {
  
  @SuppressWarnings("nls")
  private static final String DEFAULT_FILE_LOCATION = 
      "/home/ees/paparazzi/conf/conf.xml";
  
  private final List<Aircraft> realAircrafts;
  private final List<Aircraft> virtualAircrafts;
  
  private Aircraft             tempAircraft;
  
  /**
   * @throws FileNotFoundException
   * @throws SAXException
   */
  public AircraftXmlReader() throws FileNotFoundException, SAXException {
    this(new File(DEFAULT_FILE_LOCATION));
  }

  /**
   * @param _xmlFile
   * @throws SAXException
   * @throws FileNotFoundException
   */
  public AircraftXmlReader(File _xmlFile)
      throws SAXException, FileNotFoundException
  {
    super(_xmlFile);
    
    this.realAircrafts    = new ArrayList<Aircraft>();
    this.virtualAircrafts = new ArrayList<Aircraft>();
  }

  /**
   * @return a list of all {@link Aircraft}s.
   */
  public List<Aircraft> getRealAircrafts() {
    return this.realAircrafts;
  }

  
  /**
   * @return a list of all virtual {@link Aircraft}s.
   */
  public List<Aircraft> getVirtualAircrafts() {
    return this.virtualAircrafts;
  }
  
  @SuppressWarnings("nls")
  @Override
  public void onStartElementRead(String _uri, String _localName, String _qName, 
      Attributes _attributes) throws SAXException 
  {
    if (_localName.equals(Aircraft.TAG)) {
      this.tempAircraft = new Aircraft();
      String name    = _attributes.getValue("name");
      String ac_id   = _attributes.getValue("ac_id");
      String color   = _attributes.getValue("gui_color");
      //String virtual = _attributes.getValue("virtual");
      
      this.tempAircraft.setName(name);
      this.tempAircraft.setId(Integer.valueOf(ac_id));
      this.tempAircraft.setGuiColor(color);
      
      if (name.startsWith("Virtual")) {
        this.tempAircraft.setIsVirtual(true);
      }
      /*
      if (virtual != null && virtual.equals("true")) {
        this.tempAircraft.setIsVirtual(true);
      }
      */
    }
  }
  
  @Override
  public void onEndElementRead(String _uri, String _localName, String _qName) 
      throws SAXException 
  {
    if (_localName.equals(Aircraft.TAG)) {
      if (this.tempAircraft.isVirtual()) {
        this.virtualAircrafts.add(this.tempAircraft);
      }
      else {
        this.realAircrafts.add(this.tempAircraft);
      }
      
      this.tempAircraft = null;
    }
  }

  @Override
  protected void onParsingFinished() {
    // TODO Auto-generated method stub
  }

}
