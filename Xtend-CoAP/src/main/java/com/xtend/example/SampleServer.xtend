package com.xtend.example

import java.net.SocketException

import com.xtend.coap.message.resource.ReadOnlyResource
import com.xtend.coap.message.resource.LocalResource
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.message.response.Response
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.Option
import com.xtend.coap.endpoint.BaseServer

class SampleServer extends BaseServer {

	/*
	 * Constructor for a new SampleServer
	 * 
	 */
	new() throws SocketException {
		addResource(new HelloWorldResource)
		addResource(new StorageResource)
		addResource(new ToUpperResource)
		addResource(new SeparateResource)
	}

	// Resource definitions ////////////////////////////////////////////////////
	
	/*
	 * Defines a resource that returns "Hello World!" on a GET request.
	 * 
	 */
	private static class HelloWorldResource extends ReadOnlyResource {
		
		new() {
			super("helloWorld")
			setResourceName("GET a friendly greeting!")
		}
		
		@Override
		override void performGet(GetRequest request) {
			var response = new Response(Code.RESP_CONTENT)
			response.setPayload("Hello World! Some sauts: äöü")
			request.respond(response)
		}
	}
	
	private static class ToUpperResource extends LocalResource {
		
		new() {
			super("toUpper")
			setResourceName("POST text here to convert it to uppercase")
		}
		
		@Override
		override void performPost(PostRequest request) {
			var text = request.getPayloadString
			request.respond(Code.RESP_CONTENT, text.toUpperCase)
		}
	}

	/*
	 * Defines a resource that stores POSTed data and that creates new
	 * sub-resources on PUT request where the Uri-Path doesn't yet point
	 * to an existing resource.
	 * 
	 */	
	private static class StorageResource extends LocalResource {
		
		byte[] data
		Option contentFormat
		boolean isRoot
		
		new(String resourceIdentifier) {
			super(resourceIdentifier)
			setResourceName("POST your data here or PUT new resources!")
		}
		
		new() {
			this("storage")
			isRoot = true
		}
		
		@Override
		override void performGet(GetRequest request) {
			var response = new Response(Code.RESP_CONTENT)
			response.setPayload(data)
			response.setOption(contentFormat)
			request.respond(response)
		}

		@Override
		override void performPost(PostRequest request) {
			storeData(request)
			request.respond(Code.RESP_CHANGED)
		}
		
		@Override
		override void performPut(PutRequest request) {
			storeData(request)
			request.respond(Code.RESP_CHANGED)
		}		
		
		@Override
		override void performDelete(DeleteRequest request) {
			if (!isRoot) {
				remove
				request.respond(Code.RESP_DELETED)
			} else {
				request.respond(Code.RESP_FORBIDDEN)
			}
		}
		
		@Override
		override void createNew(PutRequest request, String newIdentifier) {
			var resource = new StorageResource(newIdentifier)
			addSubResource(resource)
			resource.storeData(request)
			request.respond(Code.RESP_CREATED)
		}
		
		def private void storeData(Request request) {
			data = request.getPayload
			contentFormat = request.getFirstOption(Option.CONTENT_FORMAT)
			changed
		}
	}
	
	/*
	 * Defines a resource that returns "Hello World!" on a GET request.
	 * 
	 */
	private static class SeparateResource extends ReadOnlyResource {
		
		new() {
			super("separate")
			setResourceName("GET a response in a separate CoAP Message")
		}
		
		@Override
		override void performGet(GetRequest request) {
			request.accept
			try {
				Thread.sleep(1000)
			} catch (InterruptedException e) {
				e.printStackTrace
			}
			var response = new Response(Code.RESP_CONTENT)
			response.setID(nextMessageID("S"))
//			generateTokenForRequest(response)
			response.setPayload("This message was sent by a separate response.\n" +
				"Your client will need to acknowledge it, otherwise it will be retransmitted.")
			request.respond(response)
		}
	}

	// Logging /////////////////////////////////////////////////////////////////
	
	@Override
	override void handleRequest(Request request) {
		System.out.println("Incoming request:")
		request.log
		super.handleRequest(request)
	}

	// Application entry point /////////////////////////////////////////////////
	
	def static void main(String[] args) {
		try {
			var BaseServer server = new SampleServer
			System.out.println("SampleServer listening at port " + server.port + ".")
		} catch (SocketException e) {
			System.err.printf("Failed to create SampleServer: " + e.getMessage)
			return
		}
	}
}
