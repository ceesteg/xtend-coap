package com.xtend.coap.endpoint

import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageHandler
import com.xtend.coap.message.MessageReceiver
import com.xtend.coap.message.MessageSender
import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.message.response.Response
import com.xtend.coap.resource.DiscoveryResource
import com.xtend.coap.resource.LocalResource
import com.xtend.coap.resource.ReadOnlyResource
import com.xtend.coap.resource.Resource
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.HexUtils
import com.xtend.coap.utils.MessageType
import com.xtend.coap.utils.Option
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.PrintStream
import java.net.SocketException
import java.net.URISyntaxException
import java.util.ArrayList
import org.apache.http.HttpResponse
import org.apache.http.NameValuePair
import org.apache.http.client.entity.UrlEncodedFormEntity
import org.apache.http.client.methods.HttpDelete
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.methods.HttpPost
import org.apache.http.client.methods.HttpPut
import org.apache.http.client.utils.URIBuilder
import org.apache.http.impl.client.HttpClients
import org.apache.http.message.BasicNameValuePair
import org.apache.http.util.EntityUtils

/** 
 * Class that represents a CoAP End Point.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
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
	
	def void execute(Request request) {
		System.err.println("Impossible to execute")
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
	
	override void receiveMessage(Message msg) {
		msg.handleBy(this)
	}

	override void handleRequest(Request request) {
		execute(request)
	}

	override void handleResponse(Response response) {
		response.handle
	}
	
	def void printEndpointInfo(PrintStream out) {
		out.println("***************************************************************************************")
		out.println("|                                                                                     |")
		out.println("| This CoAP endpoint is using the Xtend-CoAP library developed by César Estebas Gómez |")
		out.println("|                                                                                     |")
		out.println("***************************************************************************************")
	}
}

/** 
 * Class that represents a base CoAP Server.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */ 
class BaseCoAPServer extends EndPoint {
	
	new() throws SocketException {
		super()
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
				if (request instanceof GetRequest && request.hasOption(Option.OBSERVE)) {
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
						request.respond(Code.RESP_CONTENT, "Observation with resource " + resource.resourceName + " ended.")
					} else {
						System.out.println("[" + getClass.getName + "] Bad OBSERVE option value: " + obsVal)
						request.respond(Code.RESP_BAD_OPTION)
					}
				} else if (resource.isObserved(request.endpointID)) {
					// terminate observation relationship on that resource
					resource.removeObserveRequest(request.endpointID)
					request.respond(Code.RESP_CONTENT, "Observation with resource " + resource.resourceName + " ended.")
				}
			} else if (request instanceof PutRequest) {
				createByPut(request as PutRequest)
			} else {
				System.out.println("[" + getClass.getName + "] Resource not found: " + resourceIdentifier)
				request.respond(Code.RESP_NOT_FOUND)
			}
		}
	}
}

/** 
 * Class that represents a base HTTP-CoAP Proxy.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
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

/** 
 * Class that represents a base CoAP-HTTP Proxy.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class BaseCoAP2HTTPProxy extends EndPoint {
	
	new(int port, boolean daemon) throws SocketException {
		super(port, daemon)
	}
	
	override void execute(Request request) {
		if (request != null) {
			var reply = request.newReply(true)
			request.log
			var host = request.getFirstOption(Option.URI_HOST).displayValue
			var port = request.getFirstOption(Option.URI_PORT).displayValue
			var builder = new URIBuilder
			builder.setScheme("http").setHost(host).setPort(Integer.valueOf(port))
		    var path = ""
			var paths = request.getOptions(Option.URI_PATH)
			for (var i = 0; i < paths.length; i++) {
				path += "/" + paths.get(i).displayValue
			}
			builder.setPath(path)
			var httpClient = HttpClients.createDefault
			var dataValue = request.payloadString
			var code = 0
			var HttpResponse response = null
			if (request instanceof GetRequest) {
				var uri = builder.build
				var req = new HttpGet(uri)
				response = httpClient.execute(req)
				code = response.getStatusLine.statusCode
			} else if (request instanceof PostRequest) {
				var uri = builder.build
				var req = new HttpPost(uri)
				var postParameters = new ArrayList<NameValuePair>
				for (String param : dataValue.trim.split("&")) {
					var p = param.split("=")	
					postParameters.add(new BasicNameValuePair(p.get(0), p.get(1)))
				}
				req.setEntity(new UrlEncodedFormEntity(postParameters))
				response = httpClient.execute(req)
			} else if (request instanceof PutRequest) {
				for (String param : dataValue.trim.split("&")) {
					var p = param.split("=")	
					builder.setParameter(p.get(0), p.get(1))
				}
				var uri = builder.build
				var req = new HttpPut(uri)
				response = httpClient.execute(req)
			} else if (request instanceof DeleteRequest) {
				var uri = builder.build
				var req = new HttpDelete(uri)
				response = httpClient.execute(req)
				code = response.getStatusLine.statusCode
			}
			
			if (response != null) {
				code = response.getStatusLine.statusCode
			} else  {
				code = 502
			}
			var coapCode = CoAPCode(code, request)	
			if (response.getEntity != null) {
				reply.setPayload(EntityUtils.toString(response.getEntity, "UTF-8").trim)
			}
			reply.setCode(coapCode)		    

			communicator.sendMessage(reply)
			httpClient.close
		}
	}
	
	def private String CoAPCode(int HttpCode, Request req) {
		switch (HttpCode) {
			case 200:
				return Code.RESP_CONTENT
			case 201:
				return Code.RESP_CREATED
			case 204:
				if (req instanceof DeleteRequest) {
					return Code.RESP_DELETED
				} else if (req instanceof PostRequest || req instanceof PutRequest){
					return Code.RESP_CHANGED
				}
			case 304:
				return Code.RESP_VALID
			case 400:
				return Code.RESP_BAD_REQUEST
			case 401:
				return Code.RESP_UNAUTHORIZED
			case 403:
				return Code.RESP_FORBIDDEN
			case 404:
				return Code.RESP_NOT_FOUND
			case 405:
				return Code.RESP_METHOD_NOT_ALLOWED
			case 406:
				return Code.RESP_NOT_ACCEPTABLE
			case 412:
				return Code.RESP_PRECONDITION_FAILED
			case 413:
				return Code.RESP_REQUEST_ENTITY_TOO_LARGE
			case 415:
				return Code.RESP_UNSUPPORTED_CONTENT_TYPE
			case 500:
				return Code.RESP_INTERNAL_SERVER_ERROR
			case 501:
				return Code.RESP_NOT_IMPLEMENTED
			case 502:
				return Code.RESP_BAD_GATEWAY
			case 503:
				return Code.RESP_SERVICE_UNAVAILABLE
			case 504:
				return Code.RESP_GATEWAY_TIMEOUT
			default: 
				return ""
		}
	}
}
