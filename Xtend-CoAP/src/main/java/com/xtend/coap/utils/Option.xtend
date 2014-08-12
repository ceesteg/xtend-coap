package com.xtend.coap.utils

import java.nio.ByteBuffer
import java.io.UnsupportedEncodingException

class Option {
	
	val public static IF_MATCH            = 1
	val public static URI_HOST            = 3
	val public static ETAG                = 4
	val public static IF_NONE_MATCH       = 5
	val public static OBSERVE             = 6 // draft-ietf-core-observe-14
	val public static URI_PORT            = 7
	val public static LOCATION_PATH       = 8
	val public static URI_PATH            = 11
	val public static CONTENT_FORMAT      = 12
	val public static MAX_AGE             = 14
	val public static URI_QUERY           = 15
	val public static ACCEPT              = 17
	val public static LOCATION_QUERY      = 20
	val public static PROXY_URI           = 35
	val public static PROXY_SCHEME        = 39
	val public static SIZE1               = 60
	val public static TOKEN               = 13  // Token option

    val public static OPTION_JUMP = 14
	
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
		var aux = HexUtils.intToBytes(valueAux, 4)
		value = ByteBuffer.allocate(4).put(aux, 0, aux.length)
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
		return HexUtils.bytesToInt(value.array)
	}
	
	/*
	 * This method returns the current option's data as byte array
	 * 
	 * @return The current option's data as byte array.
	 */
	def getValue () {
		return value
	}

	/*
	 * Returns a human-readable string representation of the option's value
	 * 
	 * @Return The option value represented as a string
	 */
	def getDisplayValue() {
		switch (optionNr) {
			case IF_MATCH:
				return HexUtils.hex(getRawValue)
			case URI_HOST:
				return getStringValue
			case ETAG:
				return HexUtils.hex(getRawValue)
			case IF_NONE_MATCH:
				return ""
			case OBSERVE:
				return String.valueOf(getIntValue)
			case URI_PORT:
				return String.valueOf(getIntValue)
			case LOCATION_PATH:
				return getStringValue
			case URI_PATH:
				return getStringValue
			case CONTENT_FORMAT: 
				return ContentFormat.toString(getIntValue)
			case MAX_AGE:
				return getIntValue + "s"
			case URI_QUERY:
				return getStringValue
			case ACCEPT:
				return String.valueOf(getIntValue)
			case LOCATION_QUERY:
				return getStringValue
			case PROXY_URI:
				return getStringValue
			case PROXY_SCHEME:
				return getStringValue
			case SIZE1:
				return String.valueOf(getIntValue)
			case TOKEN:
				return HexUtils.hex(getRawValue)
			default:
				return HexUtils.hex(getRawValue)
		}
	}

	def static String toString(int optionNumber) {
		switch (optionNumber) {
			case IF_MATCH:
				return "If-Match"
			case URI_HOST:
				return "Uri-Host"
			case ETAG:
				return "ETag"
			case IF_NONE_MATCH:
				return "If-None-Match"
			case OBSERVE:
				return "Observe"
			case URI_PORT:
				return "Uri-Port"
			case LOCATION_PATH:
				return "Location-Path"
			case URI_PATH:
				return "Uri-Path"
			case CONTENT_FORMAT:
				return "Content-Format"
			case MAX_AGE:
				return "Max-Age"
			case URI_QUERY:
				return "Uri-Query"
			case ACCEPT:
				return "Accept"
			case LOCATION_QUERY:
				return "Location-Query"
			case PROXY_URI:
				return "Proxy-Uri"
			case PROXY_SCHEME:
				return "Proxy-Scheme"
			case SIZE1:
				return "Size1"
			case TOKEN:
				return "Token"
			default:
				return "Unknown option number " + optionNumber
		}
	}
	
	def static OptionFormat getFormatByNr (int optionNumber) {
		switch (optionNumber) {
			case IF_MATCH:
				return OptionFormat.OPAQUE
			case URI_HOST:
				return OptionFormat.STRING
			case ETAG:
				return OptionFormat.OPAQUE
			case IF_NONE_MATCH:
				return OptionFormat.EMPTY
			case OBSERVE:
				return OptionFormat.UINT
			case URI_PORT:
				return OptionFormat.UINT
			case LOCATION_PATH:
				return OptionFormat.STRING
			case URI_PATH:
				return OptionFormat.STRING
			case CONTENT_FORMAT:
				return OptionFormat.UINT
			case MAX_AGE:
				return OptionFormat.UINT
			case URI_QUERY:
				return OptionFormat.STRING
			case ACCEPT:
				return OptionFormat.UINT
			case LOCATION_QUERY:
				return OptionFormat.STRING
			case PROXY_URI:
				return OptionFormat.STRING
			case PROXY_SCHEME:
				return OptionFormat.STRING
			case SIZE1:
				return OptionFormat.UINT
			case TOKEN:
				return OptionFormat.OPAQUE
			default:
				return OptionFormat.UNKNOWN
		}
	}
	
	def static Option getDefaultOption(int optionNumber) {
		switch(optionNumber) {
			case IF_MATCH:
				return new Option ("", IF_MATCH)
			case URI_HOST:
				return null
			case ETAG:
				return new Option (newByteArrayOfSize(0), ETAG)
			case IF_NONE_MATCH:
				return new Option ("", IF_NONE_MATCH)
			case OBSERVE:
				return new Option (0, OBSERVE)
			case URI_PORT:
				return null
			case LOCATION_PATH:
				return new Option ("", LOCATION_PATH)
			case URI_PATH:
				return new Option ("", URI_PATH)
			case CONTENT_FORMAT:
				return new Option (0, CONTENT_FORMAT)
			case MAX_AGE:
				return new Option (60, MAX_AGE)
			case URI_QUERY:
				return new Option ("", URI_QUERY)
			case ACCEPT:
				return new Option (0, ACCEPT)
			case LOCATION_QUERY:
				return new Option ("", LOCATION_QUERY)
			case PROXY_URI:
				return new Option ("", PROXY_URI)
			case PROXY_SCHEME:
				return new Option ("", PROXY_SCHEME)
			case SIZE1:
				return new Option (0, SIZE1)
			case TOKEN:
				return new Option (newByteArrayOfSize(0), TOKEN)
			default:
				return null
		}
	}
}