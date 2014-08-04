package xtend.coap.utils

import java.nio.ByteBuffer
import java.io.UnsupportedEncodingException

class Option {
	val public static RESERVED_0          = 0
	
	val public static CONTENT_TYPE        = 1
	val public static MAX_AGE             = 2
	val public static PROXY_URI           = 3
	val public static ETAG                = 4
	val public static URI_HOST            = 5
	val public static LOCATION_PATH       = 6
	val public static URI_PORT            = 7
	val public static LOCATION_QUERY      = 8
	val public static URI_PATH            = 9
	val public static OBSERVE             = 10 
	val public static TOKEN               = 11
	val public static BLOCK               = 13 
	val public static FENCEPOST_DIVISOR   = 14
	val public static URI_QUERY           = 15
	val public static BLOCK2              = 17 
	val public static BLOCK1              = 19 
	
	ByteBuffer value
	int optionNr
	
	new(byte[] raw, int nr) {
		value = ByteBuffer.wrap(raw)
		optionNr = nr
	}

	new(String str, int nr) {
		value = ByteBuffer.wrap(str.getBytes)
		optionNr = nr
	}
	
	new(int valueAux, int nr) {
		setIntValue(valueAux)
		optionNr = nr
	}
	
	def private void setIntValue(int valueAux) {
		var neededBytes = 4
		if (valueAux == 0) {
			value = ByteBuffer.allocate(1)
			value.put(0.byteValue)
		} else {
			var aux = ByteBuffer.allocate(4)
			aux.putInt(valueAux)
			var break = false
			var i = 3
			while (i >= 0 && break == false) {
				if (aux.get(3-i) == 0x00) {
					neededBytes--
				} else {
					break = true
				}
				i--
			}
			value = ByteBuffer.allocate(neededBytes)
			for (var n = neededBytes - 1; n >= 0; n--) {
				value.put(aux.get(3-n))
			}
		}
	}
	
	/*
	 * This method sets the number of the current option
	 * 
	 * @param nr The option number.
	 */
	def setOptionNr (int nr) {
		optionNr = nr
	}
	

	def setValue (byte[] value) {
		this.value = ByteBuffer.wrap(value)
	}
	
	
	// Functions ///////////////////////////////////////////////////////////////
	
	
	/*
	 * This method returns the data of the current option as byte array
	 * 
	 * @return The byte array holding the data
	 */
	def getRawValue() {
		return value.array
	}

	@Override
	override hashCode() {
		val prime = 31
		var result = 1
		result = prime * result + optionNr
		var aux = 0
		if (value == null) {
			aux = 0
		} else {
			aux = value.hashCode
		}
		result = prime * result + aux
		return result
	}
	
	@Override
	override equals(Object obj) {
		var res = false
		if (obj != null) {
			var other = obj as Option
			if (optionNr == other.optionNr) {
				if (other.value.array.length == value.array.length) {
					var cont = 0
					var valid = true
					while (cont<value.array.length && valid) {
						if (other.value.array.get(cont) != value.array.get(cont)){
							valid = false
						}
						cont++
					}
					if (valid) {
						res = true
					}
				}
			}
		} 
		return res
	}

	/*
	 * This method returns the option number of the current option
	 * 
	 * @return The option number as integer
	 */
	def getOptionNumber() {
		return optionNr
	}
	
	/*
	 * This method returns the name that corresponds to the option number.
	 * 
	 * @return The name of the option
	 */
	def String getName() {
		return toString(optionNr)
	}

	/*
	 * This method returns the length of the option's data in the ByteBuffer
	 * 
	 * @return The length of the data stored in the ByteBuffer as number of bytes
	 */
	def getLength() {
		return value.capacity
	}
	
	/*
	 * This method returns the value of the option's data as string
	 * 
	 * @return The string representation of the current option's data
	 */
	def getStringValue () {
		var result = ""
		try {
			result = new String(value.array, "UTF8")
		} catch (UnsupportedEncodingException e) {
			System.err.println("String conversion error")
		}
		return result
	}
	
	/*
	 * This method returns the value of the option's data as integer
	 * 
	 * @return The integer representation of the current option's data
	 */
	def getIntValue () {
		var byteLength = value.capacity
		var temp = ByteBuffer.allocate(4)
		for (var i=0; i < (4-byteLength); i++) {
			temp.put(0.byteValue)
		}
		for (var i=0; i < byteLength; i++) {
			temp.put(value.get(i))
		}
		var valueAux = temp.getInt(0)
		return valueAux
	}
	
	/*
	 * This method returns the current option's data as byte array
	 * 
	 * @return The current option's data as byte array.
	 */
	def getValue () {
		return value
	}
	
	def private static String hex(byte[] data) {
		val digits = "0123456789ABCDEF"
		if (data != null) {
			var length = data.length
			var builder = new StringBuilder(length * 3);
			for (var i = 0; i < length; i++) {
				builder.append(digits.charAt(i.operator_doubleGreaterThan(4).bitwiseAnd(0xF)))
				builder.append(digits.charAt(data.get(i).bitwiseAnd(0xF)))
				if (i < length-1) {
					builder.append(' ')
				}
			}
			return builder.toString
		} else {
			return null
		}
	}
	
	/*
	 * Returns a human-readable string representation of the option's value
	 * 
	 * @Return The option value represented as a string
	 */
	def getDisplayValue() {
		switch (optionNr) {
			case CONTENT_TYPE:
				return MediaType.toString(getIntValue)
			case MAX_AGE:
				return getIntValue + "s"
			case PROXY_URI:
				return getStringValue
			case ETAG:
				return hex(getRawValue)
			case URI_HOST:
				return getStringValue
			case LOCATION_PATH:
				return getStringValue
			case URI_PORT:
				return String.valueOf(getIntValue)
			case LOCATION_QUERY:
				return getStringValue
			case URI_PATH:
				return getStringValue
			case OBSERVE:
				return String.valueOf(getIntValue)
			case TOKEN:
				return hex(getRawValue)
			case URI_QUERY:
				return getStringValue
			case BLOCK:
				return null
			case BLOCK1:
				return null
			case BLOCK2: {
				var valueAux = getIntValue
				var szx = valueAux.bitwiseAnd(0x7)
				var m = valueAux.operator_doubleGreaterThan(3).bitwiseAnd(0x1)
				var num = valueAux.operator_doubleGreaterThan(4)      
				var size = 1.operator_doubleLessThan(szx + 4)
				return "NUM: " + num + ", SZX: " + szx + " (" + size + " bytes), M: " + m
			}
			default:
				return hex(getRawValue)
		}
	}
	
	def static boolean isElective(int optionNumber) {
		return optionNumber.bitwiseAnd(1) == 0
	}

	def static boolean isCritical(int optionNumber) {
		return optionNumber.bitwiseAnd(1) == 1
	}

	def static boolean isFencepost(int optionNumber) {
		return optionNumber % FENCEPOST_DIVISOR == 0
	}
	
	def static int nextFencepost(int optionNumber) {
		return (optionNumber / FENCEPOST_DIVISOR + 1) * FENCEPOST_DIVISOR
	}

	def static String toString(int optionNumber) {
		switch (optionNumber) {
		case RESERVED_0:
			return "Reserved (0)"
		case CONTENT_TYPE:
			return "Content-Type"
		case MAX_AGE:
			return "Max-Age"
		case PROXY_URI:
			return "Proxy-Uri"
		case ETAG:
			return "ETag"
		case URI_HOST:
			return "Uri-Host"
		case LOCATION_PATH:
			return "Location-Path"
		case URI_PORT:
			return "Uri-Port"
		case LOCATION_QUERY:
			return "Location-Query"
		case URI_PATH:
			return "Uri-Path"
		case OBSERVE:
			return "Observe"
		case TOKEN:
			return "Token"
		case BLOCK:
			return "Block"
		case URI_QUERY:
			return "Uri-Query"
		case BLOCK2:
			return "Block2"
		case BLOCK1:
			return "Block1"
		}
		return "Unknown option [number " + optionNumber + "]"
	}
	
	def static OptionFormat getFormatByNr (int optionNumber) {
		switch (optionNumber) {
			case RESERVED_0:
				return OptionFormat.unknown
			case CONTENT_TYPE:
				return OptionFormat.integer
			case PROXY_URI:
				return OptionFormat.string
			case ETAG:
				return OptionFormat.opaque
			case URI_HOST:
				return OptionFormat.string
			case LOCATION_PATH:
				return OptionFormat.string
			case URI_PORT:
				return OptionFormat.integer
			case LOCATION_QUERY:
				return OptionFormat.string
			case URI_PATH:
				return OptionFormat.string
			case TOKEN:
				return OptionFormat.opaque
			case URI_QUERY:
				return OptionFormat.string
			default:
				return OptionFormat.error
		}
	}
	
	def static Option getDefaultOption (int optionNumber) {
		switch(optionNumber) {
			case CONTENT_TYPE:
				return new Option(0, CONTENT_TYPE)
			case MAX_AGE:
				return new Option (60, MAX_AGE)
			case PROXY_URI:
				return new Option ("", PROXY_URI)
			case ETAG:
				return new Option (newByteArrayOfSize(0), ETAG)
			case URI_HOST:
				return null
			case LOCATION_PATH:
				return new Option ("", LOCATION_PATH)
			case URI_PORT:
				return null
			case LOCATION_QUERY:
				return new Option ("", LOCATION_QUERY)
			case URI_PATH:
				return new Option ("", URI_PATH)
			case TOKEN:
				return new Option (newByteArrayOfSize(0), TOKEN)
			case URI_QUERY:
				return new Option ("", URI_QUERY)
			default:
				return null
		}
	}
	
	def static Option getDefaultOption (int optionNumber, String ipAddress) {
		return new Option (ipAddress, URI_HOST)
	}
	
	def static Option getDefaultOption (int optionNumber, int udpPort) {
		return new Option (udpPort, URI_PORT)
	}
}