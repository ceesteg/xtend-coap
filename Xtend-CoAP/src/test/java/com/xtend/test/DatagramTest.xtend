package com.xtend.test

import static org.junit.Assert.*
import org.junit.Test

import java.nio.ByteBuffer
import java.nio.ByteOrder

import com.xtend.coap.utils.DatagramUtils

class DatagramTest {
	
	@Test
	def test32BitInt() {
		val intIn = 0x87654321
		var writer = new DatagramUtils(null)
		writer.write(intIn, 32)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(32)
		assertEquals(intIn, intOut)
	}
	
	@Test
	def test32BitIntZero() {
		val intIn = 0x00000000
		var writer = new DatagramUtils(null)
		writer.write(intIn, 32)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(32)
		assertEquals(intIn, intOut)
	}
	
	@Test
	def test32BitIntOne() {
		val intIn = 0xFFFFFFFF
		var writer = new DatagramUtils(null)
		writer.write(intIn, 32)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(32)
		assertEquals(intIn, intOut)
	}		
	
	@Test
	def test16BitInt() {
		val intIn = 0x00004321
		var writer = new DatagramUtils(null)
		writer.write(intIn, 16)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(16)
		assertEquals(intIn, intOut)
	}	
	
	@Test
	def test8BitInt() {	
		val intIn = 0x00000021
		var writer = new DatagramUtils(null)
		writer.write(intIn, 8)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(8)
		assertEquals(intIn, intOut)
	}
	
	@Test
	def test4BitInt() {
		val intIn = 0x0000005
		var writer = new DatagramUtils(null)
		writer.write(intIn, 4)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(4)
		assertEquals(intIn, intOut)
	}	
	
	@Test
	def test2BitInt() {
		val intIn = 0x00000002
		var writer = new DatagramUtils(null)
		writer.write(intIn, 2)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(2)
		assertEquals(intIn, intOut)
	}
	
	@Test
	def test1BitInt() {
		val intIn = 0x00000001
		var writer = new DatagramUtils(null)
		writer.write(intIn, 1)
		var reader = new DatagramUtils(writer.toByteArray)
		var intOut = reader.read(1)
		assertEquals(intIn, intOut)
	}	
	
	@Test
	def testByteOrder() {
		val intIn = 1234567890
		var writer = new DatagramUtils(null)
		writer.write(intIn, 32)
		val data = writer.toByteArray
		var buf = ByteBuffer.wrap(data)
		buf.order(ByteOrder.BIG_ENDIAN)
		var intTrans = buf.getInt
		var reader = new DatagramUtils(data)
		var intOut = reader.read(32)
		assertEquals(intIn, intTrans)
		assertEquals(intIn, intOut)
	}
	
	@Test
	def testAlignedBytes() {
		val bytesIn = "Some aligned Bytes".getBytes
		var writer = new DatagramUtils(null)
		writer.writeBytes(bytesIn)
		var reader = new DatagramUtils(writer.toByteArray)
		var bytesOut = reader.readBytes(bytesIn.length)
		assertArrayEquals(bytesIn, bytesOut)
	}
	
	@Test
	def testUnalignedBytes1() {
		val bitCount = 1
		val bitsIn = 0x1
		val bytesIn = "Some unaligned Bytes".getBytes
		var writer = new DatagramUtils(null)
		writer.write(bitsIn, bitCount)
		writer.writeBytes(bytesIn)
		var reader = new DatagramUtils(writer.toByteArray)
		var bitsOut = reader.read(bitCount)
		var bytesOut = reader.readBytes(bytesIn.length)
		assertEquals(bitsIn, bitsOut)
		assertArrayEquals(bytesIn, bytesOut)
	}
	
	@Test
	def testUnalignedBytes3() {
		val bitCount = 3
		val bitsIn = 0x5
		val bytesIn = "Some unaligned Bytes".getBytes
		var writer = new DatagramUtils(null)
		writer.write(bitsIn, bitCount)
		writer.writeBytes(bytesIn)
		var reader = new DatagramUtils(writer.toByteArray)
		var bitsOut = reader.read(bitCount)
		var bytesOut = reader.readBytes(bytesIn.length)
		assertEquals(bitsIn, bitsOut)
		assertArrayEquals(bytesIn, bytesOut)
	}
	
	@Test
	def testUnalignedBytes7() {
		val bitCount = 7
		val bitsIn = 0x69
		val bytesIn = "Some unaligned Bytes".getBytes
		var writer = new DatagramUtils(null)
		writer.write(bitsIn, bitCount)
		writer.writeBytes(bytesIn)
		var reader = new DatagramUtils(writer.toByteArray)
		var bitsOut = reader.read(bitCount)
		var bytesOut = reader.readBytes(bytesIn.length)
		assertEquals(bitsIn, bitsOut)
		assertArrayEquals(bytesIn, bytesOut)
	}
	
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
	def testBytesLeftUnaligned() {
		val bitCount = 7
		val bitsIn = 0x55
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