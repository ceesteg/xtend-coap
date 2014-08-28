package com.xtend.coap.endpoint

import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.xtend.coap.message.MessageSender
import com.xtend.coap.message.request.Request
import com.xtend.coap.message.response.Response
import com.xtend.coap.utils.MessageType
import com.xtend.coap.utils.Option
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.net.SocketException
import java.net.URISyntaxException

class BaseHTTP2CoAPProxy extends MessageSender implements HttpHandler {

	new(int port, boolean daemon) throws SocketException {
		super(port, daemon)
	}
	
	override void handle(HttpExchange ex) throws IOException {
    	var String response = null
    	var code = 0
    	
    	var method = ex.getRequestMethod
    	var uri = ex.getRequestURI
    	
    	var reqBody = ex.requestBody
    	var payload = ""
 
		var out = new ByteArrayOutputStream
		var buf = newByteArrayOfSize(4096)
		
		var n = reqBody.read(buf)
		while (n > 0) {
			 out.write(buf, 0, n)
			 n = reqBody.read(buf)
		}
		var query = new String(out.toByteArray)
		if (query != null && !query.trim.equals("")) {
			payload = new String(out.toByteArray).split("=").get(1)
		}
	    reqBody.close
		
    	
    	var request = Request.newRequest(method)
    	
    	if (request == null) {
    		response = "Bad Gateway"
    		code = 502
    	} else {
     		if (uri == null) {
     			response = "Bad Request"
    			code = 400
     		} else {
     			try {
					request.setURI(uri)
					request.setOption(new Option(request.getURI.host, Option.URI_HOST))
					var port = request.getURI.port
					if (port == -1) {
						port = MessageSender.DEFAULT_PORT
					}
					request.setOption(new Option(port, Option.URI_PORT))
				} catch (URISyntaxException e) {
					response = "Bad Request"
    				code = 400
				}
				
				request.setID(nextMessageID("P"))
				generateTokenForRequest(request)
				request.setPayload(payload)
				request.enableResponseQueue(true)
				try {
					request.execute
				} catch (IOException e) {
					response = "Internal server error"
    				code = 500
				}
				
				var Response resp = null
				try {
					resp = request.receiveResponse
				} catch (InterruptedException e) {
					response = "Internal server error"
    				code = 500
				}
	
				if (resp != null) {
					response = resp.getPayloadString
					code = HTTPCode(resp.getCode)
					resp.log
					System.out.println("Round Trip Time (ms): " + resp.getRTT)
					if (resp.getType == MessageType.CONFIRMABLE) {
						var reply = resp.newReply(true)
						communicator.sendMessage(reply)
					}
				} else {
					response = "Gateway timeout"
    				code = 504
				}
     		}
    	}

		var respLength = -1
		if (response != null) {
			respLength = response.length
		}
		
        ex.sendResponseHeaders(code, respLength)
        var os = ex.getResponseBody
        os.write(response.getBytes)
        os.close
    }
    
    def private int HTTPCode(String CoAPCode) {
		switch (CoAPCode) {
			case "2.01":
				return 201
			case "2.02":
				return 204
			case "2.03":
				return 304
			case "2.04":
				return 204
			case "2.05":
				return 200
			case "4.00":
				return 400
			case "4.01":
				return 401
			case "4.02":
				return 402
			case "4.03":
				return 403
			case "4.04":
				return 404
			case "4.05":
				return 405
			case "4.06":
				return 406
			case "4.12":
				return 412
			case "4.13":
				return 413
			case "4.15":
				return 415
			case "5.00":
				return 500
			case "5.01":
				return 501
			case "5.02":
				return 502
			case "5.03":
				return 503
			case "5.04":
				return 504
			default: 
				return 500
		}
	}
}