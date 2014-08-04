package xtend.coap.message.resource

import xtend.coap.message.request.PutRequest
import xtend.coap.message.request.PostRequest
import xtend.coap.message.request.DeleteRequest
import xtend.coap.utils.Code

class ReadOnlyResource extends LocalResource {
	
	// Constructors ////////////////////////////////////////////////////////////
	
	new(String resourceIdentifier) {
		super(resourceIdentifier)
	}
	
	@Override
	override void performPut(PutRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void performPost(PostRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void performDelete(DeleteRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void createNew(PutRequest request, String newIdentifier) {
		request.respond(Code.RESP_FORBIDDEN)
	}
}