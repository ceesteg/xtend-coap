package xtend.coap.layers

import java.io.IOException
import java.util.HashMap
import java.util.Map

import xtend.coap.message.Message
import xtend.coap.message.response.Response
import xtend.coap.message.request.GetRequest
import xtend.coap.utils.Option

class TransferLayer extends UpperLayer {
	
	private static int DEFAULT_BLOCK_SIZE = 512

	private Map<Integer, Message> incomplete = new HashMap<Integer, Message>
	
	private Map<Message, Message> partialOut = new HashMap<Message, Message>
	
	def static void decodeBlock(Option blockOpt) {
		var value = blockOpt.getIntValue
		var szx = value.bitwiseAnd(0x7)
		var m   = value.operator_doubleGreaterThan(3).bitwiseAnd(0x1)
		var num = value.operator_doubleGreaterThan(4)
		var size = 1.operator_doubleLessThan(szx + 4)
		System.out.println("NUM: " + num + ", SZX: " + szx + " (" + size + " bytes), M: " + m)
	}
	
	def static Option encodeBlock(int num, int szx, int m) {
		var value = 0
		value = value.bitwiseOr(szx.bitwiseAnd(0x7))    
		value = value.bitwiseOr(m.bitwiseAnd(0x1).operator_doubleLessThan(3))
		value = value.bitwiseOr(num.operator_doubleLessThan(4))
		return new Option(value, Option.BLOCK)
	}

	def private static Message getBlock(Message msg, int num, int szx) {
		var blockSize = 1.operator_doubleLessThan(szx + 4)
		var payloadOffset = num * blockSize
		var payloadLeft = msg.payloadSize - payloadOffset
		if (payloadLeft > 0) {
			var Message block = null
			try {
				block = msg.getClass.newInstance
			} catch (Exception e) {
				e.printStackTrace
				return null
			}
			block.setType(msg.getType)
			block.setCode(msg.getCode)
			block.setURI(msg.getURI) 
			var m = 0
			if(blockSize < payloadLeft){
				m = 1
			}
			if (m == 0) {
				blockSize = payloadLeft
			}
			var blockPayload = newByteArrayOfSize(blockSize)
			System.arraycopy(msg.getPayload, payloadOffset, blockPayload, 0, blockSize)
			block.setPayload(blockPayload)
			var value = 0
			value = value.bitwiseOr(szx.bitwiseAnd(0x7))
			value = value.bitwiseOr(m.bitwiseAnd(0x1).operator_doubleLessThan(3))
			value = value.bitwiseOr(num.operator_doubleLessThan(4))
			var Option blockOpt = null
			if (msg.isRequest) {
				blockOpt = new Option(value, Option.BLOCK1)
			} else {
				blockOpt = new Option(value, Option.BLOCK2)
			}
			block.setOption(blockOpt)
			return block
		} else {
			return null
		}
	}
	
	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg.payloadSize > DEFAULT_BLOCK_SIZE) {
			var block = getBlock(msg, 0, 5)
			partialOut.put(block, msg)
			sendMessageOverLowerLayer(block)
		} else {
			sendMessageOverLowerLayer(msg)
		}
	}
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		var blockOpt = msg.getFirstOption(Option.BLOCK)
		if (blockOpt != null) {
			var value = blockOpt.getIntValue
			var szx = value.bitwiseAnd(0x7)
			var m   = value.operator_doubleGreaterThan(3).bitwiseAnd(0x1)
			var num = value.operator_doubleGreaterThan(4)
			var tokenOpt = msg.getFirstOption(Option.TOKEN)
			if (tokenOpt != null) {
				var token = tokenOpt.getIntValue
				if (m != 0) {
					if (msg instanceof Response) {
						if ( true || (msg as Response).getRequest instanceof GetRequest) {
							var request = new GetRequest
							request.setOption(tokenOpt)
							request.setOption(encodeBlock(num+1, szx, 0))
							try {
								sendMessageOverLowerLayer(request)
							} catch (IOException e) {
								System.err.println("[" + getClass.getName + "] Failed to request next block for T" + token + ": " + e.getMessage)
							}
						}
					}
				}
				if (num == 0 && m != 0) {
					incomplete.put(token, msg)
					System.out.println("[" + getClass.getName + "] Blockwise transfer of T" + token + " initiated")
				} else {
					var first = incomplete.get(token)
					System.out.println("[" + getClass.getName + "] Receiving block #" + token + " of T" + token)
					first.appendPayload(msg.getPayload)
					if (m == 0) {
						System.out.println("[" + getClass.getName + "] Blockwise transfer of T" + token + " completed")
						incomplete.remove(token)
						first.setComplete(true)
					}
				}
			} else {
				System.err.println("[" + getClass.getName + "] ERROR: Token missing for blockwise receiving of " + msg.key)
			}
		}
		deliverMessage(msg)
	}
}