package com.xtend.example

import com.sun.net.httpserver.HttpServer
import java.net.SocketException
import java.net.InetSocketAddress
import com.xtend.coap.endpoint.BaseHTTP2CoAPProxy
import com.xtend.coap.message.MessageSender

class SampleHTTP2CoAPProxy extends BaseHTTP2CoAPProxy{
	
	new(int port, boolean daemon) throws SocketException {
		super(port, daemon)
	}
	
    def static void main(String[] args) throws Exception {
    	try {
    		var server = HttpServer.create(new InetSocketAddress(8000), 0)
			var BaseHTTP2CoAPProxy proxy = new SampleHTTP2CoAPProxy(MessageSender.DEFAULT_PORT + 2, false)
			server.createContext("/", proxy)
	        server.setExecutor(null)
	        server.start
			System.out.println("Sample HTTP to CoAP proxy listening at port " + 8000 + ".")
		} catch (SocketException e) {
			System.err.printf("Failed to create Sample HTTP to CoAP proxy: " + e.getMessage)
			return
		}
    }
}