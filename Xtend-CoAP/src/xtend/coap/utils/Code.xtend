package xtend.coap.utils

import xtend.coap.message.Message
import xtend.coap.message.request.GetRequest
import xtend.coap.message.request.Request
import xtend.coap.message.request.PostRequest
import xtend.coap.message.request.PutRequest
import xtend.coap.message.request.DeleteRequest
import xtend.coap.message.response.Response

class Code {
	public static final int EMPTY_MESSAGE = 0
	
	public static final int METHOD_GET = 1
	public static final int METHOD_POST = 2
	public static final int METHOD_PUT = 3
	public static final int METHOD_DELETE = 4
	
	public static final int RESP_CREATED                          = 201
	public static final int RESP_DELETED                          = 202
	public static final int RESP_VALID                            = 203
	public static final int RESP_CHANGED                          = 204
	public static final int RESP_CONTENT                          = 205
	public static final int RESP_BAD_REQUEST                      = 400
	public static final int RESP_UNAUTHORIZED                     = 401
	public static final int RESP_BAD_OPTION                       = 402
	public static final int RESP_FORBIDDEN                        = 403
	public static final int RESP_NOT_FOUND                        = 404
	public static final int RESP_METHOD_NOT_ALLOWED               = 405
	public static final int RESP_NOT_ACCEPTABLE                   = 406
	public static final int RESP_PRECONDITION_FAILED              = 412
	public static final int RESP_REQUEST_ENTITY_TOO_LARGE         = 413
	public static final int RESP_UNSUPPORTED_CONTENT_TYPE         = 415
	public static final int RESP_INTERNAL_SERVER_ERROR            = 500
	public static final int RESP_NOT_IMPLEMENTED                  = 501
	public static final int RESP_BAD_GATEWAY                      = 502
	public static final int RESP_SERVICE_UNAVAILABLE              = 503
	public static final int RESP_GATEWAY_TIMEOUT                  = 504
	public static final int RESP_PROXYING_NOT_SUPPORTED           = 505
	
	def static isRequest(int code) {
		return (code >= 1) && (code <= 31)
	}

	def static isResponse(int code) {
		return (code >= 200) && (code <= 531)
	}

	def static isValid(int code) {
		return ((code >= 0) && (code <= 31)) || ((code >= 100) && (code <= 131)) || ((code >= 200) && (code <= 531)) || ((code >= 600) && (code <= 731))
	}

	def static Class<? extends Message> getMessageClass(int code) {
		if (code == EMPTY_MESSAGE) {
			return typeof(Response)
		} else if (isRequest(code)) {
			switch (code) {
				case METHOD_GET: 
					return typeof(GetRequest)
				case METHOD_POST: 
					return typeof(PostRequest)
				case METHOD_PUT: 
					return typeof(PutRequest)
				case METHOD_DELETE: 
					return typeof(DeleteRequest)
				default: 
					return typeof(Request)
			}
		} else if (isResponse(code)) {
			return typeof(Response)
		} else if (isValid(code)) {
			return typeof(Message)
		} else {
			return null
		}
	}
	
	def static toString(int code) {
		switch (code) {
			case EMPTY_MESSAGE:
				return "Empty Message"
			case METHOD_GET:    
				return "GET Request"
			case METHOD_POST:   
				return "POST Request"
			case METHOD_PUT:    
				return "PUT Request"
			case METHOD_DELETE: 
				return "DELETE Request"
			case RESP_CREATED: 
				return "2.01 Created"
			case RESP_DELETED: 
				return "2.02 Deleted"
			case RESP_VALID: 
				return "2.03 Valid"
			case RESP_CHANGED: 
				return "2.04 Changed"
			case RESP_CONTENT: 
				return "2.05 Content"
			case RESP_BAD_REQUEST: 
				return "4.00 Bad Request"
			case RESP_UNAUTHORIZED: 
				return "4.01 Unauthorized"
			case RESP_BAD_OPTION: 
				return "4.02 Bad Option"
			case RESP_FORBIDDEN: 
				return "4.03 Forbidden"
			case RESP_NOT_FOUND: 
				return "4.04 Not Found"
			case RESP_METHOD_NOT_ALLOWED: 
				return "4.05 Method Not Allowed"
			case RESP_NOT_ACCEPTABLE:
				return "4.06 Not Acceptable"
			case RESP_PRECONDITION_FAILED: 
				return "4.12 Precondition Failed"
			case RESP_REQUEST_ENTITY_TOO_LARGE: 
				return "4.13 Request Entity Too Large"
			case RESP_UNSUPPORTED_CONTENT_TYPE: 
				return "4.15 Unsupported Media Type"
			case RESP_INTERNAL_SERVER_ERROR: 
				return "5.00 Internal Server Error"
			case RESP_NOT_IMPLEMENTED: 
				return "5.01 Not Implemented"
			case RESP_BAD_GATEWAY: 
				return "5.02 Bad Gateway"
			case RESP_SERVICE_UNAVAILABLE: 
				return "5.03 Service Unavailable"
			case RESP_GATEWAY_TIMEOUT: 
				return "5.04 Gateway Timeout"
			case RESP_PROXYING_NOT_SUPPORTED: 
				return "5.05 Proxying Not Supported"
		}
		if (isValid(code)) {
			if (isRequest(code)) {
				return "Unknown request code " + code
			} else if (isResponse(code)) {
				return "Unknown response code " + code
			} else {
				return "Reserved code " + code
			}
		} else {
			return "Invalid message code " + code
		}
	}
}