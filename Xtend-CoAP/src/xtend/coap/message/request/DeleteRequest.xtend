package xtend.coap.message.request

import xtend.coap.utils.Code

class DeleteRequest extends Request {
	new() {
		super(Code.METHOD_DELETE, true)
	}
	
	@Override
	override void dispat(RequestHandler handler) {
		handler.performDelete(this)
	}	
}