package com.xtend.coap.message.request

import com.xtend.coap.utils.Code

class PostRequest extends Request {
	new() {
		super(Code.METHOD_POST, true)
	}
	
	@Override
	override void dispat(RequestHandler handler) {
		handler.performPost(this)
	}
}