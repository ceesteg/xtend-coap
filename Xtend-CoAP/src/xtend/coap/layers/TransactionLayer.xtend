package xtend.coap.layers

import java.util.Map
import java.util.HashMap
import java.io.IOException

import xtend.coap.message.Message
import xtend.coap.message.response.Response
import xtend.coap.message.request.Request

class TransactionLayer extends UpperLayer {
	
	Map<Integer, Request> tokenMap
	
	new (){
		tokenMap = new HashMap<Integer, Request>
	}

	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg instanceof Request) {
			var request = msg as Request
			request.setToken(request.getToken, request.getTokenLength)
			tokenMap.put(request.getToken, request)
		}
		sendMessageOverLowerLayer(msg)
	}	
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		var token = msg.getToken
		if (msg instanceof Response) {
			var response = msg as Response
			var request = tokenMap.get(token)
			if (request == null) {
				if (response.getBuddy instanceof Request) {
					request = response.getBuddy as Request
				}
			}
			if (response.isConfirmable) {
				try {
					var reply = response.newReply(request != null)
					sendMessageOverLowerLayer(reply)
				} catch (IOException e) {
					System.err.println("[" + getClass.getName + "] ERROR: Failed to reply to confirmable response: ")
					e.printStackTrace
				}
			}
			if (request != null) {
				response.setRequest(request)
			}
		} else if (msg instanceof Request) {
			if (token != 0x0000) {
				tokenMap.put(token, msg as Request)
			}
		}
		deliverMessage(msg)
	}
}