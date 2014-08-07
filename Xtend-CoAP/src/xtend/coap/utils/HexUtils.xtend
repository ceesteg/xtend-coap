package xtend.coap.utils

import java.nio.ByteBuffer

class HexUtils {
	def static ByteBuffer bufferIntValue(int valueAux) {
		var ByteBuffer value = null
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
		return value
	}
	
	def static int getIntValue (ByteBuffer value) {
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
	
	def static String hex(byte[] data) {
		val digits = "0123456789ABCDEF"
		if (data != null) {
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