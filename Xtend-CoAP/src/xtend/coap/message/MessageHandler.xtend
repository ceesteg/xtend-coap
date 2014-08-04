package xtend.coap.message

import xtend.coap.message.response.Response
import xtend.coap.message.request.Request

interface MessageHandler {
	def void handleRequest(Request request)
	def void handleResponse(Response response)
}