package com.xtend.coap.utils

import java.nio.ByteBuffer

/**
 * Class for hexadecimal operations. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class HexUtils {

	/**
	 * Converts a long number to a numBytes-length byte array.
	 * 
	 * @param number Long value of the number to be converted.
	 * @param numBytes The number of bytes to represent the number.
	 * @return The number as byte array.
	 */
    def static byte[] longToBytes(long number, int numBytes) {
    	var buffer = ByteBuffer.allocate(8)
        buffer.putLong(0, number)
        var array = buffer.array
        var byte[] aux = newByteArrayOfSize(numBytes)
        var n = numBytes - 1
		for (var i = 7; i > 8 - numBytes -1; i--) {  
    		aux.set(n, array.get(i))
    		n--
		}		 
        return aux
    }

	/**
	 * Converts a byte array to a long number.
	 * 
	 * @param bytes The byte array representation of the number.
	 * @return The long value of the number.
	 */
    def static long bytesToLong(byte[] bytes) {
    	var buffer = ByteBuffer.allocate(8)
		for (var i=0; i < 8 - bytes.length; i++) {
			buffer.put(0.byteValue)
		}
		for (var i=0; i < bytes.length; i++) {
			buffer.put(bytes.get(i))
		}
		return buffer.getLong(0)
    }
    
    /**
	 * Converts an integer number to a numBytes-length byte array.
	 * 
	 * @param number Integer value of the number to be converted.
	 * @param numBytes The number of bytes to represent the number.
	 * @return The number as byte array.
	 */
    def static byte[] intToBytes(int number, int numBytes) {
    	var buffer = ByteBuffer.allocate(4)
        buffer.putInt(0, number)
        var array = buffer.array
        var byte[] aux = newByteArrayOfSize(numBytes)
        var n = numBytes - 1
		for (var i = 3; i > 4 - numBytes -1; i--) {  
    		aux.set(n, array.get(i))
    		n--
		}		 
        return aux
    }

	/**
	 * Converts a byte array to a integer number.
	 * 
	 * @param bytes The byte array representation of the number.
	 * @return The integer value of the number.
	 */
    def static int bytesToInt(byte[] bytes) {
    	var buffer = ByteBuffer.allocate(4)
        for (var i = 0; i < 4 - bytes.length; i++) {
			buffer.put(0.byteValue)
		}
		for (var i = 0; i < bytes.length; i++) {
			buffer.put(bytes.get(i))
		}
		return buffer.getInt(0)
    }

	/**
	 * Hexadecimal representation of a byte array.
	 * 
	 * @param data The byte array to represent in hexadecimal.
	 * @return String representation of the byte array.
	 */	
	def static String hex(byte[] data) {
		val digits = "0123456789ABCDEF"
		if (data != null) {
			if (bytesToLong(data) == 0) {
				return "00"
			}
			var length = data.length
			var builder = new StringBuilder(length * 3);
			for (var i = 0; i < length; i++) {
				builder.append(digits.charAt(data.get(i).operator_doubleGreaterThan(4).bitwiseAnd(0xF)))
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
}