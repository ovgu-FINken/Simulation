package velinov.java.jfreechart.realtime;

import org.jfree.data.Range;

import velinov.java.jfreechart.Chart;

/**
 * Describes a real-time plotting chart.
 * 
 * @author Vladimir Velinov
 * @since 11.04.2015
 *
 */
public interface RealTimePlot extends Chart {
  
  /**
   * a property that is fired whenever a new variable to be displayed is 
   * added to the plot.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_ADDED_VARIABLE    = "variableAdded";
  
  /**
   * a property that is fired whenever the values of all variables have been
   * updated - {@code RealTimePlot#updateRealTimeVariables(float[])} have been
   * invoked.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_VARIABLES_UPDATED = "variablesUpdated";
  
  /**
   * Update the values of the real-time graph. The method invokes 
   * {@code SwingUtilities#invokeLater()} and is thus Swing thread-safe.
   * 
   * @param _values 
   */
  void updateRealTimeVariables(float[] _values);
  
  /**
   * Add a variable to be displayed on the real-time graph. The event trigers
   * a {@code PROPERTY_ADDED_VARIABLE} property change.
   * 
   * @param _variable to be plotted.
   */
  void addRealTimeVariable(RealTimeVariable _variable);
  
  /**
   * @return the numbers of real-time variables which are currently displayed.
   */
  public int getVariablesCount();
  
  /**
   * Set the minimum and maximum values of the range axis.
   * @param _min the minimum displayable value.
   * @param _max the maximum displayable value.
   */
  public void setRange(float _min, float _max);
  
  /**
   * @return the range of the range axis.
   */
  abstract Range getRange();
  
}
