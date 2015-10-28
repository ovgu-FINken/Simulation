package velinov.java.jfreechart;

import java.awt.Color;

import javax.swing.JPanel;

import org.jfree.chart.plot.Plot;
import org.jfree.data.general.Dataset;

import velinov.java.event.EventDispatchable;


/**
 * defines a simple chart.
 * 
 * @author Vladimir Velinov
 * @since 10.04.2015
 *
 */
public interface Chart extends EventDispatchable {
  
  /**
   * @return the <code>JPanel</code> of the <code>Chart</code>.
   */
  JPanel getPanel();
 
  /**
   * @return the <code>Dataset</code> of the <code>Chart</code>.
   */
  Dataset getDataSet();
  
  /**
   * @return the {@code Plot} of the <code>Chart</code>.
   */
  Plot getPlot();
  
  /**
   * set the background color of the <code>Chart</code>.
   * 
   * @param _color the new <code>Color</code>.
   */
  void setBackGroundColor(Color _color); 

}
