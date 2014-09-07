package com.xtend.coap.resource;

import com.xtend.coap.message.request.DeleteRequest;
import com.xtend.coap.message.request.PostRequest;
import com.xtend.coap.message.request.PutRequest;
import com.xtend.coap.resource.LocalResource;
import com.xtend.coap.utils.Code;

/**
 * Class that represents a Read Only Resource.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
@SuppressWarnings("all")
public class ReadOnlyResource extends LocalResource {
  /**
   * Constructor for a new ReadOnlyResource
   * 
   * @param resourceIdentifier The resource identifier
   */
  public ReadOnlyResource(final String resourceIdentifier) {
    super(resourceIdentifier);
  }
  
  @Override
  public void performPut(final PutRequest request) {
    request.respond(Code.RESP_METHOD_NOT_ALLOWED);
  }
  
  @Override
  public void performPost(final PostRequest request) {
    request.respond(Code.RESP_METHOD_NOT_ALLOWED);
  }
  
  @Override
  public void performDelete(final DeleteRequest request) {
    request.respond(Code.RESP_METHOD_NOT_ALLOWED);
  }
  
  @Override
  public void createNew(final PutRequest request, final String newIdentifier) {
    request.respond(Code.RESP_FORBIDDEN);
  }
}
