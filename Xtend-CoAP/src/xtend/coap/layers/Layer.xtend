package xtend.coap.layers

import java.util.List
import java.util.ArrayList
import java.io.IOException

import xtend.coap.message.Message
import xtend.coap.message.MessageReceiver

public abstract class Layer implements MessageReceiver {
		
	List<MessageReceiver> receivers
	int numMessagesSent
	int numMessagesReceived
	
	def sendMessage(Message msg) throws IOException {
		if (msg != null) {
			doSendMessage(msg)
			numMessagesSent++
		}
	}
	
	@Override
	override void receiveMessage(Message msg) {
		if (msg != null) {
			numMessagesReceived++
			doReceiveMessage(msg)
		}
	}
	
	def protected abstract void doSendMessage(Message msg) throws IOException 
	
	def protected abstract void doReceiveMessage(Message msg)
	
	def protected void deliverMessage(Message msg) {
		if (receivers != null) {
			for (MessageReceiver receiver : receivers) {
				receiver.receiveMessage(msg)
			}
		}
	}
	
	def registerReceiver(MessageReceiver receiver) {
		if (receiver != null && receiver != this) {
			if (receivers == null) {
				receivers = new ArrayList<MessageReceiver>
			}
			receivers.add(receiver)
		}
	}
	
	def unregisterReceiver(MessageReceiver receiver) {
		if (receivers != null) {
			receivers.remove(receiver)
		}
	}
	
	def getNumMessagesSent() {
		return numMessagesSent
	}
	
	def getNumMessagesReceived() {
		return numMessagesReceived
	}	
}