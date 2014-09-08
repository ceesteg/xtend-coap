
import com.google.common.base.Objects;
import com.xtend.coap.message.Message;
import com.xtend.coap.message.MessageSender;
import com.xtend.coap.message.request.Request;
import com.xtend.coap.message.response.Response;
import com.xtend.coap.utils.MessageType;
import com.xtend.coap.utils.Option;
import java.io.IOException;
import java.net.SocketException;
import java.net.URI;
import java.net.URISyntaxException;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleClient2 extends MessageSender {
  public SampleClient2(final int port, final boolean daemon) throws SocketException {
    super(port, daemon);
  }
  
  public static void main(final String[] args) {
    try {
      SampleClient2 client = new SampleClient2((MessageSender.DEFAULT_PORT + 2), true);
      client.startClient(args);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void startClient(final String[] args) {
    try {
      String method = "GET";
      String uri = "http://localhost:8080/AplicacionTemperatura/temperatura";
      String payload = "";
      String proxy_uri = "coap://localhost";
      boolean loop = false;
      boolean _equals = Objects.equal(method, null);
      if (_equals) {
        System.err.println("Method not specified");
        return;
      }
      Request request = Request.newRequest(method);
      boolean _notEquals = (!Objects.equal(proxy_uri, null));
      if (_notEquals) {
        Option _option = new Option(proxy_uri, Option.PROXY_URI);
        request.setOption(_option);
      }
      boolean _equals_1 = Objects.equal(request, null);
      if (_equals_1) {
        System.err.println(("Unknown method: " + method));
        return;
      }
      boolean _equals_2 = Objects.equal(uri, null);
      if (_equals_2) {
        System.err.println("URI not specified");
      }
      try {
        request.setURI(uri);
        URI _uRI = request.getURI();
        String _host = _uRI.getHost();
        Option _option_1 = new Option(_host, Option.URI_HOST);
        request.setOption(_option_1);
        URI _uRI_1 = request.getURI();
        int port = _uRI_1.getPort();
        if ((port == (-1))) {
          port = MessageSender.DEFAULT_PORT;
        }
        Option _option_2 = new Option(port, Option.URI_PORT);
        request.setOption(_option_2);
      } catch (final Throwable _t) {
        if (_t instanceof URISyntaxException) {
          final URISyntaxException e = (URISyntaxException)_t;
          String _message = e.getMessage();
          String _plus = ("Failed to parse URI: " + _message);
          System.err.println(_plus);
          return;
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      int _nextMessageID = MessageSender.nextMessageID("C");
      request.setID(_nextMessageID);
      MessageSender.generateTokenForRequest(request);
      request.setPayload(payload);
      request.enableResponseQueue(true);
      try {
        request.execute();
      } catch (final Throwable _t_1) {
        if (_t_1 instanceof IOException) {
          final IOException e_1 = (IOException)_t_1;
          String _message_1 = e_1.getMessage();
          String _plus_1 = ("Failed to execute request: " + _message_1);
          System.err.println(_plus_1);
          return;
        } else {
          throw Exceptions.sneakyThrow(_t_1);
        }
      }
      boolean _dowhile = false;
      do {
        {
          Response response = null;
          try {
            Response _receiveResponse = request.receiveResponse();
            response = _receiveResponse;
            boolean _and = false;
            boolean _notEquals_1 = (!Objects.equal(response, null));
            if (!_notEquals_1) {
              _and = false;
            } else {
              boolean _isEmptyACK = response.isEmptyACK();
              _and = _isEmptyACK;
            }
            if (_and) {
              System.out.println("Receiving response...");
              response.log();
              System.out.println("Request acknowledged, waiting for separate response...");
              Response _receiveResponse_1 = request.receiveResponse();
              response = _receiveResponse_1;
            }
          } catch (final Throwable _t_2) {
            if (_t_2 instanceof InterruptedException) {
              final InterruptedException e_2 = (InterruptedException)_t_2;
              String _message_2 = e_2.getMessage();
              String _plus_2 = ("Failed to receive response: " + _message_2);
              System.err.println(_plus_2);
              return;
            } else {
              throw Exceptions.sneakyThrow(_t_2);
            }
          }
          boolean _notEquals_2 = (!Objects.equal(response, null));
          if (_notEquals_2) {
            response.log();
            int _rTT = response.getRTT();
            String _plus_3 = ("Round Trip Time (ms): " + Integer.valueOf(_rTT));
            System.out.println(_plus_3);
            MessageType _type = response.getType();
            boolean _equals_3 = Objects.equal(_type, MessageType.CONFIRMABLE);
            if (_equals_3) {
              Message reply = response.newReply(true);
              this.communicator.sendMessage(reply);
            }
          } else {
            long _currentTimeMillis = System.currentTimeMillis();
            long _timestamp = request.getTimestamp();
            long elapsed = (_currentTimeMillis - _timestamp);
            System.out.println(("Request timed out (ms): " + Long.valueOf(elapsed)));
            loop = false;
          }
        }
        _dowhile = loop;
      } while(_dowhile);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
