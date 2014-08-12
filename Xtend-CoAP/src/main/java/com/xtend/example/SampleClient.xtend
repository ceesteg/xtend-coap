package com.xtend.example

import java.net.URISyntaxException
import java.io.IOException

import com.xtend.coap.message.response.Response
import com.xtend.coap.message.resource.Resource
import com.xtend.coap.message.request.Request
import com.xtend.coap.utils.ContentFormat
import com.xtend.coap.utils.MessageType
import com.xtend.coap.layers.Communicator
import com.xtend.coap.utils.Option
import com.xtend.coap.message.MessageSender

class SampleClient extends MessageSender {
	
	val static DISCOVERY_RESOURCE = "/.well-known/core"
	val static IDX_METHOD  = 0
	val static IDX_URI     = 1
	val static IDX_PAYLOAD = 2
	
	/*
	 * Main method of this client.
	 */
	def static void main(String[] args) {

		// initialize parameters
//		var String method  = null
//		var String uri     = null
//		var String payload = null
//		var loop   = false
		
		// parametros de prueba 1
//		var String method  = "OBSERVE"
//		var String uri     = "coap://localhost"
//		var String payload = null
//		var loop   = false
		// parametros de prueba 2
//		var method  = "GET"
//		var uri     = "coap://localhost/sayHello"
//		var payload = "César" // ""
//		var loop   = false
		// parametros de prueba 3
//		var String method  = "GET"
//		var String uri     = "coap://localhost/toUpper"
//		var String payload = "ponlo en mayusculas"
//		var loop   = false
		// parametros de prueba 4
		var String method  = "PUT"
		var String uri     = "coap://localhost/storage"
		var String payload = "data 2"
		var loop   = false
		// parametros de prueba 5
//		var String method  = "OBSERVE"
//		var String uri     = "coap://localhost/storage"
//		var String payload = null
//		var loop   = true
        // parametros de prueba 6
//		var String method  = "GET"
//		var String uri     = "coap://localhost/separate"
//		var String payload = null
//		var loop   = false
		// parametros de prueba 7
//		var String method  = "DISCOVER"
//		var String uri     = "coap://localhost"
//		var String payload = null
//		var loop   = false
		// parametros de prueba 8
//		var String method  = "GET"
//		var String uri     = "coap://localhost/level1"
//		var String payload = null
//		var loop   = false
		// parametros de prueba 8
//		var String method  = "GET"
//		var String uri     = "coap://localhost/level1/level2"
//		var String payload = null
//		var loop   = false

		if (args.length == 0) {
			printInfo
		}

		var idx = 0
		var i = 0
		var break = false
		while (i <args.length && !break) {
			if (args.get(i).startsWith("-")) {
				if (args.get(i).equals("-l")) {
					loop = true
				} else {
					System.out.println("Unrecognized option: " + args.get(i))
				}
			} else {
				switch (idx) {
				case IDX_METHOD:{
					method = args.get(i).toUpperCase
					break = true
				}
				case IDX_URI:{
					uri = args.get(i)
					break = true	
				}
				case IDX_PAYLOAD: {
					payload = args.get(i)
					break = true
				}
				default:
					System.out.println("Unexpected argument: " + args.get(i))
				}
				idx++
			}
			i++
		}
		if (method == null) {
			System.err.println("Method not specified")
			return
		}
		var request = Request.newRequest(method)
		if (request == null) {
			System.err.println("Unknown method: " + method)
			return
		}
		
		if (method.equals("OBSERVE")) {
			request.setOption(new Option(0, Option.OBSERVE))
		}
		
		if (uri == null) {
			System.err.println("URI not specified")
		}
		if (method.equals("DISCOVER") && !uri.endsWith(DISCOVERY_RESOURCE)) {
			uri = uri + DISCOVERY_RESOURCE
		}
		try {
			request.setURI(uri)
		} catch (URISyntaxException e) {
			System.err.println("Failed to parse URI: " + e.getMessage)
			return
		}
		request.setID(nextMessageID("C"))
		generateTokenForRequest(request)
		request.setPayload(payload)
		request.enableResponseQueue(true)
		try {
			request.execute
		} catch (IOException e) {
			System.err.println("Failed to execute request: " + e.getMessage)
			return
		}
		
		var Communicator com = null
		var obsCont = 0
		do {
			var Response response = null
			try {
				response = request.receiveResponse
				if (response != null && response.isEmptyACK) {
					System.out.println("Receiving response...")
					response.log
					System.out.println("Request acknowledged, waiting for separate response...")
					response = request.receiveResponse
				}
			} catch (InterruptedException e) {
				System.err.println("Failed to receive response: " + e.getMessage)
				return
			}

			if (response != null) {
				response.log
				System.out.println("Round Trip Time (ms): " + response.getRTT)
				if (response.getType == MessageType.CONFIRMABLE) {
					var reply = response.newReply(true)
					if(com == null) {
						com = new Communicator(Communicator.DEFAULT_PORT+1, true)
					}
					com.sendMessage(reply)
				}
				if (response.hasFormat(ContentFormat.LINK_FORMAT)) {
					var linkFormat = response.getPayloadString
					var Resource root = Resource.newRoot(linkFormat)
					if (root != null) {
						System.out.println("\nDiscovered resources:")
						root.log
					} else {
						System.err.println("Failed to parse link format")
					}
				} else {
					if (method.equals("DISCOVER")) {
						System.err.println("ERROR. Server error: Link format not specified")
					}
				}
			} else {
				var elapsed = System.currentTimeMillis - request.getTimestamp
				System.out.println("Request timed out (ms): " + elapsed)
				loop = false
			}
			if (request.hasOption(Option.OBSERVE)) {
				if (obsCont > 1) {
					System.out.println("Out observe...")
					var request1 = Request.newRequest(method)
					try {
						request1.setURI(uri)
					} catch (URISyntaxException e) {
						System.err.println("Failed to parse URI: " + e.getMessage)
						return
					}
					request1.setOption(new Option(1, Option.OBSERVE))
					request1.setID(nextMessageID("C"))
					generateTokenForRequest(request1)
					request1.enableResponseQueue(true)
					request1.setType(MessageType.NON_CONFIRMABLE)
					loop = false
					try {
						request1.execute
					} catch (IOException e) {
						System.err.println("Failed to execute request: " + e.getMessage)
						return
					}
				}
				obsCont++
			}
		} while (loop)
	}
	
	/*
	 * Outputs user guide of this program.
	 * 
	 */
	def static void printInfo() {
		System.out.println("CPrueba de cliente\n")
		System.out.println("Usage: SampleClient [-l] METHOD URI [PAYLOAD]")
		System.out.println("  METHOD  : {GET, POST, PUT, DELETE, DISCOVER, OBSERVE}")
		System.out.println("  URI     : The URI to the remote endpoint or resource")
		System.out.println("  PAYLOAD : The data to send with the request")
		System.out.println("Options:")
		System.out.println("  -l      : Wait for multiple responses\n")
		System.out.println("Examples:")
		System.out.println("  SampleClient DISCOVER coap://localhost")
		System.out.println("  SampleClient POST coap://someServer.org:61616 my data")
	}
}
