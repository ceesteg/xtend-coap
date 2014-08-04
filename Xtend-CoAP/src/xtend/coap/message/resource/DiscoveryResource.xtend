package xtend.coap.message.resource

import xtend.coap.utils.MediaType
import xtend.coap.message.request.GetRequest
import xtend.coap.message.response.Response
import xtend.coap.utils.Code

class DiscoveryResource extends ReadOnlyResource {
	
	val public static String DEFAULT_IDENTIFIER = "core"
	
	Resource root
	
	/*
	 * Constructor for a new DiscoveryResource
	 * 
	 * @param resources The resources used for the discovery
	 */
	new(Resource root) {
		super(DEFAULT_IDENTIFIER)
		this.root = root
		setContentTypeCode(MediaType.LINK_FORMAT)
	}
	
	@Override
	override void performGet(GetRequest request) {
		var response = new Response(Code.RESP_CONTENT)
		response.setPayload(root.toLinkFormat, getContentTypeCode)
		request.respond(response)
	}
}
