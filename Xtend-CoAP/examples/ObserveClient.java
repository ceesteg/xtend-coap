
import com.google.common.base.Objects;
import com.xtend.coap.layers.Communicator;
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
import java.util.ArrayList;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class ObserveClient extends MessageSender {
  public static class ObservePetition implements Runnable {
    private ObserveClient client;
    
    private String method;
    
    private String uri;
    
    private boolean terminate;
    
    public ObservePetition(final ObserveClient client, final String method, final String uri) {
      this.client = client;
      this.method = method;
      this.uri = uri;
      this.terminate = true;
    }
    
    public void setTerminate() {
      this.terminate = true;
    }
    
    public void run() {
      try {
        Request request = Request.newRequest(this.method);
        boolean _equals = Objects.equal(request, null);
        if (_equals) {
          System.err.println(("Unknown method: " + this.method));
          return;
        }
        boolean _contains = this.client.obs.contains(this.uri);
        if (_contains) {
          this.client.obs.remove(this.uri);
          System.out.println((("Ending observation relationship with " + this.uri) + "..."));
          Option _option = new Option(1, Option.OBSERVE);
          request.setOption(_option);
          request.setType(MessageType.NON_CONFIRMABLE);
        } else {
          this.client.obs.add(this.uri);
          System.out.println((("Establishing observation relationship with " + this.uri) + "..."));
          Option _option_1 = new Option(0, Option.OBSERVE);
          request.setOption(_option_1);
          this.terminate = false;
        }
        try {
          request.setURI(this.uri);
          URI _uRI = request.getURI();
          String _host = _uRI.getHost();
          Option _option_2 = new Option(_host, Option.URI_HOST);
          request.setOption(_option_2);
          URI _uRI_1 = request.getURI();
          int port = _uRI_1.getPort();
          if ((port == (-1))) {
            port = MessageSender.DEFAULT_PORT;
          }
          Option _option_3 = new Option(port, Option.URI_PORT);
          request.setOption(_option_3);
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
            if (this.terminate) {
              return;
            }
            Response response = null;
            try {
              Response _receiveResponse = request.receiveResponse();
              response = _receiveResponse;
              boolean _and = false;
              boolean _notEquals = (!Objects.equal(response, null));
              if (!_notEquals) {
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
                return;
              } else {
                throw Exceptions.sneakyThrow(_t_2);
              }
            }
            boolean _notEquals_1 = (!Objects.equal(response, null));
            if (_notEquals_1) {
              response.log();
              int _rTT = response.getRTT();
              String _plus_2 = ("Round Trip Time (ms): " + Integer.valueOf(_rTT));
              System.out.println(_plus_2);
              MessageType _type = response.getType();
              boolean _equals_1 = Objects.equal(_type, MessageType.CONFIRMABLE);
              if (_equals_1) {
                Message reply = response.newReply(true);
                Communicator _communicator = this.client.getCommunicator();
                _communicator.sendMessage(reply);
              }
            } else {
              long _currentTimeMillis = System.currentTimeMillis();
              long _timestamp = request.getTimestamp();
              long elapsed = (_currentTimeMillis - _timestamp);
              System.out.println(("Request timed out (ms): " + Long.valueOf(elapsed)));
              this.terminate = true;
            }
          }
          _dowhile = (!this.terminate);
        } while(_dowhile);
      } catch (Throwable _e) {
        throw Exceptions.sneakyThrow(_e);
      }
    }
  }
  
  private final List<String> obs = new ArrayList<String>();
  
  public ObserveClient(final int port, final boolean daemon) throws SocketException {
    super(port, daemon);
  }
  
  public static void main(final String[] args) {
    try {
      String method = "OBSERVE";
      String uri = "coap://192.168.1.12/store";
      ObserveClient client = new ObserveClient(MessageSender.DEFAULT_PORT + 2, true);
      ObserveClient.ObservePetition p = new ObserveClient.ObservePetition(client, method, uri);
      Thread t = new Thread(p);
      t.start();
      try {
        Thread.sleep(20000);
      } catch (final Throwable _t) {
        if (_t instanceof Exception) {
          final Exception e = (Exception)_t;
          System.out.println("ERROR");
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
      Thread t1 = new Thread(p);
      t1.start();
      t.interrupt();
      t1.interrupt();
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
