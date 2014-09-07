package com.xtend.coap.resource;

import com.google.common.base.Objects;
import com.xtend.coap.message.request.DeleteRequest;
import com.xtend.coap.message.request.GetRequest;
import com.xtend.coap.message.request.PostRequest;
import com.xtend.coap.message.request.PutRequest;
import com.xtend.coap.resource.Resource;
import com.xtend.coap.utils.Code;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * Class that represents a Local Resource.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
@SuppressWarnings("all")
public class LocalResource extends Resource {
  private Map<String, GetRequest> observeRequests;
  
  public LocalResource(final String resourceIdentifier, final boolean hidden) {
    super(resourceIdentifier, hidden);
  }
  
  public LocalResource(final String resourceIdentifier) {
    super(resourceIdentifier, false);
  }
  
  public void addObserveRequest(final GetRequest request) {
    boolean _notEquals = (!Objects.equal(request, null));
    if (_notEquals) {
      boolean _equals = Objects.equal(this.observeRequests, null);
      if (_equals) {
        HashMap<String, GetRequest> _hashMap = new HashMap<String, GetRequest>();
        this.observeRequests = _hashMap;
      }
      String _endpointID = request.endpointID();
      this.observeRequests.put(_endpointID, request);
      String _endpointID_1 = request.endpointID();
      String _plus = ("Observation relationship between " + _endpointID_1);
      String _plus_1 = (_plus + " and ");
      String _resourceIdentifier = this.getResourceIdentifier();
      String _plus_2 = (_plus_1 + _resourceIdentifier);
      String _plus_3 = (_plus_2 + " established.");
      System.out.println(_plus_3);
    }
  }
  
  public void removeObserveRequest(final String endpointID) {
    boolean _notEquals = (!Objects.equal(this.observeRequests, null));
    if (_notEquals) {
      GetRequest _remove = this.observeRequests.remove(endpointID);
      boolean _notEquals_1 = (!Objects.equal(_remove, null));
      if (_notEquals_1) {
        String _resourceIdentifier = this.getResourceIdentifier();
        String _plus = ((("Observation relationship between " + endpointID) + " and ") + _resourceIdentifier);
        String _plus_1 = (_plus + " terminated.");
        System.out.println(_plus_1);
      }
    }
  }
  
  public boolean isObserved(final String endpointID) {
    boolean _and = false;
    boolean _notEquals = (!Objects.equal(this.observeRequests, null));
    if (!_notEquals) {
      _and = false;
    } else {
      boolean _containsKey = this.observeRequests.containsKey(endpointID);
      _and = _containsKey;
    }
    return _and;
  }
  
  protected void processObserveRequests() {
    boolean _notEquals = (!Objects.equal(this.observeRequests, null));
    if (_notEquals) {
      Collection<GetRequest> _values = this.observeRequests.values();
      for (final GetRequest request : _values) {
        this.performGet(request);
      }
    }
  }
  
  protected void changed() {
    this.processObserveRequests();
  }
  
  @Override
  public void performGet(final GetRequest request) {
    request.respond(Code.RESP_NOT_IMPLEMENTED);
  }
  
  @Override
  public void performPut(final PutRequest request) {
    request.respond(Code.RESP_NOT_IMPLEMENTED);
  }
  
  @Override
  public void performPost(final PostRequest request) {
    request.respond(Code.RESP_NOT_IMPLEMENTED);
  }
  
  @Override
  public void performDelete(final DeleteRequest request) {
    request.respond(Code.RESP_NOT_IMPLEMENTED);
  }
  
  @Override
  public void createNew(final PutRequest request, final String newIdentifier) {
    request.respond(Code.RESP_NOT_IMPLEMENTED);
  }
}
