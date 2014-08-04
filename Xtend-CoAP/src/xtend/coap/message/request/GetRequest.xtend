package xtend.coap.message.request

import xtend.coap.utils.Code

class GetRequest extends Request {
	new() {
		super(Code.METHOD_GET, true)
	}
	
	@Override
	override void dispat(RequestHandler handler) {
		handler.performGet(this)
	}
}