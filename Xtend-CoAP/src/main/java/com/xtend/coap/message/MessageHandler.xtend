package com.xtend.coap.message

import com.xtend.coap.message.response.Response
import com.xtend.coap.message.request.Request

/** 
 * Interface with the methods of a Message Handler.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
interface MessageHandler {
	/**
	 * Method to handle a Request.
	 * 
	 * @param request The request to handle.
	 */
	def void handleRequest(Request request)
	/**
	 * Method to handle a Response.
	 * 
	 * @param request The response to handle.
	 */
	def void handleResponse(Response response)
}