package com.xtend.coap.utils

import com.xtend.coap.message.Message
import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.Request
import com.xtend.coap.message.response.Response

/**
 * Class for CoAP Code Registries as defined in rfc7252, section 12.1. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class Code {
	public static final String EMPTY_MESSAGE                  = "0.00"
	public static final String METHOD_GET                     = "0.01"
	public static final String METHOD_POST                    = "0.02"
	public static final String METHOD_PUT                     = "0.03"
	public static final String METHOD_DELETE                  = "0.04"
	
	public static final String RESP_CREATED                   = "2.01"
	public static final String RESP_DELETED                   = "2.02"
	public static final String RESP_VALID                     = "2.03"
	public static final String RESP_CHANGED                   = "2.04"
	public static final String RESP_CONTENT                   = "2.05"
	public static final String RESP_BAD_REQUEST               = "4.00"
	public static final String RESP_UNAUTHORIZED              = "4.01"
	public static final String RESP_BAD_OPTION                = "4.02"
	public static final String RESP_FORBIDDEN                 = "4.03"
	public static final String RESP_NOT_FOUND                 = "4.04"
	public static final String RESP_METHOD_NOT_ALLOWED        = "4.05"
	public static final String RESP_NOT_ACCEPTABLE            = "4.06"
	public static final String RESP_PRECONDITION_FAILED       = "4.12"
	public static final String RESP_REQUEST_ENTITY_TOO_LARGE  = "4.13"
	public static final String RESP_UNSUPPORTED_CONTENT_TYPE  = "4.15"
	public static final String RESP_INTERNAL_SERVER_ERROR     = "5.00"
	public static final String RESP_NOT_IMPLEMENTED           = "5.01"
	public static final String RESP_BAD_GATEWAY               = "5.02"
	public static final String RESP_SERVICE_UNAVAILABLE       = "5.03"
	public static final String RESP_GATEWAY_TIMEOUT           = "5.04"
	public static final String RESP_PROXYING_NOT_SUPPORTED    = "5.05"
	
	/**
     * Gets the class of a code. 
     * 
     * @param code String value of the code.
     * @return Class of the code.
     */
	def static int codeClass(String code) {
		var codeD = Double.parseDouble(code)
		return Math.floor(codeD).intValue
	}
	
	/**
     * Gets the detail of a code. 
     * 
     * @param code String value of the code.
     * @return Detail of the code.
     */
	def static int codeDetail(String code) {
		return Integer.valueOf(String.valueOf(code).split("\\.").get(1))
	}
	
	/**
     * Generation of a code parsing the class and the detail. 
     * 
     * @param codeClass Integer value of the class.
     * @param codeDetail Integer value of the detail.
     * @return The code generated.
     */
	def static String genCode(int codeClass, int codeDetail){
		var ret = codeClass + "."
		if (codeDetail < 10) {
			ret += "0"
		}
		return ret + codeDetail
	}

	/**
     * Function that determines if a the code is a request code. 
     * 
     * @param code String value of the code.
     * @return True if the code is a request code, false if not.
     */
	def static isRequest(String code) {
		var codeClass = codeClass(code)
		var codeDetail = codeDetail(code)
		return (codeClass == 0) && (codeDetail >= 1) && (codeDetail <= 31)
	}

	/**
     * Function that determines if a the code is a response code. 
     * 
     * @param code String value of the code.
     * @return True if the code is a response code, false if not.
     */
	def static isResponse(String code) {
		var codeClass = codeClass(code)
		var codeDetail = codeDetail(code)
		return (codeClass >= 2) && (codeClass <=5) && (codeDetail >= 0) && (codeDetail <= 31)
	}

	/**
     * Function that determines if a the code is valid.
     * 
     * @param code String value of the code.
     * @return True if the code is valid, false if not.
     */
	def static isValid(String code) {
		var codeClass = codeClass(code)
		var codeDetail = codeDetail(code)
		return (codeClass >= 0) && (codeClass <= 7) && (codeDetail >= 0) && (codeDetail <= 31)
	}
	
	/**
     * Function to get the class of a message.
     * 
     * @param code String value of the code.
     * @return The type of the message according to the code.
     */
	def static Class<? extends Message> getMessageClass(String code) {
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
	
	/**
     * Function that returns a human-readable string representation of the code.
     * 
     * @return Code represented as string.
     */
	def static toString(String code) {
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