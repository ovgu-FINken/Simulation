package velinov.java.vrep.tests;

import static org.junit.Assert.*;

import org.junit.Test;

import velinov.java.vrep.objects.VrepObjectName;


/**
 * A test-case for <code>VrepObjectName</code>.
 * 
 * @author Vladimir Velinov
 * @since Jul 8, 2015
 *
 */
public class VrepObjectNameTest {

  /**
   * test 
   */
  @SuppressWarnings("nls")
  @Test
  public void test() {
    
    String         name;
    VrepObjectName objectName;
    
    name       = "Quad_Lia_ovgu_01";
    objectName = new VrepObjectName(name);
    
    assertTrue(!objectName.isIndexed());
    assertTrue(objectName.getBaseName().equals(name));
    assertTrue(objectName.getFullName().equals(name));
    assertTrue(objectName.getNameSuffix() == null);
    assertTrue(objectName.getNameIndex() == null);
    
    name       = "Quad_Lia_ovgu_01#0";
    objectName = new VrepObjectName(name);
    
    assertTrue(objectName.isIndexed());
    assertTrue(objectName.getBaseName().equals("Quad_Lia_ovgu_01"));
    assertTrue(objectName.getFullName().equals(name));
    assertTrue(objectName.getNameSuffix().equals("#0"));
    assertTrue(objectName.getNameIndex().equals("0"));
    
    name       = "Quad_Lia_ovgu_02#1";
    objectName = new VrepObjectName(name);
    
    assertTrue(objectName.isIndexed());
    assertTrue(objectName.getBaseName().equals("Quad_Lia_ovgu_02"));
    assertTrue(objectName.getFullName().equals(name));
    assertTrue(objectName.getNameSuffix().equals("#1"));
    assertTrue(objectName.getNameIndex().equals("1"));
    
  }

}
