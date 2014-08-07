package xtend.coap.layers

import java.util.Map
import java.util.HashMap
import java.io.IOException

import xtend.coap.message.Message
import xtend.coap.message.response.Response
import xtend.coap.message.request.Request
import xtend.coap.utils.Option

class TransactionLayer extends UpperLayer {
	
	Map<Integer, Request> tokenMap = new HashMap<Integer, Request>
	int currentToken
	
	new (){
		this.currentToken = 0xCAFE
	}

	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg instanceof Request) {
			var request = msg as Request
			if (request.getFirstOption(Option.TOKEN) == null) {
				request.setOption(new Option(currentToken, Option.TOKEN))
			}
			tokenMap.put(currentToken, request)
			currentToken++
		}
		sendMessageOverLowerLayer(msg)
	}	
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		var tokenOpt = msg.getFirstOption(Option.TOKEN)
		if (msg instanceof Response) {
			var response = msg as Response
			var Request request = null
			if (tokenOpt != null) {
				var token = tokenOpt.getIntValue
				request = tokenMap.get(token)
			} else {
				System.out.println("[" + getClass.getName + "] WARNING: Token missing for matching response to request")
				if (response.getBuddy instanceof Request) {
					request = response.getBuddy as Request
					System.out.println("[" + getClass.getName + "] Falling back to buddy matching for " + response.key)
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
			if (tokenOpt != null) {
				tokenMap.put(tokenOpt.getIntValue, msg as Request)
			}
		}
		deliverMessage(msg)
	}
}