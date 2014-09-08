
import com.xtend.coap.endpoint.BaseCoAP2HTTPProxy;
import com.xtend.coap.message.MessageSender;
import java.net.SocketException;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleCoAP2HTTPProxy extends BaseCoAP2HTTPProxy {
  public SampleCoAP2HTTPProxy(final int port, final boolean daemon) throws SocketException {
    super(port, daemon);
  }
  
  public static void main(final String[] args) {
    try {
      BaseCoAP2HTTPProxy proxy = new SampleCoAP2HTTPProxy(MessageSender.DEFAULT_PORT, false);
      int _port = proxy.port();
      String _plus = ("Sample CoAP to HTTP proxy listening at port " + Integer.valueOf(_port));
      String _plus_1 = (_plus + ".");
      System.out.println(_plus_1);
    } catch (final Throwable _t) {
      if (_t instanceof SocketException) {
        final SocketException e = (SocketException)_t;
        String _message = e.getMessage();
        String _plus_2 = ("Failed to create Sample CoAP to HTTP proxy: " + _message);
        System.err.printf(_plus_2);
        return;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
