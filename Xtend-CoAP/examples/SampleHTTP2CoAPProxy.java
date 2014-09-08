
import com.sun.net.httpserver.HttpServer;
import com.xtend.coap.endpoint.BaseHTTP2CoAPProxy;
import com.xtend.coap.message.MessageSender;
import java.net.InetSocketAddress;
import java.net.SocketException;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleHTTP2CoAPProxy extends BaseHTTP2CoAPProxy {
  public SampleHTTP2CoAPProxy(final int port, final boolean daemon) throws SocketException {
    super(port, daemon);
  }
  
  public static void main(final String[] args) throws Exception {
    try {
      InetSocketAddress _inetSocketAddress = new InetSocketAddress(8000);
      HttpServer server = HttpServer.create(_inetSocketAddress, 0);
      BaseHTTP2CoAPProxy proxy = new SampleHTTP2CoAPProxy((MessageSender.DEFAULT_PORT + 2), false);
      server.createContext("/", proxy);
      server.setExecutor(null);
      server.start();
      System.out.println((("Sample HTTP to CoAP proxy listening at port " + Integer.valueOf(8000)) + "."));
    } catch (final Throwable _t) {
      if (_t instanceof SocketException) {
        final SocketException e = (SocketException)_t;
        String _message = e.getMessage();
        String _plus = ("Failed to create Sample HTTP to CoAP proxy: " + _message);
        System.err.printf(_plus);
        return;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
