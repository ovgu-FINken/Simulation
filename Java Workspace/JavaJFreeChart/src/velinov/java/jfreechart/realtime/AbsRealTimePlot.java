package velinov.java.jfreechart.realtime;
 
import java.awt.Paint;
import javax.swing.SwingUtilities;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.plot.XYPlot;
import org.jfree.data.time.DynamicTimeSeriesCollection;
import org.jfree.data.time.RegularTimePeriod;
import org.jfree.data.time.Second;
import org.jfree.data.xy.XYDataset;

import velinov.java.jfreechart.AbsChart;

/**
 * @author Vladimir Velinov
 * @since 11.04.2015
 *
 */
public abstract class AbsRealTimePlot extends AbsChart implements RealTimePlot {
  
  private static final int DEFAULT_MAX_VARIABLE_COUNT = 10;
  private static final int COUNT                      = 2 * 60;
  
  private ValueAxis              domain;
  private ValueAxis              range;
  private RegularTimePeriod      period;
  
  /**
   * default constructor.
   * 
   * @param _title 
   *          title of the plot or null if no title is required.
   * @param _timeAxisLabel 
   * @param _valueAxisLabel 
   */
  public AbsRealTimePlot(String _title, String _timeAxisLabel, 
      String _valueAxisLabel) 
  {  
    this.period    = new Second(0, 0, 0, 1, 1, 2015);
    this.dataSet   = new DynamicTimeSeriesCollection(
        DEFAULT_MAX_VARIABLE_COUNT, COUNT, new Second());
    
    ((DynamicTimeSeriesCollection) this.dataSet).setTimeBase(this.period);
    
    this.chart     = ChartFactory.createTimeSeriesChart(_title, _timeAxisLabel,
        _valueAxisLabel, (XYDataset) this.dataSet);
    
    this.plot      = this.chart.getXYPlot();
    this.domain    = ((XYPlot) this.plot).getDomainAxis();
    this.range     = ((XYPlot) this.plot).getRangeAxis();
    
    this.range.setRange(this.getRange());
    this.plot.setBackgroundPaint(this.getBackgroundColor());
    this.domain.setAutoRange(this.isAutoRange());
    this.domain.setVisible(this.isDomainVisible());
    this.domain.setAxisLineVisible(this.isAxisLineVisible());
    this.domain.setTickMarksVisible(this.isTickMarksVisible());
    
  }
  
  @Override
  public void setRange(float _min, float _max) {
    this.range.setRange(_min, _max);
  }

  @SuppressWarnings("nls")
  @Override
  public void updateRealTimeVariables(final float[] _values) {
    if (_values.length != this.getVariablesCount()) {
      throw new IllegalArgumentException("variable length mismatch");
    }
    
    SwingUtilities.invokeLater(new Runnable() {
      @Override
      public void run() {
        ((DynamicTimeSeriesCollection) AbsRealTimePlot.this.
            dataSet).advanceTime();
        ((DynamicTimeSeriesCollection) AbsRealTimePlot.this.
            dataSet).appendData(_values);
      }
    });
    
    this.firePropertyChange(PROPERTY_VARIABLES_UPDATED, null, _values);
  }
  
  @SuppressWarnings("nls")
  @Override
  public void addRealTimeVariable(RealTimeVariable _variable) {
    if (_variable == null ) {
      throw new NullPointerException("null variable");
    }
    
    if (this.getVariablesCount() == 0) {
      ((DynamicTimeSeriesCollection) this.dataSet).addSeries(new float[COUNT],
          0, _variable.getLabel());
    }
    else {
      ((DynamicTimeSeriesCollection) this.dataSet).addSeries(new float[COUNT],
          this.getVariablesCount() + 1, _variable.getLabel());
    }
    
    this.firePropertyChange(PROPERTY_ADDED_VARIABLE, null, _variable);
  }
  
  @Override
  public int getVariablesCount() { 
    return ((DynamicTimeSeriesCollection) this.dataSet).getSeriesCount();
  }
  
  /**
   * @return the background color of the plot.
   */
  protected abstract Paint getBackgroundColor();
  
  /**
   * @return {@code true} if the range-axis auto-ranges as the values change.
   */
  protected abstract boolean isAutoRange();
  
  /**
   * @return {@code true} if the domain-axis is visible.
   */
  protected abstract boolean isDomainVisible();
  
  protected abstract boolean isAxisLineVisible();
  
  protected abstract boolean isTickMarksVisible();

}
