package velinov.java.jfreechart;

import java.awt.Color;
import javax.swing.JPanel;

import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.Plot;
import org.jfree.data.general.Dataset;

import velinov.java.bean.AbsEventDispatchable;


/**
 * an abstract implementation of {@link Chart}.
 * 
 * @author Vladimir Velinov
 * @since 11.04.2015
 *
 */
public abstract class AbsChart extends AbsEventDispatchable implements Chart {
  
  protected JFreeChart chart;
  protected Dataset    dataSet;
  protected Plot       plot;
  private   ChartPanel panel;
  
  

  @Override
  public JPanel getPanel() {
    if (this.panel == null) {
      this.panel = new ChartPanel(this.chart);
    }
    
    return this.panel;
  }
  
  @Override
  public Dataset getDataSet() {
    return this.dataSet;
  }
  
  @Override
  public Plot getPlot() {
    return this.plot;
  }

  @Override
  public void setBackGroundColor(Color _color) {
   this.plot.setBackgroundPaint(_color);
  }
  


}
