package xtend.test

import static org.junit.Assert.*
import org.junit.Test
import xtend.coap.utils.Option

class OptionTest {
	
	@Test
	def testRawOption() {
		var dataRef = "test".getBytes
		var nrRef = 1
		var opt = new Option(dataRef, nrRef)
		assertArrayEquals(dataRef, opt.getRawValue)
		assertEquals(dataRef.length, opt.getLength)
	}
	
	@Test
	def testIntOption() {
		var oneByteValue = 255 
		var twoBytesValue = 256 
		var nrRef = 1
		var optOneByte = new Option(oneByteValue, nrRef)
		var optTwoBytes = new Option(twoBytesValue, nrRef)
		assertEquals(1, optOneByte.getLength)
		assertEquals(2, optTwoBytes.getLength)
		assertEquals(255, optOneByte.getIntValue)
		assertEquals(256, optTwoBytes.getIntValue)
	}
	
	@Test
	def testStringOption() {
		var strRef = "test"
		var nrRef = 1
		var opt = new Option(strRef, nrRef)
		assertEquals(strRef, opt.getStringValue)
		assertEquals(strRef.getBytes.length, opt.getLength)
	}
	
	@Test
	def testOptionNr() {
		var dataRef = "test".getBytes
		var nrRef = 1
		var opt = new Option(dataRef, nrRef)
		assertEquals(nrRef, opt.getOptionNumber)
	}
	
	@Test
	def equalityTest() {
		var oneByteValue = 255 
		var twoBytesValue = 256 
		var nrRef = 1
		var optOneByte = new Option(oneByteValue, nrRef)
		var optTwoBytes = new Option(twoBytesValue, nrRef)
		var optTwoBytesRef = new Option(twoBytesValue, nrRef)
		assertTrue(optTwoBytes.equals(optTwoBytesRef))
		assertFalse(optTwoBytes.equals(optOneByte))
	}
	
	def static String getHexString(byte[] b) throws Exception {
		var result = ""
		for (var i=0; i < b.length; i++) {
		    result += Integer.toString(b.get(i).bitwiseAnd(0xff) + 0x100, 16).substring(1)
		}
		return result
	}
}