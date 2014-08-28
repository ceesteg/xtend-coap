package com.xtend.coap.message.response

import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageHandler
import com.xtend.coap.message.request.Request
import com.xtend.coap.utils.Code

/**
 * Class that represents a Response. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class Response extends Message {
	
	private Request request
	
	/**
	 * Initializes a new Response object.
	 */
	new () {
		this(Code.RESP_VALID)
	}
	
	/**
	 * Initializes a new Response object.
	 * 
	 * @param code The code of the response.
	 */
	new (String code) {
		setCode(code)
	}
	
	/**
	 * Sets the request matched to the response.
	 * 
	 * @param request Request to match.
	 */
	def void setRequest(Request request) {
		this.request = request
	}

	/**
	 * Gets the request matched to the response.
	 * 
	 * @return The request matched to the response.
	 */	
	def getRequest() {
		return request
	}
	
	/**
	 * Method to be invoked to respond the request matched with the actual response.
	 */	
	def void respond() {
		if (request != null) {
			request.respond(this)
		}
	}
	
	/**
	 * Gets the round trip time of the response.
	 * 
	 * @return The round trip time as integer value.
	 */	
	def getRTT() {
		if (request != null) {
			return (getTimestamp - request.getTimestamp).intValue
		} else {
			return -1
		}
	}
	
	/**
	 * Method to handle the actual response.
	 */
	def void handle() {
		if (request != null) {
			request.handleResponse(this)
		}
	}
	
	/**
	 * Override method. If request is not null, append the payload to the response.
	 * 
	 * @param data The data to append.
	 */
	override void payloadAppended(byte[] data) {
		if (request != null) {
			request.responsePayloadAppended(this, data) 
		}
	}
	
	/**
	 * Override method. If request is not null, set this response to completed.
	 */
	override void completed() {
		if (request != null) {
			request.responseCompleted(this)
		}
	}
	
	/**
	 * Override method. Defines the message handler that handles this response.
	 * 
	 * @param handler The message handler to handle the response.
	 */
	override void handleBy(MessageHandler handler) {
		handler.handleResponse(this)
	}

	/**
	 * Method to know if a response is piggybacked.
	 * 
	 * @return True if code is not EMPTY_MESSAGE and the response is an acknowledgement.
	 */
	def isPiggyBacked() {
		return isAcknowledgement && getCode != Code.EMPTY_MESSAGE
	}

	/**
	 * Method to know if a response is an acknowledgement empty message.
	 * 
	 * @return True if code is EMPTY_MESSAGE and the response is an acknowledgement.
	 */
	def isEmptyACK() {
		return isAcknowledgement && getCode == Code.EMPTY_MESSAGE
	}
}
