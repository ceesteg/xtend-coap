package com.xtend.coap.utils

import java.nio.ByteBuffer
import java.util.Random

import com.xtend.coap.endpoint.Endpoint

class HexUtils {

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
    
    def static void main(String[] args) {
    	var random = new Random
		var lengthInt = random.nextInt(4) + 1
		var lengthLong = random.nextInt(4) + 5
		var tokL = HexUtils.longToBytes(Endpoint.generateToken(lengthLong), lengthLong)
		System.out.println(HexUtils.hex(HexUtils.intToBytes(Endpoint.generateToken(lengthInt).intValue, lengthInt)))
    	System.out.println(HexUtils.hex(tokL))
    	System.out.println(HexUtils.bytesToLong(tokL))
    }
	
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