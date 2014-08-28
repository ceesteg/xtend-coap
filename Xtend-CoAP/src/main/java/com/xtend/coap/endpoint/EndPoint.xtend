package com.xtend.coap.endpoint

import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageHandler
import com.xtend.coap.message.MessageReceiver
import com.xtend.coap.message.MessageSender
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.message.resource.DiscoveryResource
import com.xtend.coap.message.resource.LocalResource
import com.xtend.coap.message.resource.ReadOnlyResource
import com.xtend.coap.message.resource.Resource
import com.xtend.coap.message.response.Response
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.Option
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.net.SocketException

class EndPoint extends MessageSender implements MessageReceiver, MessageHandler {
	
	Resource rootResource
	Resource wellKnownResource
	DiscoveryResource discoveryResource
	
	new(int port, boolean daemon) throws SocketException {
		super(port, daemon)
		this.communicator.registerReceiver(this)
		this.rootResource = new EndPoint.RootResource(this)
		this.wellKnownResource = new LocalResource(".well-known", true)
		this.wellKnownResource.setResourceName("")
		this.discoveryResource = new DiscoveryResource(rootResource)
		rootResource.addSubResource(wellKnownResource)
		wellKnownResource.addSubResource(discoveryResource)
	}
	
	new() throws SocketException {
		this(DEFAULT_PORT, false)
	}
	
		def port() {
		var res = -1
		if(communicator != null){
			res = communicator.port
		}
		return res
	}
	
	def resourceCount() {
		var res = 0
		if(rootResource != null){
			res = rootResource.subResourceCount + 1
		}
		return res
	}
	
	private static class RootResource extends ReadOnlyResource {
		
		EndPoint endPoint
		
		new(EndPoint endPoint) {
			super("")
			this.endPoint = endPoint
			setResourceName("root")
		}
		
		@Override
		override void performGet(GetRequest request) {
			
			var response = new Response(Code.RESP_CONTENT)
			var data = new ByteArrayOutputStream
			var out = new PrintStream(data)
			
			endPoint.printEndpointInfo(out)
			
			response.setPayload(data.toByteArray)
			
			request.respond(response);
		}		
	}
	
	def void execute(Request request) {
		System.err.println("Impossible to execute")
	}
	
	def protected void createByPut(PutRequest request) {
		
		var identifier = getResourceIdentifier(request)
		var pos = identifier.lastIndexOf('/')
		if (pos != -1 && pos < identifier.length-1) {
			var parentIdentifier = identifier.substring(0, pos)
			var newIdentifier = identifier.substring(pos+1)
			var parent = getResource(parentIdentifier)
			if (parent != null) {
				parent.createNew(request, newIdentifier)
			} else {
				request.respond(Code.RESP_NOT_FOUND, "Unable to create '" + newIdentifier + "' in '" + parentIdentifier + "': Parent does not exist.")
			}
		} else {
			request.respond(Code.RESP_FORBIDDEN)
		}
	}
	
	def void addResource(LocalResource resource) {
		if (rootResource != null) {
			rootResource.addSubResource(resource)
		}
	}
	
	def void removeResource(String resourceIdentifier) {
		if (rootResource != null) {
			rootResource.removeSubResource(resourceIdentifier)
		}
	}
	
	def LocalResource getResource(String resourceIdentifier) {
		if (rootResource != null) {
			return rootResource.getResource(resourceIdentifier) as LocalResource
		} else {
			return null
		}
	}
	
	def protected static String getResourceIdentifier(Request request) {
		
		var uriPaths = request.getOptions(Option.URI_PATH)
		
		if (uriPaths == null) {
			return ""
		}
		var builder = new StringBuilder

		for (var i=0; i<uriPaths.length; i++) {
			builder.append('/')
			builder.append(uriPaths.get(i).getStringValue)
		}
		var builderLength = builder.length
		if(String.valueOf(builder.charAt(builderLength - 1)).equals("/")) {
			builder.deleteCharAt(builderLength - 1)
		}
		return builder.toString
	}
	
	override void receiveMessage(Message msg) {
		msg.handleBy(this)
	}

	override void handleRequest(Request request) {
		execute(request)
	}

	override void handleResponse(Response response) {
		response.handle
	}
	
	def protected void printEndpointInfo(PrintStream out) {
		
		// print disclaimer etc.
		out.println("************************************************************")
		out.println("This CoAP endpoint is using the Xtend-CoAP library")
		out.println("developed by César Estebas Gómez")
		out.println("************************************************************")
	}
}