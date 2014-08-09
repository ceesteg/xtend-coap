package xtend.coap.message.response

import xtend.coap.message.MessageHandler
import xtend.coap.message.Message
import xtend.coap.message.request.Request
import xtend.coap.utils.Code

class Response extends Message {
	
	private Request request
	
	new() {
		this(Code.RESP_VALID)
	}
	
	new(String code) {
		setCode(code)
	}
	
	def void setRequest(Request request) {
		this.request = request
	}
	
	def getRequest() {
		return request
	}
	
	def void respond() {
		if (request != null) {
			request.respond(this)
		}
	}
	
	def getRTT() {
		if (request != null) {
			return (getTimestamp - request.getTimestamp).intValue
		} else {
			return -1
		}
	}
	
	def void handle() {
		if (request != null) {
			request.handleResponse(this)
		}
	}
	
	@Override
	override void payloadAppended(byte[] block) {
		if (request != null) {
			request.responsePayloadAppended(this, block) 
		}
	}
	
	@Override
	override void completed() {
		if (request != null) {
			request.responseCompleted(this)
		}
	}
	
	@Override
	override void handleBy(MessageHandler handler) {
		handler.handleResponse(this)
	}
	
	def isPiggyBacked() {
		return isAcknowledgement && getCode != Code.EMPTY_MESSAGE
	}

	def isEmptyACK() {
		return isAcknowledgement && getCode == Code.EMPTY_MESSAGE
	}
}
