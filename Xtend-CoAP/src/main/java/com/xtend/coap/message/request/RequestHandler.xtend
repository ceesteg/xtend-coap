package com.xtend.coap.message.request

/** 
 * Interface with the methods of a Request Handler.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
interface RequestHandler {
	/**
	 * Method to perform a Get request.
	 * 
	 * @param request The request to perform.
	 */
	def void performGet(GetRequest request)
	/**
	 * Method to perform a Post request.
	 * 
	 * @param request The request to perform.
	 */
	def void performPost(PostRequest request)
	/**
	 * Method to perform a Put request.
	 * 
	 * @param request The request to perform.
	 */
	def void performPut(PutRequest request)
	/**
	 * Method to perform a Delete request.
	 * 
	 * @param request The request to perform.
	 */
	def void performDelete(DeleteRequest request)
}