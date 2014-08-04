package xtend.coap.layers

import java.net.DatagramSocket
import java.net.DatagramPacket
import java.net.SocketException
import java.io.IOException
import java.util.Arrays
import java.net.URI
import java.net.URISyntaxException

import xtend.coap.message.Message

class UDPLayer extends Layer {

	// CoAP specific constants /////////////////////////////////////////////////
	
	val public static DEFAULT_PORT      = 5683
	val public static String URI_SCHEME_NAME = "coap"
	val public static RX_BUFFER_SIZE    = 1024
	
	DatagramSocket socket
	ReceiverThread receiverThread	
	
		// Constructors ////////////////////////////////////////////////////////////
	
	/*
	 * Constructor for a new UDP layer
	 * 
	 * @param port The local UDP port to listen for incoming messages
	 */	
	new (int port, boolean daemon) throws SocketException {
		this.socket = new DatagramSocket(port)
		this.receiverThread = new ReceiverThread(this)
		receiverThread.setDaemon(daemon)
		this.receiverThread.start
	}

	/*
	 * Constructor for a new UDP layer
	 * 
	 */	
    new () throws SocketException {
		this(0, true) 
	}

	// Inner Classes ///////////////////////////////////////////////////////////
	
	static class ReceiverThread extends Thread {
		
		UDPLayer udpLayer
	
		new(UDPLayer udpLayer){
			this.udpLayer = udpLayer
		}
		
		@Override
		override public void run() {
			while (true) {
				var buffer = newByteArrayOfSize(RX_BUFFER_SIZE)
				var datagram = new DatagramPacket(buffer, buffer.length)
				try {
					udpLayer.getSocket.receive(datagram)
				} catch (IOException e) {
					e.printStackTrace
				}
				udpLayer.datagramReceived(datagram)
			}
		}
	}
	
	
	// Commands ////////////////////////////////////////////////////////////////
	
	def getSocket(){
		return socket
	}
	
	/*
	 * Decides if the listener thread persists after the main thread terminates
	 * 
	 * @param on True if the listener thread should stay alive after the main
	 * thread terminates. This is useful for e.g. server applications
	 */
	def setDaemon(boolean on) {
		receiverThread.setDaemon(on)
	}
	
	// Queries /////////////////////////////////////////////////////////////////

	/*
	 * Checks whether the listener thread persists after the main thread 
	 * terminates
	 * 
	 * @return True if the listener thread stays alive after the main
	 * thread terminates. This is useful for e.g. server applications
	 */
	def isDaemon() {
		return receiverThread.isDaemon
	}
	
	def getPort() {
		return socket.getLocalPort
	}	

	// I/O implementation //////////////////////////////////////////////////////
	
	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		var uri = msg.getURI
		var address = msg.getAddress
		var port = -1
		if(uri != null){
			port = uri.getPort
		}
		if (port < 0){
			port = DEFAULT_PORT
		}
		var payload = msg.toByteArray
		var datagram = new DatagramPacket(payload, payload.length, address, port)
		msg.setTimestamp(System.currentTimeMillis)
		socket.send(datagram)
	}

	@Override
	override protected void doReceiveMessage(Message msg) {
		deliverMessage(msg)
	}

	
	// Internal ////////////////////////////////////////////////////////////////
	
	def datagramReceived(DatagramPacket datagram) {
		var timestamp = System.currentTimeMillis()
		var data = Arrays.copyOfRange(datagram.getData, datagram.getOffset, datagram.getLength) 
		var msg = Message.fromByteArray(data)
		msg.setTimestamp(timestamp)
		var scheme = URI_SCHEME_NAME
		var String 	userInfo 	= null
		var host = datagram.getAddress.getHostAddress
		var port = datagram.getPort
		var String path = null
		var String query = null
		var String fragment = null
		try {
			msg.setURI(new URI(scheme, userInfo, host, port, path, query, fragment))
		} catch (URISyntaxException e) {
			System.out.println("[" + getClass.getName + "] Failed to build URI for incoming message: " +  e.getMessage)
		}
		receiveMessage(msg)
	}
}