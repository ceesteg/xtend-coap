package com.xtend.example

import com.xtend.coap.endpoint.BaseCoAP2HTTPProxy
import com.xtend.coap.message.MessageSender
import java.net.SocketException

class SampleCoAP2HTTPProxy extends BaseCoAP2HTTPProxy {
	
	new(int port, boolean daemon) throws SocketException {
		super(port, daemon)
	}
	
	def static void main(String[] args) {
		try {
			var BaseCoAP2HTTPProxy proxy = new SampleCoAP2HTTPProxy(MessageSender.DEFAULT_PORT, false)
			System.out.println("Sample CoAP to HTTP proxy listening at port " + proxy.port + ".")
		} catch (SocketException e) {
			System.err.printf("Failed to create Sample CoAP to HTTP proxy: " + e.getMessage)
			return
		}
	}
}