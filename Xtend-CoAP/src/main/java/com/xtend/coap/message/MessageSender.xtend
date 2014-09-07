package com.xtend.coap.message

import java.util.Random

import com.xtend.coap.message.request.Request
import com.xtend.coap.layers.Communicator
import java.net.SocketException

/** 
 * Class that represents a Message Sender.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class MessageSender {
	
	static int messageID = 0
	val public static DEFAULT_PORT = Communicator.DEFAULT_PORT
	
	protected Communicator communicator
	
	new (int port, boolean daemon) throws SocketException {
		this.communicator = new Communicator(port, daemon)
	}
	
	def getCommunicator() {
		return this.communicator
	}
	
	/** 
	 * This method gets the ID for a new message.
	 * 
	 * @param typeEndpoint The type of End Point. It must be C for Client, S for Server and P for Proxy.
	 * 
	 * @return The ID for a new message.
	 */
	def static int nextMessageID(String typeEndpoint) {
		if (messageID == 0) {
			resetMessageID(typeEndpoint)
		}
		var id = messageID
		messageID++
		if (messageID > Message.MAX_ID) {
			resetMessageID(typeEndpoint)
		}
		return id
	}
	
	def private static void resetMessageID(String typeEndpoint) {
		switch (typeEndpoint) {
			case ("C"):
				messageID = 0x1001
			case ("S"):
				messageID = 0x2001	
			case ("P"):
				messageID = 0x3001
			default:
				messageID = 0x4001
		}
	}
	
	/** 
	 * This method generates a new Token.
	 * 
	 * @param length The length of the Token.
	 * 
	 * @return The Token generated.
	 */
	def static long generateToken(int length) {
		var random = new Random
		var long token = 0
		for (var i = 0; i < length * 8; i++) {
			var rndDigit =  random.nextInt(2)
			token += rndDigit * Math.pow(2, i).longValue
		}
		return token
	}
	
	/** 
	 * This method generates a new Token for a Request.
	 * 
	 * @param request The request that takes the Token.
	 */
	def static void generateTokenForRequest(Request request) {
		var random = new Random
		var length = random.nextInt(3) + 5
		var token = generateToken(length)
		request.setToken(token, length)
	}
}