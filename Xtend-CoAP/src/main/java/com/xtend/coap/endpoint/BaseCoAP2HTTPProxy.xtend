package com.xtend.coap.endpoint

import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.Option
import java.net.SocketException
import java.util.ArrayList
import org.apache.http.HttpResponse
import org.apache.http.NameValuePair
import org.apache.http.client.entity.UrlEncodedFormEntity
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.methods.HttpPost
import org.apache.http.client.methods.HttpPut
import org.apache.http.client.utils.URIBuilder
import org.apache.http.impl.client.HttpClients
import org.apache.http.message.BasicNameValuePair
import org.apache.http.util.EntityUtils

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