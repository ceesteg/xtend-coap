package com.xtend.coap.utils

import java.io.UnsupportedEncodingException
import java.nio.ByteBuffer

/**
 * Class for CoAP Message Options as defined in rfc7252, section 12.2 and draft-ietf-core-observe-14, section 2. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class Option {
	
	val public static IF_MATCH       = 1
	val public static URI_HOST       = 3
	val public static ETAG           = 4
	val public static IF_NONE_MATCH  = 5
	val public static OBSERVE        = 6 
	val public static URI_PORT       = 7
	val public static LOCATION_PATH  = 8
	val public static URI_PATH       = 11
	val public static CONTENT_FORMAT = 12
	val public static MAX_AGE        = 14
	val public static URI_QUERY      = 15
	val public static ACCEPT         = 17
	val public static LOCATION_QUERY = 20
	val public static PROXY_URI      = 35
	val public static PROXY_SCHEME   = 39
	val public static SIZE1          = 60
	
	ByteBuffer value
	int optionNumber
	
	/**
	 * Initializes a new Option object.
	 * 
	 * @param raw Value as byte array.
	 * @param number Option number.
	 */
	new (byte[] raw, int number) {
		value = ByteBuffer.wrap(raw)
		optionNumber = number
	}

	/**
	 * Initializes a new Option object.
	 * 
	 * @param str Value as string.
	 * @param number Option number.
	 */
	new (String str, int number) {
		value = ByteBuffer.wrap(str.getBytes)
		optionNumber = number
	}
	
	/**
	 * Initializes a new Option object.
	 * 
	 * @param value Value as integer.
	 * @param number Option number.
	 */
	new (int value, int number) {
		setIntValue(value)
		optionNumber = number
	}
	
	/**
	 * Sets the value with an integer value.
	 * 
	 * @param value Value as integer.
	 */
	def private void setIntValue(int value) {
		var aux = HexUtils.intToBytes(value, 4)
		this.value = ByteBuffer.allocate(4).put(aux, 0, aux.length)
	}
	
	/**
	 * Sets the number of the current option.
	 * 
	 * @param number The option number.
	 */
	def setOptionNumber (int number) {
		optionNumber = number
	}
	
	/**
	 * Sets the value of the current option.
	 * 
	 * @param value Value as byte array.
	 */
	def setValue (byte[] value) {
		this.value = ByteBuffer.wrap(value)
	}
	
	/**
	 * Method that returns the data of the current option as byte array.
	 * 
	 * @return The byte array holding the data
	 */
	def getRawValue() {
		return value.array
	}

	/**
	 * Method that returns the hash code of the current option.
	 * 
	 * @return The hash code.
	 */
	override hashCode() {
		val prime = 31
		var result = 1
		result = prime * result + optionNumber
		var aux = 0
		if (value == null) {
			aux = 0
		} else {
			aux = value.hashCode
		}
		result = prime * result + aux
		return result
	}
	
	/**
	 * Method to compare the current option with another option.
	 * 
	 * @param obj The option to compare with.
	 * @return Returns true if equal and false if not.
	 */
	override equals(Object obj) {
		var res = false
		if (obj != null) {
			var other = obj as Option
			if (optionNumber == other.optionNumber) {
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

	/**
	 * Method that returns the option number of the current option.
	 * 
	 * @return The option number as integer.
	 */
	def getOptionNumber() {
		return optionNumber
	}
	
	/**
	 * Method that returns the name of to the option number.
	 * 
	 * @return The name of the option.
	 */
	def String getName() {
		return toString(optionNumber)
	}

	/**
	 * Method that returns the length of the option's value.
	 * 
	 * @return The length of the data stored in the value ByteBuffer.
	 */
	def getLength() {
		return value.capacity
	}
	
	/**
	 * Method that returns the current option's value as string.
	 * 
	 * @return The string representation of the current option's value.
	 */
	def getStringValue() {
		var result = ""
		try {
			result = new String(value.array, "UTF8")
		} catch (UnsupportedEncodingException e) {
			System.err.println("String conversion error")
		}
		return result
	}
	
	/**
	 * Method that returns the current option's value as integer.
	 * 
	 * @return The integer representation of the current option's value.
	 */
	def getIntValue () {
		return HexUtils.bytesToInt(value.array)
	}
	
	/**
	 * Method that returns the current option's value as byte array.
	 * 
	 * @return The current option's value as byte array.
	 */
	def getValue () {
		return value
	}

	/**
	 * Returns a human-readable string representation of the option's value.
	 * 
	 * @Return The option value represented as a string.
	 */
	def getDisplayValue() {
		switch (optionNumber) {
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
			default:
				return HexUtils.hex(getRawValue)
		}
	}

	/**
	 * Returns a human-readable string representation of the option's name.
	 * 
	 * @Return The option name.
	 */
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
			default:
				return "Unknown option number " + optionNumber
		}
	}
	
	/**
	 * Returns the option format value represented by the optionNumber param.
	 * 
	 * @param optionNumber Number of the option as integer.
	 * @Return The option number value of the option.
	 */
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
			default:
				return OptionFormat.UNKNOWN
		}
	}
	
	/**
	 * Returns an option with the default value.
	 * 
	 * @param optionNumber Number of the option as integer.
	 * @Return The default option generated.
	 */
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
			default:
				return null
		}
	}
}