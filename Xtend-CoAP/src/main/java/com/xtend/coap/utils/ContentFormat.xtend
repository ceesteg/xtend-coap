package com.xtend.coap.utils

/**
 * Class for CoAP valid content formats as defined in rfc7252, section 12.3. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class ContentFormat {
	
	val public static PLAIN = 0
	val public static LINK_FORMAT = 40
	val public static XML = 41
	val public static OCTET_STREAM = 42
	val public static EXI = 47
	val public static JSON = 50
	
	/**
     * Function that returns a more readable by human representation of the content format.
     * 
     * @param contentFormat Integer value of the content format.
     * @return String representation of the content format.
     */
	def static String toString(int contentFormat) {
		switch (contentFormat) {
			case PLAIN:
				return "text/plain charset=utf-8"
			case LINK_FORMAT:
				return "application/link-format"
			case XML:
				return "application/xml"
			case OCTET_STREAM:
				return "application/octet-stream"
			case EXI:
				return "application/exi"
			case JSON:
				return "application/json"
			default:
				return "Unknown content format: " + contentFormat
		}
	}
}