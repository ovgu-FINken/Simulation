package velinov.java.vrep.objects;

import velinov.java.bean.AbsEventDispatchable;
import velinov.java.vrep.VrepClient;
import velinov.java.vrep.VrepConnection;
import velinov.java.vrep.VrepConnectionUtils;


/**
 * An abstract implementation of <code>ObjectUpdater</code>.
 * 
 * @author Vladimir Velinov
 * @since Jul 7, 2015
 *
 */
public abstract class AbsObjectUpdater extends AbsEventDispatchable 
    implements ObjectUpdater 
{
  private Thread                 thread;
  protected final VrepConnection vrepConnection;
  protected final VrepClient     vrepClient;
  private long                   simStep;
  private volatile boolean       run;
  
  /**
   * default constructor.
   * @param _vrepClient 
   */
  protected AbsObjectUpdater(VrepClient _vrepClient) {
    this.vrepClient     = _vrepClient;
    this.vrepConnection = VrepConnectionUtils.getConnection();
    this.simStep        = 50;
  }

  @Override
  public void start() {
    if (this.isRunning()) {
      return;
    }
    
    if (this.thread == null) {
      this.thread = new Thread(this, ObjectUpdater.NAME);
      this.run    = true;
      this.thread.start();
      this.fireBooleanPropertyChanged(PROPERTY_STARTED, this.run);
    }
  }

  @Override
  public void stop() {
    this.run    = false;
    this.thread = null;
    this.fireBooleanPropertyChanged(PROPERTY_STARTED, this.run);
  }

  @Override
  public boolean isRunning() {
    return this.run;
  }

  @Override
  public void run() {
    while (this.run) {
      this.onObjectUpdate();
      try {
        Thread.sleep(this.simStep);
      }
      catch (InterruptedException _e) {
        // ignored.
      }
    }
  }
  
  abstract protected void onObjectUpdate();

}
