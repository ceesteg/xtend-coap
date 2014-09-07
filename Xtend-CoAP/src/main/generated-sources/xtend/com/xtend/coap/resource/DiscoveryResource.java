package com.xtend.coap.resource;

import com.xtend.coap.message.request.GetRequest;
import com.xtend.coap.message.response.Response;
import com.xtend.coap.resource.ReadOnlyResource;
import com.xtend.coap.resource.Resource;
import com.xtend.coap.utils.Code;
import com.xtend.coap.utils.ContentFormat;

/**
 * Class that represents a Discovery Resource.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
@SuppressWarnings("all")
public class DiscoveryResource extends ReadOnlyResource {
  public final static String DEFAULT_IDENTIFIER = "core";
  
  private Resource root;
  
  /**
   * Constructor for a new DiscoveryResource
   * 
   * @param root The root resource for the discovery
   */
  public DiscoveryResource(final Resource root) {
    super(DiscoveryResource.DEFAULT_IDENTIFIER);
    this.root = root;
    this.setContentTypeCode(ContentFormat.LINK_FORMAT);
  }
  
  @Override
  public void performGet(final GetRequest request) {
    Response response = new Response(Code.RESP_CONTENT);
    String _linkFormat = this.root.toLinkFormat();
    int _contentTypeCode = this.getContentTypeCode();
    response.setPayload(_linkFormat, _contentTypeCode);
    request.respond(response);
  }
}
