package velinov.java.finken;

import java.awt.Color;
import java.awt.Paint;

import org.jfree.data.Range;

import velinov.java.jfreechart.realtime.AbsRealTimePlot;
import velinov.java.jfreechart.realtime.RealTimePlot;

/**
 * Represents a standard {@link RealTimePlot}.
 * 
 * @author Vladimir Velinov
 * @since 13.04.2015
 */
public class VREPRealTimePlot extends AbsRealTimePlot {
  
  private static final float MAX_RANGE = 1000;
  
  private static final float MIN_RANGE = 0;

  /**
   * default constructor.
   */
  public VREPRealTimePlot() {
    super(null, null, null);
    
    /*
    this.addRealTimeVariable(new RealTimeVariable(
        FlightParamMsg.MESSAGE_NAME, "distance"));
        */
  }

  @Override
  public Range getRange() {
    return new Range(MIN_RANGE, MAX_RANGE);
  }

  @Override
  public Paint getBackgroundColor() {
    return Color.WHITE;
  }

  @Override
  public boolean isAutoRange() {
    return true;
  }

  @Override
  protected boolean isDomainVisible() {
    return false;
  }

  @Override
  protected boolean isAxisLineVisible() {
    return false;
  }

  @Override
  protected boolean isTickMarksVisible() {
    return false;
  }

}
