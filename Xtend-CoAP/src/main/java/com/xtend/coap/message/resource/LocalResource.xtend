package com.xtend.coap.message.resource

import java.util.Map
import java.util.HashMap

import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.utils.Code

class LocalResource extends Resource {

	Map<String, GetRequest> observeRequests
	
	// Constructors ////////////////////////////////////////////////////////////
	
	new (String resourceIdentifier, boolean hidden) {
		super(resourceIdentifier, hidden)
	}
	new (String resourceIdentifier) {
		super(resourceIdentifier, false)
	}

	def void addObserveRequest(GetRequest request) {
		if (request != null) {
			if (observeRequests == null) {
				observeRequests = new HashMap<String, GetRequest>
			}
			observeRequests.put(request.endpointID, request)
			System.out.println("Observation relationship between " + request.endpointID + " and " + getResourceIdentifier + " established.")

		}
	}
	
	def void removeObserveRequest(String endpointID) {
		
		if (observeRequests != null) {
			if (observeRequests.remove(endpointID) != null) {
				System.out.println("Observation relationship between " + endpointID + " and " + getResourceIdentifier + " terminated.")
			}
		}
	}

	def isObserved(String endpointID) {
		return observeRequests != null && observeRequests.containsKey(endpointID)
	}
	
	def protected void processObserveRequests() {
		if (observeRequests != null) {
			for (GetRequest request : observeRequests.values) {
				performGet(request)
			}
		}
	}
	
	def protected void changed() {
		processObserveRequests
	}
	
	// REST Operations /////////////////////////////////////////////////////////
	
	@Override
	override void performGet(GetRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}

	@Override
	override void performPut(PutRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}
	
	@Override
	override void performPost(PostRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}
	
	@Override
	override void performDelete(DeleteRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}

	@Override
	override void createNew(PutRequest request, String newIdentifier) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}		
}
