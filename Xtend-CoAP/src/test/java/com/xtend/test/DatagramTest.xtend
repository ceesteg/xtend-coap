package com.xtend.test

import static org.junit.Assert.*
import org.junit.Test

import com.xtend.coap.utils.DatagramUtils

class DatagramTest {

	@Test
	def testBytesLeft() {
		val bitCount = 8
		val bitsIn = 0xAA
		val bytesIn = "Some payload".getBytes
		var writer = new DatagramUtils(null)
		writer.write(bitsIn, bitCount)
		writer.writeBytes(bytesIn)
		var reader = new DatagramUtils(writer.toByteArray)
		var bitsOut = reader.read(bitCount)
		var bytesOut = reader.readBytesLeft
		assertEquals(bitsIn, bitsOut)
		assertArrayEquals(bytesIn, bytesOut)
	}
	
	@Test
	def testGETRequestHeader() {
		val versionIn = 1
		val versionSz = 2
		val typeIn = 0 
		val typeSz = 2
		val optionCntIn = 1
		val optionCntSz = 4
		val codeIn = 1 
		val codeSz = 8
		val msgIdIn = 0x1234
		val msgIdSz = 16
		var writer = new DatagramUtils(null)
		writer.write(versionIn, versionSz)
		writer.write(typeIn, typeSz)
		writer.write(optionCntIn, optionCntSz)
		writer.write(codeIn, codeSz)
		writer.write(msgIdIn, msgIdSz)
		val data = writer.toByteArray
		val dataRef = #[0x41.byteValue, 0x01.byteValue, 0x12.byteValue, 0x34.byteValue]
		var reader = new DatagramUtils(data)
		var versionOut = reader.read(versionSz)
		var typeOut = reader.read(typeSz)
		var optionCntOut = reader.read(optionCntSz)
		var codeOut = reader.read(codeSz)
		var msgIdOut = reader.read(msgIdSz)
		assertArrayEquals(dataRef, data)
		assertEquals(versionIn, versionOut)
		assertEquals(typeIn, typeOut)
		assertEquals(optionCntIn, optionCntOut)
		assertEquals(codeIn, codeOut)
		assertEquals(msgIdIn, msgIdOut)
	}
}