package com.xtend.coap.utils

import java.io.ByteArrayOutputStream
import java.io.ByteArrayInputStream

class DatagramUtils {
	
	ByteArrayInputStream byteInputStream
	ByteArrayOutputStream byteOutputStream  
	byte cByte  
	int cBitIx 
	
	/*
	 * Initializes a new BitReader object
	 * 
	 * @param byteArray The byte array to read from. If is null initializes byteOutputStream, else byteInputStream.
	 * 
	 */
	new (byte[] byteArray) {
		if (byteArray == null) {
			byteOutputStream = new ByteArrayOutputStream
			cByte = 0.byteValue
			cBitIx = Byte.SIZE-1
		} else {
			byteInputStream = new ByteArrayInputStream(byteArray)
			cByte = 0.byteValue
			cBitIx = -1
		}
	}
	
	/*
	 * Writes a sequence of bits to the stream
	 * 
	 * @param data An integer containing the bits to write
	 * @param nBits The number of bits to write
	 * 
	 */
	def write(int data, int nBits) {
		if (nBits < 32 && data >= (1.operator_doubleLessThan(nBits))) {
			System.out.println("[" + getClass.getName + "] Warning: Truncating value " + data + " to " + nBits + "-bit integer")
		}
		for (var i = nBits-1; i >= 0; i--) {
			var validBit = data.operator_doubleGreaterThan(i).bitwiseAnd(1) != 0
			if (validBit) {
				cByte = cByte.bitwiseOr(1.operator_doubleLessThan(cBitIx)).byteValue
			}
			cBitIx--
			if (cBitIx < 0) {
				writeCurrentByte
			}
		}
	}
	
	/*
	 * Writes a sequence of bytes to the stream
	 * 
	 * @param bytes The sequence of bytes to write
	 */
	def writeBytes(byte[] bytes) {
		if (bytes == null) {
			return
		}
		if (cBitIx < Byte.SIZE-1) {
			for (var i = 0; i < bytes.length; i++) {
				write(bytes.get(i), Byte.SIZE)
			}			
		} else {			
			byteOutputStream.write(bytes, 0, bytes.length)
		}
	}
	
	/*
	 * Reads a sequence of bits from the stream
	 * 
	 * @param numBits The number of bits to read
	 * @return An integer containing the bits read
	 * 
	 */
	def read(int nBits) {
		var bRead = 0; 
		for (var i = nBits-1; i >= 0; i--) {
			if (cBitIx < 0) {
				readCurrentByte
			}
			var validBit = cByte.operator_doubleGreaterThan(cBitIx).bitwiseAnd(1) != 0
			if (validBit) {
				bRead = bRead.bitwiseOr(1.operator_doubleLessThan(i))
			}
			cBitIx--;
		}
		return bRead;
	}
	
	
	/*
	 * Reads a sequence of bytes from the stream
	 * 
	 * @param nBytes The number of bytes to read
	 * @return The sequence of bytes read from the stream
	 * 
	 */
	def readBytes(int nBytes) {
		var n = nBytes
		if (n < 0) {
			n = byteInputStream.available
		}
		var bRead = newByteArrayOfSize(n)
		if (cBitIx >= 0) {
			for (var i = 0; i < n; i++) {
				bRead.set(i, read(Byte.SIZE).byteValue)
			}
		} else {
			byteInputStream.read(bRead, 0, bRead.length)
		}
		return bRead
	}
	
	/*
	 * Writes pending bits to the stream
	 */
	def private void writeCurrentByte() {
		if (cBitIx < Byte.SIZE-1) {
			byteOutputStream.write(cByte)
			cByte = 0.byteValue
			cBitIx = Byte.SIZE-1
		}
	}
	
	/*
	 * Reads new bits from the stream
	 */ 
	def private void readCurrentByte() {
		var value = byteInputStream.read
		if (value >= 0) {
			cByte = value.byteValue
		} else {
			cByte = 0.byteValue
		}
		cBitIx = Byte.SIZE-1
	}
	
	/*
	 * Reads the complete sequence of bytes left in the stream
	 * 
	 * @return The sequence of bytes left in the stream
	 * 
	 */
	def readBytesLeft() {
		return readBytes(-1)
	}
	
	/*
	 * Returns a byte array containing the sequence of bits written
	 * 
	 * @Return The byte array containing the written bits
	 */
	def toByteArray() {
		writeCurrentByte
		val byteArray = byteOutputStream.toByteArray
		byteOutputStream.reset
		return byteArray
	}
}

