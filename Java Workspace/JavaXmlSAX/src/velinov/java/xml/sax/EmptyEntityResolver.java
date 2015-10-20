package velinov.java.xml.sax;

import java.io.IOException;
import java.io.StringReader;

import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;


/**
 * A DTD workaround see: 
 * http://stuartsierra.com/2008/05/08/stop-your-java-sax-parser-from-
 * downloading-dtds
 * 
 * @author Vladimir Velinov
 * @since 10.05.2015
 */
public class EmptyEntityResolver implements EntityResolver {

  @SuppressWarnings("nls")
  @Override
  public InputSource resolveEntity(String _arg0, String _arg1)
      throws SAXException, IOException
  {
    return new InputSource(new StringReader(""));
  }

}
