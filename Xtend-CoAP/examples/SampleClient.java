
import com.google.common.base.Objects;
import com.google.common.collect.Lists;
import com.xtend.coap.message.Message;
import com.xtend.coap.message.MessageSender;
import com.xtend.coap.message.request.Request;
import com.xtend.coap.message.response.Response;
import com.xtend.coap.resource.Resource;
import com.xtend.coap.utils.ContentFormat;
import com.xtend.coap.utils.MessageType;
import com.xtend.coap.utils.Option;
import java.io.IOException;
import java.net.SocketException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collections;
import java.util.List;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleClient extends MessageSender {
  public SampleClient(final int port, final boolean daemon) throws SocketException {
    super(port, daemon);
  }
  
  public static void main(final String[] args) {
    try {
      SampleClient client = new SampleClient((MessageSender.DEFAULT_PORT + 1), true);
      client.startClient(args);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void startClient(final String[] args) {
    try {
      Request requestDiscover = Request.newRequest("DISCOVER");
      try {
        requestDiscover.setURI("coap://192.168.1.12/.well-known/core");
        URI _uRI = requestDiscover.getURI();
        String _host = _uRI.getHost();
        Option _option = new Option(_host, Option.URI_HOST);
        requestDiscover.setOption(_option);
        URI _uRI_1 = requestDiscover.getURI();
        int port = _uRI_1.getPort();
        if ((port == (-1))) {
          port = MessageSender.DEFAULT_PORT;
        }
        Option _option_1 = new Option(port, Option.URI_PORT);
        requestDiscover.setOption(_option_1);
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
      int msgID = MessageSender.nextMessageID("C");
      requestDiscover.setID(msgID);
      MessageSender.generateTokenForRequest(requestDiscover);
      requestDiscover.enableResponseQueue(true);
      try {
        requestDiscover.execute();
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
      Response responseDiscover = null;
      try {
        Response _receiveResponse = requestDiscover.receiveResponse();
        responseDiscover = _receiveResponse;
        boolean _and = false;
        boolean _notEquals = (!Objects.equal(responseDiscover, null));
        if (!_notEquals) {
          _and = false;
        } else {
          boolean _isEmptyACK = responseDiscover.isEmptyACK();
          _and = _isEmptyACK;
        }
        if (_and) {
          System.out.println("Receiving response...");
          responseDiscover.log();
          System.out.println("Request acknowledged, waiting for separate response...");
          Response _receiveResponse_1 = requestDiscover.receiveResponse();
          responseDiscover = _receiveResponse_1;
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
      boolean respDiscNull = (!Objects.equal(responseDiscover, null));
      if (respDiscNull) {
        responseDiscover.log();
        int _rTT = responseDiscover.getRTT();
        String _plus_3 = ("Round Trip Time (ms): " + Integer.valueOf(_rTT));
        String _plus_4 = (_plus_3 + "\r\n");
        System.out.println(_plus_4);
        MessageType _type = responseDiscover.getType();
        boolean _equals = Objects.equal(_type, MessageType.CONFIRMABLE);
        if (_equals) {
          Message reply = responseDiscover.newReply(true);
          this.communicator.sendMessage(reply);
        }
        boolean _hasFormat = responseDiscover.hasFormat(ContentFormat.LINK_FORMAT);
        if (_hasFormat) {
          String linkFormat = responseDiscover.getPayloadString();
          Resource root = Resource.newRoot(linkFormat);
          boolean _notEquals_1 = (!Objects.equal(root, null));
          if (_notEquals_1) {
            System.out.println("\nDiscovered resources:");
            root.log();
            System.out.println("\r\n");
          } else {
            System.err.println("Failed to parse link format");
          }
        } else {
          System.err.println("ERROR. Server error: Link format not specified");
        }
      } else {
        long _currentTimeMillis = System.currentTimeMillis();
        long _timestamp = requestDiscover.getTimestamp();
        long elapsed = (_currentTimeMillis - _timestamp);
        System.out.println((("Request timed out (ms): " + Long.valueOf(elapsed)) + "\r\n"));
      }
      List<String> methods = Collections.<String>unmodifiableList(Lists.<String>newArrayList("GET", "POST", "GET", "PUT", "GET", "DELETE", "GET"));
      String uri = "coap://192.168.1.12/store";
      List<String> payloads = Collections.<String>unmodifiableList(Lists.<String>newArrayList((String)null, "4", (String)null, "5", (String)null, (String)null, (String)null));
      for (int i = 0; (i < ((Object[])Conversions.unwrapArray(methods, Object.class)).length); i++) {
        {
          String _get = methods.get(i);
          Request request = Request.newRequest(((String) _get));
          try {
            request.setURI(uri);
            URI _uRI = request.getURI();
            String _host = _uRI.getHost();
            Option _option = new Option(_host, Option.URI_HOST);
            request.setOption(_option);
            URI _uRI_1 = request.getURI();
            int port = _uRI_1.getPort();
            if ((port == (-1))) {
              port = MessageSender.DEFAULT_PORT;
            }
            Option _option_1 = new Option(port, Option.URI_PORT);
            request.setOption(_option_1);
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
          msgID = _nextMessageID;
          request.setID(msgID);
          MessageSender.generateTokenForRequest(request);
          String _get_1 = payloads.get(i);
          request.setPayload(((String) _get_1));
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
              String _message_2 = e_2.getMessage();
              String _plus_2 = ("Failed to receive response: " + _message_2);
              System.err.println(_plus_2);
              return;
            } else {
              throw Exceptions.sneakyThrow(_t_2);
            }
          }
          boolean _notEquals_1 = (!Objects.equal(response, null));
          if (_notEquals_1) {
            response.log();
            int _rTT = response.getRTT();
            String _plus_3 = ("Round Trip Time (ms): " + Integer.valueOf(_rTT));
            String _plus_4 = (_plus_3 + "\r\n");
            System.out.println(_plus_4);
            MessageType _type = response.getType();
            boolean _equals = Objects.equal(_type, MessageType.CONFIRMABLE);
            if (_equals) {
              Message reply = response.newReply(true);
              this.communicator.sendMessage(reply);
            }
          } else {
            long _currentTimeMillis = System.currentTimeMillis();
            long _timestamp = request.getTimestamp();
            long elapsed = (_currentTimeMillis - _timestamp);
            System.out.println((("Request timed out (ms): " + Long.valueOf(elapsed)) + "\r\n"));
          }
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
