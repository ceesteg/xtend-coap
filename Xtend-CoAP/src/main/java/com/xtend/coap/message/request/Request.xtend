package com.xtend.coap.message.request

import java.io.IOException
import java.net.SocketException
import java.util.ArrayList
import java.util.List
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue

import com.xtend.coap.message.Message
import com.xtend.coap.message.response.Response
import com.xtend.coap.message.MessageHandler
import com.xtend.coap.message.response.ResponseHandler
import com.xtend.coap.layers.Communicator
import com.xtend.coap.utils.MessageType
import com.xtend.coap.utils.Code

class Request extends Message {
	
	static Communicator DEFAULT_COMM
	val static TIMEOUT_RESPONSE = new Response
	
	Communicator communicator
	List<ResponseHandler> responseHandlers
	BlockingQueue<Response> responseQueue
	int responseCount

	/*
	 * Constructor for a new CoAP message
	 * 
	 * @param code The method code of the message
	 * @param confirmable True if the request is to be sent as a Confirmable
	 */	
	new(String code, boolean confirmable) {
		if(confirmable){
			this.type = MessageType.CONFIRMABLE
		} else{
			this.type = MessageType.NON_CONFIRMABLE
		}
		this.code = code
	}
	
	/*
	 * Executes the request on the endpoint specified by the URI
	 * 
	 */
	def void execute() throws IOException {
		var Communicator comm = null
		if (communicator != null){
			comm = communicator
		}else{
			comm = defaultCommunicator
		}
		if (comm != null) {
			comm.sendMessage(this)
		}
	}
	
	/*
	 * Places a new response to this request, e.g. to answer it
	 * 
	 * @param response A response to this request
	 */
	def void respond(Response response) {
		response.setRequest(this)
		response.setURI(getURI)
		response.setToken(getToken, getTokenLength)
		if (responseCount == 0 && isConfirmable) {
			response.setID(getID)
		}
		if (response.getType == null) {
			if (responseCount == 0 && isConfirmable) {
				response.setType(MessageType.ACKNOWLEDGMENT)
			} else {
				response.setType(getType)
			}
		}		
		
		if (communicator != null) {
			try {
				communicator.sendMessage(response)
			} catch (IOException e) {
				e.printStackTrace
			} 
		} else {
			response.handle
		}
		responseCount++
	}
	
	def void respond(String code, String message) {
		var response = new Response(code)
		if (message != null) {
			response.setPayload(message)
		}
		respond(response)
	}

	def void respond(String code) {
		respond(code, null)
	}
	
	def void accept() {
		if (isConfirmable) {
			var ack = new Response(Code.EMPTY_MESSAGE)
			ack.setType(MessageType.ACKNOWLEDGMENT)
			respond(ack)
		}
	}

	def void reject() {
		if (isConfirmable) {
			var rst = new Response(Code.EMPTY_MESSAGE)
			rst.setType(MessageType.RESET)
			respond(rst)
		}
	}
	
	def setCommunicator(Communicator communicator) {
		this.communicator = communicator
	}
	
	/*
	 * Returns a response that was placed using respond() and
	 * blocks until such a response is available.
	 * 
	 * NOTE: In order to safely use this method, the call useResponseQueue(true)
	 * is required BEFORE any possible respond() calls take place
	 * 
	 * @return The next response that was placed using respond()
	 */
	def receiveResponse() throws InterruptedException {
		if (!responseQueueEnabled) {
			System.out.println("WARNING: Missing useResponseQueue(true) call, responses may be lost")
			enableResponseQueue(true)
		}
		var response = responseQueue.take
		var Response res = null
		if(response != TIMEOUT_RESPONSE){
			res = response
		}
		return res
	}
	
	@Override
	override void timedOut() { 
		if (responseQueueEnabled) {
			responseQueue.offer(TIMEOUT_RESPONSE)
		}
	}

	/*
	 * Registers a handler for responses to this request
	 * 
	 * @param handler The observer to add to the handler list
	 */
	def void registerResponseHandler(ResponseHandler handler) {
		if (handler != null) {
			if (responseHandlers == null) {
				responseHandlers = new ArrayList<ResponseHandler>
			}
			responseHandlers.add(handler)
		}
	}

	/*
	 * Unregisters a handler for responses to this request
	 * 
	 * @param handler The observer to remove from the handler list
	 */	
	def void unregisterResponseHandler(ResponseHandler handler) {
		if (handler != null && responseHandlers != null) {
			responseHandlers.remove(handler)
		}
	}

	/*
	 * Enables or disables the response queue
	 * 
	 * NOTE: The response queue needs to be enabled BEFORE any possible
	 *       calls to receiveResponse()
	 * 
	 * @param enable True to enable and false to disable the response queue,
	 * respectively
	 */
	def void enableResponseQueue(boolean enable) {
		if (enable != responseQueueEnabled) {
			responseQueue = null
			if(enable){
				responseQueue = new LinkedBlockingQueue<Response>
			}
		}
	}
	
	/*
	 * Checks if the response queue is enabled
	 * 
	 * NOTE: The response queue needs to be enabled BEFORE any possible
	 *       calls to receiveResponse()
	 * 
	 * @return True iff the response queue is enabled
	 */	
	def responseQueueEnabled() {
		return responseQueue != null
	}	
	
	// Subclassing /////////////////////////////////////////////////////////////
	
	/*
	 * This method is called whenever a response was placed to this request.
	 * Subclasses can override this method in order to handle responses.
	 * 
	 * @param response The response to handle
	 */
	def handleResponse(Response response) {
		if (responseQueueEnabled) {
			if (!responseQueue.offer(response)) {
				System.err.println("ERROR: Failed to enqueue response to request")
			}
		}
		if (responseHandlers != null) {
			for (ResponseHandler handler : responseHandlers) {
				handler.handleResponse(response)
			}
		}
	}
	
	def responsePayloadAppended(Response response, byte[] block) { }
	
	def responseCompleted(Response response) { }
	
	/*
	 * Direct subclasses need to override this method in order to invoke
	 * the according method of the provided RequestHandler (visitor pattern)
	 * 
	 * @param handler A handler for this request
	 */
	def void dispat(RequestHandler handler) {
		System.err.println("Unable to dispatch request with code '" + Code.toString(getCode) + "'")
	}
	
	@Override
	override void handleBy(MessageHandler handler) {
		handler.handleRequest(this)
	}
	
	// Class functions /////////////////////////////////////////////////////////

	/*
	 * Returns the default communicator used for outgoing requests
	 * 
	 * @return The default communicator
	 */
	def static defaultCommunicator() {
		if (DEFAULT_COMM == null) {
			try {
				DEFAULT_COMM = new Communicator
			} catch (SocketException e) {
				System.err.println("[Xtend-CoAP] Failed to create default communicator: " + e.getMessage)
			}
		}
		return DEFAULT_COMM
	}
	
		/*
	 * Instantiates a new request based on a string describing a method.
	 * 
	 * @return A new request object, or null if method not recognized
	 */
	def static Request newRequest(String method) {
		if (method.equals("GET")) {
			return new GetRequest
		} else if (method.equals("POST")) {
			return new PostRequest
		} else if (method.equals("PUT")) {
			return new PutRequest
		} else if (method.equals("DELETE")) {
			return new DeleteRequest
		} else if (method.equals("DISCOVER")){
			return new GetRequest
		} else if (method.equals("OBSERVE")){
			return new GetRequest
		} else {
			return null
		}
	}
}