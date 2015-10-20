package velinov.java.jfreechart;

import java.awt.Color;

import javax.swing.JPanel;

import org.jfree.chart.plot.Plot;
import org.jfree.data.general.Dataset;

import velinov.java.bean.EventDispatchable;


/**
 * @author Vladimir Velinov
 * @since 10.04.2015
 *
 */
public interface Chart extends EventDispatchable {
  
  /**
   * @return the panel of the {@code Chart}.
   */
  JPanel getPanel();
 
  /**
   * @return the dataset of the chart.
   */
  Dataset getDataSet();
  
  /**
   * @return the {@code Plot} of the chart
   */
  Plot getPlot();
  
  /**
   * @param _color
   */
  void setBackGroundColor(Color _color); 

}
