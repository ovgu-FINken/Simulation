package velinov.java.finken;

import fr.dgac.ivy.IvyClient;
import fr.dgac.ivy.IvyException;
import fr.dgac.ivy.IvyMessageListener;
import velinov.java.ivybus.AbsIvyBusNode;
import velinov.java.ivybus.IvyBusNode;


public class TestNode extends AbsIvyBusNode {
  

  protected TestNode() {
    super("test node", "joined");
  }

  public static void main(String[] _args) throws IvyException {
    TestNode node = new TestNode();
    node.connect();
    node.ivyBus.bindMsg("(202) FINKEN_ACTUATORS_MODEL (.*)", new IvyMessageListener() {
      @Override
      public void receive(IvyClient _client, String[] _msgVal) {
        for (String msg : _msgVal) {
          System.out.println(msg);
        }
      }
    });
  }

}
