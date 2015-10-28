package velinov.java.vrep.objects;
import velinov.java.event.EventDispatchable;

/**
 * Defines an {@link VrepObject} updater, that updates the objects
 * with their dynamic simulation parameters.
 * 
 * @author Vladimir Velinov
 * @since 04.05.2015
 */
public interface ObjectUpdater extends EventDispatchable, Runnable {
  
  /**
   * defines the name of the thread.
   */
  @SuppressWarnings("nls")
  public static final String NAME = "Vrep Object Updater";
  
  /**
   * a property key that is fired when the {@code ObjectUpdater} gets started.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_STARTED         = "started";
  
  /**
   * a property key that is fired when the {@code ObjectUpdater} updates 
   * the {@link VrepObject}s. The frequency at which the objects get updated
   * depends on the simulation step.
   */
  @SuppressWarnings("nls")
  public static final String PROPERTY_OBJECTS_UPDATED = "objectsUpdated";
  
  /**
   * start the updater.
   */
  public void start();
  
  /**
   * stop the scanner.
   */
  public void stop();
  
  /**
   * @return {@code true} if the updater is currently updating.
   */
  public boolean isRunning();

}
