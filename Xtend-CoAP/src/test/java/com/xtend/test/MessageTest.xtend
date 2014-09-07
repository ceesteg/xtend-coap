package com.xtend.test

import static org.junit.Assert.*
import org.junit.Test

import com.xtend.coap.message.Message
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.MessageType
import com.xtend.coap.utils.Option

class MessageTest {
	
	@Test
	def void testMessage() {
		var msg = new Message
		msg.setCode(Code.METHOD_GET)
		msg.setType(MessageType.CONFIRMABLE)
		msg.setID(12345)
		msg.setPayload("some payload".getBytes)
		System.out.println(msg.toString)		
		var data = msg.toByteArray
		var convMsg = Message::fromByteArray(data)
		assertEquals(msg.getCode, convMsg.getCode)
		assertEquals(msg.getType, convMsg.getType)
		assertEquals(msg.getID, convMsg.getID)
	}
	
	@Test
	def void testOptionMessage() {
		var msg = new Message		
		msg.setCode(Code.METHOD_GET)
		msg.setType(MessageType.CONFIRMABLE)
		msg.setID(12345)
		msg.setPayload("hallo".getBytes)
		msg.addOption(new Option ("a".getBytes, 1))
		msg.addOption(new Option ("b".getBytes, 2))		
		var data = msg.toByteArray
		var convMsg = Message::fromByteArray(data)
		assertEquals(msg.getCode, convMsg.getCode)
		assertEquals(msg.getType, convMsg.getType)
		assertEquals(msg.getID, convMsg.getID)
		assertEquals(msg.getOptionCount, convMsg.getOptionCount)
		assertArrayEquals(msg.getPayload, convMsg.getPayload)
	}
	
	@Test
	def void testExtendedOptionMessage() {
		var msg = new Message 
		msg.setCode(Code.METHOD_GET)
		msg.setType(MessageType.CONFIRMABLE)
		msg.setID(12345)
		msg.addOption(new Option ("c".getBytes, 211))
		var data = msg.toByteArray
		var convMsg = Message.fromByteArray(data)
		assertEquals(msg.getCode, convMsg.getCode)
		assertEquals(msg.getType, convMsg.getType)
		assertEquals(msg.getID, convMsg.getID)
		assertEquals(msg.getOptionCount, convMsg.getOptionCount)
	}
	
	def static String getHexString(byte[] b) throws Exception {
		var result = ""
		for (var i=0 ; i < b.length ; i++) {
		    result += Integer.toString(( b.get(i).bitwiseAnd(0xff)) + 0x100, 16).substring( 1 )
		}
		return result
	}
}