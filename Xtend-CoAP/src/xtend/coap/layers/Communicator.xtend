package xtend.coap.layers

import java.io.IOException
import java.net.SocketException

import xtend.coap.message.Message
import xtend.coap.message.response.Response
import xtend.coap.message.request.Request
 
class Communicator extends UpperLayer {

	public final static int DEFAULT_PORT = UDPLayer.DEFAULT_PORT
	public final static String URI_SCHEME_NAME = UDPLayer.URI_SCHEME_NAME
	
	protected TransferLayer transferLayer
	protected TransactionLayer transactionLayer
	protected MessageLayer messageLayer
	protected UDPLayer udpLayer
	
	// Constructors ////////////////////////////////////////////////////////////
	
	/*
	 * Constructor for a new Communicator
	 * 
	 * @param port The local UDP port to listen for incoming messages
	 */	
	new(int port, boolean daemon) throws SocketException {
		transferLayer = new TransferLayer
		transactionLayer = new TransactionLayer
		messageLayer = new MessageLayer
		udpLayer = new UDPLayer(port, daemon)
		buildStack
	}

	/*
	 * Constructor for a new Communicator
	 * 
	 */
	new() throws SocketException {
		this(0, true)
	}
	
	// Internal ////////////////////////////////////////////////////////////////
	
	/*
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
	
	// I/O implementation //////////////////////////////////////////////////////
	
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
