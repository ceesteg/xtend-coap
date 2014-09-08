
import com.google.common.base.Objects;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.RequestLine;
import org.apache.http.StatusLine;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class SampleHttpClient {
  public static void main(final String[] args) {
    try {
      CloseableHttpClient httpclient = HttpClients.createDefault();
      try {
        HttpHost target = new HttpHost("localhost", 5683, "coap");
        HttpHost proxy = new HttpHost("localhost", 8000, "http");
        RequestConfig.Builder _custom = RequestConfig.custom();
        RequestConfig.Builder _setProxy = _custom.setProxy(proxy);
        RequestConfig config = _setProxy.build();
        HttpDelete request = new HttpDelete("/store");
        request.setConfig(config);
        RequestLine _requestLine = request.getRequestLine();
        String _plus = ("Executing request " + _requestLine);
        String _plus_1 = (_plus + " to ");
        String _plus_2 = (_plus_1 + target);
        String _plus_3 = (_plus_2 + " via ");
        String _plus_4 = (_plus_3 + proxy);
        System.out.println(_plus_4);
        CloseableHttpResponse response = httpclient.execute(target, request);
        try {
          System.out.println("----------------------------------------");
          StatusLine _statusLine = response.getStatusLine();
          System.out.println(_statusLine);
          HttpEntity _entity = response.getEntity();
          boolean _notEquals = (!Objects.equal(_entity, null));
          if (_notEquals) {
            HttpEntity _entity_1 = response.getEntity();
            String _string = EntityUtils.toString(_entity_1);
            System.out.println(_string);
          }
          HttpEntity _entity_2 = response.getEntity();
          EntityUtils.consume(_entity_2);
        } finally {
          response.close();
        }
      } finally {
        httpclient.close();
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
