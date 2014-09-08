
import com.google.common.base.Objects;
import com.xtend.coap.endpoint.BaseCoAPServer;
import com.xtend.coap.message.request.DeleteRequest;
import com.xtend.coap.message.request.GetRequest;
import com.xtend.coap.message.request.PostRequest;
import com.xtend.coap.message.request.PutRequest;
import com.xtend.coap.message.request.Request;
import com.xtend.coap.message.response.Response;
import com.xtend.coap.resource.LocalResource;
import com.xtend.coap.utils.Code;
import com.xtend.coap.utils.Option;
import java.net.SocketException;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleServer extends BaseCoAPServer {
  private static class StoreResource extends LocalResource {
    private byte[] data;
    
    private Option contentFormat;
    
    private boolean isRoot;
    
    public StoreResource(final String resourceIdentifier) {
      super(resourceIdentifier);
      this.setResourceName("Resource for storage");
    }
    
    public StoreResource() {
      this("store");
      this.isRoot = false;
    }
    
    @Override
    public void performGet(final GetRequest request) {
      Response response = new Response(Code.RESP_CONTENT);
      response.setPayload(this.data);
      response.setOption(this.contentFormat);
      request.respond(response);
    }
    
    @Override
    public void performPost(final PostRequest request) {
      String code = Code.RESP_CHANGED;
      boolean _equals = Objects.equal(this.data, null);
      if (_equals) {
        code = Code.RESP_CREATED;
      }
      this.storeData(request);
      request.respond(code);
    }
    
    @Override
    public void performPut(final PutRequest request) {
      String code = Code.RESP_CHANGED;
      boolean _equals = Objects.equal(this.data, null);
      if (_equals) {
        code = Code.RESP_CREATED;
      }
      this.storeData(request);
      request.respond(code);
    }
    
    @Override
    public void performDelete(final DeleteRequest request) {
      if ((!this.isRoot)) {
        this.remove();
        request.respond(Code.RESP_DELETED);
      } else {
        request.respond(Code.RESP_FORBIDDEN);
      }
    }
    
    public void storeData(final Request request) {
      byte[] _payload = request.getPayload();
      this.data = _payload;
      Option _firstOption = request.getFirstOption(Option.CONTENT_FORMAT);
      this.contentFormat = _firstOption;
      this.changed();
    }
  }
  
  public SampleServer() throws SocketException {
	SampleServer.StoreResource _storeResource = new SampleServer.StoreResource();
    this.addResource(_storeResource);
  }
  
  public static void main(final String[] args) {
    try {
      BaseCoAPServer server = new SampleServer();
      int _port = server.port();
      String _plus = ("SampleServer listening at port " + Integer.valueOf(_port));
      String _plus_1 = (_plus + ".\r\n");
      System.out.println(_plus_1);
    } catch (final Throwable _t) {
      if (_t instanceof SocketException) {
        final SocketException e = (SocketException)_t;
        String _message = e.getMessage();
        String _plus_2 = ("Failed to create SampleServer: " + _message);
        System.err.println(_plus_2);
        return;
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
