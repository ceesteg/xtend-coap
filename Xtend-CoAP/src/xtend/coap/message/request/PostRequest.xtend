package xtend.coap.message.request

import xtend.coap.utils.Code

class PostRequest extends Request {
	new() {
		super(Code.METHOD_POST, true)
	}
	
	@Override
	override void dispat(RequestHandler handler) {
		handler.performPost(this)
	}
}