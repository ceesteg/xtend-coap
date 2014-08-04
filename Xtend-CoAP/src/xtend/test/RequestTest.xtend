package xtend.test

import java.util.Timer
import java.util.TimerTask

import xtend.coap.message.response.Response
import xtend.coap.message.request.Request
import xtend.coap.message.request.GetRequest

import static org.junit.Assert.*
import org.junit.Test

class RequestTest {
	
	Response handledResponse
	var timer = new Timer
	
	static class RespondTask extends TimerTask {
		Request request
		Response response
		new(Request request, Response response) {
			this.request = request
			this.response = response
		}
		
		@Override
		override void run() {
			request.respond(response)
		}
	}

	@Test
	def void testRespond() {
		var response = new Response
		var request = new GetRequest {
			@Override
			override void handleResponse(Response resp) {
				handledResponse = resp
			}
		}
		request.respond(response)
		assertSame(response, handledResponse)
	}
	
	@Test
	def void testReceiveResponse() throws InterruptedException {
		var request = new GetRequest
		request.enableResponseQueue(true)
		var response = new Response
		timer.schedule(new RespondTask(request, response), 500)
		var receivedResponse = request.receiveResponse
		assertSame(response, receivedResponse)
	} 
}