package velinov.java.xml.sax;

import org.xml.sax.SAXException;


/**
 * a custom <code>SAXException</code> used to be thrown when the 
 * <code>AbsXmlSaxReader</code> needs to be forced to cancel the parsing, for
 * example when a xml element of interest has been found.
 * 
 * @author Vladimir Velinov
 * @since Oct 19, 2015
 *
 */
public class StopParsingException extends SAXException {
  
  /**
   * default constructor.
   */
  @SuppressWarnings("nls")
  public StopParsingException() {
    super("SAX Xml reader stops parsing");
  }
}