package xtend.coap.endpoint

import java.util.Random
import xtend.coap.message.request.Request
import xtend.coap.message.Message

class Endpoint {
	
	static int messageID = 0

	def static int nextMessageID(String typeEndpoint) {
		if (messageID == 0) {
			resetValue(typeEndpoint)
		}
		var id = messageID
		messageID++
		if (messageID > Message.MAX_ID) {
			resetValue(typeEndpoint)
		}
		return id
	}
	
	def private static void resetValue(String typeEndpoint) {
		switch (typeEndpoint) {
			case ("S"):
				messageID = 0x1001
			case ("C"):
				messageID = 0x2001
			default:
				messageID = 0x2001
		}
	}
	
	def static void generateTokenForRequest(Request request) {
		var random = new Random
		var length = 4
		var int token = 0
		for (var i = 0; i < length * 8; i++) {
			var rndDigit = random.nextInt(2)
			token = token + rndDigit * Math.pow(2, i).intValue
		}
		request.setToken(token, length)
	}
}