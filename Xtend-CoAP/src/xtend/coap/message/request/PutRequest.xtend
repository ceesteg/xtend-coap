package xtend.coap.message.request

import xtend.coap.utils.Code

class PutRequest extends Request {
	new() {
		super(Code.METHOD_PUT, true)
	}
	
	@Override
	override void dispat(RequestHandler handler) {
		handler.performPut(this)
	}
}