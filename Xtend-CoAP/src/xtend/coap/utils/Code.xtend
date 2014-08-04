package xtend.coap.utils

import xtend.coap.message.Message
import xtend.coap.message.request.GetRequest
import xtend.coap.message.request.Request
import xtend.coap.message.request.PostRequest
import xtend.coap.message.request.PutRequest
import xtend.coap.message.request.DeleteRequest
import xtend.coap.message.response.Response

class Code {
	// Constants ///////////////////////////////////////////////////////////////
	
	public static final int EMPTY_MESSAGE                         = 0
	
	// Method Codes ////////////////////////////////////////////////////////////
	public static final int METHOD_GET                            = 1
	public static final int METHOD_POST                           = 2
	public static final int METHOD_PUT                            = 3
	public static final int METHOD_DELETE                         = 4
	
	// Response Codes //////////////////////////////////////////////////////////
	public static final int RESP_CLASS_SUCCESS                    = 2
	public static final int RESP_CLASS_CLIENT_ERROR               = 4
	public static final int RESP_CLASS_SERVER_ERROR               = 5
	
	public static final int RESP_CREATED                          = 65
	public static final int RESP_DELETED                          = 66
	public static final int RESP_VALID                            = 67
	public static final int RESP_CHANGED                          = 68
	public static final int RESP_CONTENT                          = 69
	
	public static final int RESP_BAD_REQUEST                      = 128
	public static final int RESP_UNAUTHORIZED                     = 129
	public static final int RESP_BAD_OPTION                       = 130
	public static final int RESP_FORBIDDEN                        = 131
	public static final int RESP_NOT_FOUND                        = 132
	public static final int RESP_METHOD_NOT_ALLOWED               = 133
	public static final int RESP_NOT_ACCEPTABLE                   = 134
	public static final int RESP_PRECONDITION_FAILED              = 140
	public static final int RESP_REQUEST_ENTITY_TOO_LARGE         = 141
	public static final int RESP_UNSUPPORTED_CONTENT_TYPE         = 143
	
	public static final int RESP_INTERNAL_SERVER_ERROR            = 160
	public static final int RESP_NOT_IMPLEMENTED                  = 161
	public static final int RESP_BAD_GATEWAY                      = 162
	public static final int RESP_SERVICE_UNAVAILABLE              = 163
	public static final int RESP_GATEWAY_TIMEOUT                  = 164
	public static final int RESP_PROXYING_NOT_SUPPORTED           = 165
	
	// from draft-ietf-core-block-03
	public static final int RESP_REQUEST_ENTITY_INCOMPLETE        = 136
	
	// deprecated (draft 3)
	public static final int V3_RESP_CONTINUE                      = 40
	public static final int V3_RESP_OK                            = 80
	public static final int V3_RESP_CREATED                       = 81
	public static final int V3_RESP_NOT_MODIFIED                  = 124
	public static final int V3_RESP_BAD_REQUEST                   = 160
	public static final int V3_RESP_NOT_FOUND                     = 164
	public static final int V3_RESP_METHOD_NOT_ALLOWED            = 165
	public static final int V3_RESP_UNSUPPORTED_MEDIA_TYPE        = 175
	public static final int V3_RESP_INTERNAL_SERVER_ERROR         = 200
	public static final int V3_RESP_BAD_GATEWAY                   = 202
	public static final int V3_RESP_SERVICE_UNAVAILABLE           = 203
	public static final int V3_RESP_GATEWAY_TIMEOUT               = 204
	public static final int V3_RESP_TOKEN_OPTION_REQUIRED         = 240
	public static final int V3_RESP_URI_AUTHORITY_OPTION_REQUIRED = 241
	public static final int V3_RESP_CRITICAL_OPTION_NOT_SUPPORTED = 242
	
	def static isRequest(int code) {
		return (code >= 1) && (code <= 31)
	}

	def static isResponse(int code) {
		return (code >= 40) && (code <= 242)
	}

	def static isValid(int code) {
		return (code >= 0) && (code <= 255)
	}

	def static responseClass(int code) {
		return code.operator_doubleGreaterThan(5).bitwiseAnd(0x7)
	}

	def static Class<? extends Message> getMessageClass(int code) {
		if (isRequest(code)) {
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
		} else if (code == EMPTY_MESSAGE) {
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
				
			// Deprecated (Draft 3)
			case V3_RESP_CONTINUE:
				return "100 Continue"
			case V3_RESP_OK:
				return "200 OK"
			case V3_RESP_CREATED:
				return "201 Created"
			case V3_RESP_NOT_MODIFIED:
				return "304 Not Modified"
			case V3_RESP_UNSUPPORTED_MEDIA_TYPE:
				return "415 Unsupported Media Type"
			case V3_RESP_INTERNAL_SERVER_ERROR:
				return "500 Internal Server Error"
			case V3_RESP_BAD_GATEWAY:
				return "502 Bad Gateway"
			case V3_RESP_SERVICE_UNAVAILABLE:
				return "503 Service Unavailable"
			case V3_RESP_GATEWAY_TIMEOUT:
				return "504 Gateway Timeout"
			case V3_RESP_TOKEN_OPTION_REQUIRED:
				return "Token Option required by server"
			case V3_RESP_URI_AUTHORITY_OPTION_REQUIRED:
				return "Uri-Authority Option required by server"
			case V3_RESP_CRITICAL_OPTION_NOT_SUPPORTED:
				return "Critical Option not supported"
		}
		
		if (isValid(code)) {
			if (isRequest(code)) {
				return "Unknown Request [code " + code + "]"
			} else if (isResponse(code)) {
				return "Unknown Response [code " + code + "]"
			} else {
				return "Reserved [code " + code + "]"
			}
		} else {
			return "Invalid Message [code " + code + "]"
		}
	}
}