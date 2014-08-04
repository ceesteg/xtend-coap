package xtend.coap.utils

class MediaType {
	
	val public static PLAIN = 0
	val public static XML = 41
	val public static OCTET_STREAM = 42
	val public static EXI = 47
	val public static JSON = 50
	val public static LINK_FORMAT = 40
	
	def static String toString(int mediaType) {
		switch (mediaType) {
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
				return "Unknown media type: " + mediaType
		}
	}
}