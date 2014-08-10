package com.xtend.coap.message

import com.xtend.coap.message.response.Response
import com.xtend.coap.message.request.Request

interface MessageHandler {
	def void handleRequest(Request request)
	def void handleResponse(Response response)
}