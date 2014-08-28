package com.xtend.coap.message.response

/** 
 * Interface with the methods of a response handler.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
public interface ResponseHandler {
	/**
	 * Method to handle a response.
	 * 
	 * @param response The response to handle.
	 */
	def void handleResponse(Response response)
}