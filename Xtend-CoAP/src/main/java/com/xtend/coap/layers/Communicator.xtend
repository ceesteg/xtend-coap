package com.xtend.coap.layers

import java.io.IOException
import java.net.SocketException

import com.xtend.coap.message.Message
import com.xtend.coap.message.response.Response
import com.xtend.coap.message.request.Request
 
/** 
 * Class that represents a CoAP Communicator.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */ 
class Communicator extends UpperLayer {

	public final static int DEFAULT_PORT = UDPLayer.DEFAULT_PORT
	public final static String URI_SCHEME_NAME = UDPLayer.URI_SCHEME_NAME
	
	protected TransactionLayer transactionLayer
	protected MessageLayer messageLayer
	protected UDPLayer udpLayer

	/**
	 * Constructor for a new Communicator
	 * 
	 * @param port The local UDP port to listen for incoming messages
	 */	
	new(int port, boolean daemon) throws SocketException {
		transactionLayer = new TransactionLayer
		messageLayer = new MessageLayer
		udpLayer = new UDPLayer(port, daemon)
		buildStack
	}

	/**
	 * Constructor for a new Communicator
	 * 
	 */
	new() throws SocketException {
		this(0, true)
	}
	
	/**
	 * This method connects the layers in order to build the communication stack
	 * 
	 * It can be overridden by subclasses in order to add further layers, e.g.
	 * for introducing a layer that drops or duplicates messages by a
	 * probabilistic model in order to evaluate the implementation.
	 */
	def protected void buildStack() {
		this.setLowerLayer(transactionLayer)
		transactionLayer.setLowerLayer(messageLayer)
		messageLayer.setLowerLayer(udpLayer)
		
	}
	
	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		sendMessageOverLowerLayer(msg)
	}	
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		if (msg instanceof Response) {
			var response = msg as Response
			response.handle
		} else if (msg instanceof Request) {
			var request = msg as Request
			request.setCommunicator(this)
		}	
		deliverMessage(msg)
	}
	
	def port() {
		return udpLayer.getPort
	}
}
