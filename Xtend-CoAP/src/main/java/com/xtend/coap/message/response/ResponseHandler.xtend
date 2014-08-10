package com.xtend.coap.message.response

public interface ResponseHandler {
	def void handleResponse(Response response)
}