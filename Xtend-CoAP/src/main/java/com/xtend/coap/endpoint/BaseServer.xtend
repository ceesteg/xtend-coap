package com.xtend.coap.endpoint

import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.HexUtils
import com.xtend.coap.utils.Option
import java.net.SocketException

class BaseServer extends EndPoint {
	
	new() throws SocketException {
		super()
	}
	
	override void handleRequest(Request request) {
		System.out.println("Incoming request:")
		request.log
		super.handleRequest(request)
	}
	
	override void execute(Request request) {
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
	}}