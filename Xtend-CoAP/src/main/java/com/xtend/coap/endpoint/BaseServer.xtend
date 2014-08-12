package com.xtend.coap.endpoint

import com.xtend.coap.layers.Communicator
import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageHandler
import com.xtend.coap.message.MessageReceiver
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
import com.xtend.coap.message.MessageSender
import com.xtend.coap.utils.HexUtils

class BaseServer extends MessageSender implements MessageReceiver, MessageHandler {
		
	val public static DEFAULT_PORT = Communicator.DEFAULT_PORT
	
	Communicator communicator
	Resource rootResource
	Resource wellKnownResource
	DiscoveryResource discoveryResource
	
	new(int port) throws SocketException {
		this.communicator = new Communicator(port, false)
		this.communicator.registerReceiver(this)
		this.rootResource = new BaseServer.RootResource(this)
		this.wellKnownResource = new LocalResource(".well-known", true)
		this.wellKnownResource.setResourceName("")
		this.discoveryResource = new DiscoveryResource(rootResource)
		rootResource.addSubResource(wellKnownResource)
		wellKnownResource.addSubResource(discoveryResource)
	}
	
	new() throws SocketException {
		this(DEFAULT_PORT)
	}
	def resourceCount() {
		var res = 0
		if(rootResource != null){
			res = rootResource.subResourceCount + 1
		}
		return res
	}
	
	override void receiveMessage(Message msg) {
		msg.handleBy(this)
	}
	
	def port() {
		var res = -1
		if(communicator != null){
			res = communicator.port
		}
		return res
	}
	
	private static class RootResource extends ReadOnlyResource {
		
		BaseServer endPoint
		
		new(BaseServer endPoint) {
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
		if (request != null) {
			var resourceIdentifier = getResourceIdentifier(request);
			var resource = getResource(resourceIdentifier);
			if (resource != null) {
				request.dispat(resource)
				// check if resource is to be observed
				if (request instanceof GetRequest && request.hasOption(Option.OBSERVE)) {
					// establish new observation relationship
					var obsVal = 0
					try {
						obsVal = HexUtils.bytesToInt(request.getFirstOption(Option.OBSERVE).rawValue)
					} catch (NumberFormatException e) {
						System.out.println("[" + getClass.getName + "] Bad OBSERVE option value: " + obsVal)
						request.respond(Code.RESP_BAD_OPTION)
					}
					
					if (obsVal == 0) {
						resource.addObserveRequest(request as GetRequest)
					} else if (obsVal == 1) {
						resource.removeObserveRequest(request.endpointID)
					} else {
						System.out.println("[" + getClass.getName + "] Bad OBSERVE option value: " + obsVal)
						request.respond(Code.RESP_BAD_OPTION)
					}
				} else if (resource.isObserved(request.endpointID)) {
					// terminate observation relationship on that resource
					resource.removeObserveRequest(request.endpointID)
				}
			} else if (request instanceof PutRequest) {
				createByPut(request as PutRequest)
			} else {
				System.out.println("[" + getClass.getName + "] Resource not found: " + resourceIdentifier)
				request.respond(Code.RESP_NOT_FOUND)
			}
		}
	}
	
	def private void createByPut(PutRequest request) {
		
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
	
	def private static String getResourceIdentifier(Request request) {
		
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