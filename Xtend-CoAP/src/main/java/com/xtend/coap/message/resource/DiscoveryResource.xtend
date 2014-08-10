package com.xtend.coap.message.resource

import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.response.Response
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.ContentFormat

class DiscoveryResource extends ReadOnlyResource {
	
	val public static String DEFAULT_IDENTIFIER = "core"
	
	Resource root
	
	/*
	 * Constructor for a new DiscoveryResource
	 * 
	 * @param resources The resources used for the discovery
	 */
	new (Resource root) {
		super(DEFAULT_IDENTIFIER)
		this.root = root
		setContentTypeCode(ContentFormat.LINK_FORMAT)
	}
	
	@Override
	override void performGet(GetRequest request) {
		var response = new Response(Code.RESP_CONTENT)
		response.setPayload(root.toLinkFormat, getContentTypeCode)
		request.respond(response)
	}
}
