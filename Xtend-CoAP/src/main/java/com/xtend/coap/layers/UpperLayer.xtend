package com.xtend.coap.layers

import java.io.IOException

import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageReceiver

public abstract class UpperLayer extends Layer {
	
	Layer lowerLayer
	
	def sendMessageOverLowerLayer(Message msg) throws IOException {
		if (lowerLayer != null) {
			lowerLayer.sendMessage(msg)
		} else {
			System.out.println("[" + getClass.getName + "] ERROR: No lower layer present")
		}
	}
	
	def setLowerLayer(Layer layer) {
		if (lowerLayer != null) {
			lowerLayer.unregisterReceiver(this as MessageReceiver)
		}
		lowerLayer = layer
		if (lowerLayer != null) {
			lowerLayer.registerReceiver(this as MessageReceiver)
		}
	}
	
	def getLowerLayer() {
		return lowerLayer
	}
}