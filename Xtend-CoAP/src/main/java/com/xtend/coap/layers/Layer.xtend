package com.xtend.coap.layers

import java.util.List
import java.util.ArrayList
import java.io.IOException

import com.xtend.coap.message.Message
import com.xtend.coap.message.MessageReceiver
import java.util.Map
import com.xtend.coap.message.request.Request
import java.util.HashMap
import com.xtend.coap.message.response.Response
import java.net.DatagramSocket
import java.net.SocketException
import java.net.DatagramPacket
import java.net.InetAddress
import com.xtend.coap.utils.Option
import java.net.URI
import java.net.URISyntaxException
import java.util.Arrays
import java.util.TimerTask
import java.util.LinkedHashMap
import java.util.Timer

/** 
 * Abstract class that represents a Layer.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
abstract class Layer implements MessageReceiver {
		
	List<MessageReceiver> receivers
	int numMessagesSent
	int numMessagesReceived
	
	/**
	 * Method to send a message
	 * 
	 * @param msg The message to be sent
	 */
	def sendMessage(Message msg) throws IOException {
		if (msg != null) {
			doSendMessage(msg)
			numMessagesSent++
		}
	}
	
	/**
	 * Method to receive a message-
	 * 
	 * @param msg The message received
	 */
	override void receiveMessage(Message msg) {
		if (msg != null) {
			numMessagesReceived++
			doReceiveMessage(msg)
		}
	}
	
	/**
	 * Must be implemented by other classes
	 */
	def protected abstract void doSendMessage(Message msg) throws IOException 
	
	/**
	 * Must be implemented by other classes
	 */
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
/** 
 * Abstract class that represents an Upper Layer.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
abstract class UpperLayer extends Layer {
	
	Layer lowerLayer
	
	def sendMessageOverLowerLayer(Message msg) throws IOException {
		if (lowerLayer != null) {
			lowerLayer.sendMessage(msg)
		} else {
			System.out.println("[" + getClass.getName + "] ERROR: No lower layer present")
		}
	}
	
	/**
	 * Method to set the lower layer
	 * 
	 * @param layer The lower layer
	 */	
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

/** 
 * Class that represents a Transaction Layer.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class TransactionLayer extends UpperLayer {
	
	Map<Long, Request> tokenMap
	
	new (){
		tokenMap = new HashMap<Long, Request>
	}

	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg instanceof Request) {
			var request = msg as Request
			request.setToken(request.getToken, request.getTokenLength)
			tokenMap.put(request.getToken, request)
		}
		sendMessageOverLowerLayer(msg)
	}	
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		var token = msg.getToken
		if (msg instanceof Response) {
			var response = msg as Response
			var request = tokenMap.get(token)
			if (request == null) {
				if (response.getBuddy instanceof Request) {
					request = response.getBuddy as Request
				}
			}
			if (response.isConfirmable) {
				try {
					var reply = response.newReply(request != null)
					sendMessageOverLowerLayer(reply)
				} catch (IOException e) {
					System.err.println("[" + getClass.getName + "] ERROR: Failed to reply to confirmable response: ")
					e.printStackTrace
				}
			}
			if (request != null) {
				response.setRequest(request)
			}
		} else if (msg instanceof Request) {
			if (token != 0x0) {
				tokenMap.put(token, msg as Request)
			}
		}
		deliverMessage(msg)
	}
}

/** 
 * Class that represents a Message Layer.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class MessageLayer extends UpperLayer { 
	
	val static ACK_TIMEOUT = 2000
	val static ACK_RANDOM_FACTOR = 1.5
	val static MAX_RETRANSMIT = 4
	val static MESSAGE_CACHE_SIZE = 100 
	
	Timer timer
	Map<Integer, TxContext> txTable
	MessageCache dupCache
	MessageCache replyCache
	
 	new () {
 		timer = new Timer(true) 
		txTable = new HashMap<Integer, TxContext>
		dupCache = new MessageCache
		replyCache = new MessageCache
 	}
	private static class TxContext { 
		Message msg
		RetransmitTask retransmitTask
		int numRetransmit
		int timeout
	}
	/**
	 * Utility class used for duplicate detection and reply retransmissions
	 */
	@SuppressWarnings("serial")
	private static class MessageCache extends LinkedHashMap<String, Message> {
		@Override
		override protected boolean removeEldestEntry(Map.Entry<String, Message> eldest) {
			return size > MESSAGE_CACHE_SIZE
		}
	}
	
	/**
	 * Utility class used to notify the Communicator class 
	 * about timed-out replies
	 */
	private static class RetransmitTask extends TimerTask {
		
		TxContext context
		MessageLayer messageLayer
		
		new(TxContext ctx, MessageLayer messageLayer) {
			this.context = ctx
			this.messageLayer = messageLayer
		}
			
		@Override
		override run() {
			messageLayer.handleResponseTimeout(context)
		}
	}
	
	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg.isConfirmable) {
			var ctx = addTransmission(msg)
			scheduleRetransmission(ctx)
		} else if (msg.isReply) {
			replyCache.put(msg.key, msg)
		}
		sendMessageOverLowerLayer(msg)
	}
	
	@Override
	override protected void doReceiveMessage(Message msg) {
		if (dupCache.containsKey(msg.key)) {
			if (msg.isConfirmable) {
				var reply = replyCache.get(msg.key)
				if (reply != null) {
					try {
						sendMessageOverLowerLayer(reply)
					} catch (IOException e) {
						e.printStackTrace
					}
					System.out.println("[" + getClass.getName + "] Replied to duplicate Confirmable: " + msg.key)
					return
				}
			}
		} else {
			dupCache.put(msg.key, msg)
		}
		if (msg.isReply) {
			var ctx = getTransmission(msg)
			if (ctx != null) {
				Message.matchBuddies(ctx.msg, msg)
				removeTransmission(ctx)
			} else {
				System.out.println("[" + getClass.getName + "] Unexpected reply dropped: " + msg.key)
				msg.log
				return
			}
		}
		deliverMessage(msg)
	}	
	
	def handleResponseTimeout(TxContext ctx) {
		if (ctx.numRetransmit < MAX_RETRANSMIT) {
			ctx.numRetransmit++
			System.out.println("[" + getClass.getName + "] Retransmitting " + ctx.msg.key + " (" + ctx.numRetransmit + " of " + MAX_RETRANSMIT + ")")
			try {
				sendMessageOverLowerLayer(ctx.msg)
			} catch (IOException e) {
				System.err.println("[" + getClass.getName + "] ERROR: Retransmission failed: " + e.getMessage)
				removeTransmission(ctx)
				return
			}
			scheduleRetransmission(ctx)
		} else {
			removeTransmission(ctx)
			System.out.println("[" + getClass.getName + "] Transmission of " + ctx.msg.key + " cancelled")
			ctx.msg.timedOut
		}
	}
	
	def private synchronized TxContext addTransmission(Message msg) {
		if (msg != null) {
			var ctx = new TxContext
			ctx.msg = msg
			ctx.numRetransmit = 0
			ctx.retransmitTask = null
			txTable.put(msg.getID, ctx)
			return ctx
		}
		return null
	}
	
	def private synchronized TxContext getTransmission(Message msg) {
		var TxContext res = null
		if(msg != null){
			res = txTable.get(msg.getID)
		}
		return res
	}
	
	def private synchronized void removeTransmission(TxContext ctx) {
		if (ctx != null) {
			ctx.retransmitTask.cancel
			ctx.retransmitTask = null
			txTable.remove(ctx.msg.getID)
		}
	}	
	
	/**
	 * Calculates the initial timeout for outgoing Confirmable messages.
	 * 
	 * @Return The timeout in milliseconds
	 */
	def private static int initialTimeout() {
		return rnd(ACK_TIMEOUT, (ACK_TIMEOUT * ACK_RANDOM_FACTOR).intValue)
	} 
	
	/**
	 * Returns a random number within a given range.
	 * 
	 * @param min The lower limit of the range
	 * @param max The upper limit of the range, inclusive
	 * @return A random number from the range [min, max]
	 *
	 */
	def private static int rnd(int min, int max) {
		return min + (Math.random * (max - min + 1)).intValue
	}
	
	def private void scheduleRetransmission(TxContext ctx) {
		if (ctx.retransmitTask != null) {
			ctx.retransmitTask.cancel
		}
		ctx.retransmitTask = new RetransmitTask(ctx, this)
		if (ctx.timeout == 0) {
			ctx.timeout = initialTimeout
		} else {
			ctx.timeout = ctx.timeout * 2
		}
		timer.schedule(ctx.retransmitTask, ctx.timeout)
	}
}

/** 
 * Class that represents a UDP Layer.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class UDPLayer extends Layer {
	
	val public static DEFAULT_PORT = 5683
	val public static String URI_SCHEME_NAME = "coap"
	
	DatagramSocket socket
	ReceiverThread receiverThread	
	
	/**
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

	/**
	 * Constructor for a new UDP layer
	 * 
	 */	
    new () throws SocketException {
		this(0, true) 
	}

	/** 
	 * Inner class that represents a Receiver Thread.
	 * 
	 * @author César Estebas Gómez.
	 * @version Xtend-CoAP_v1.0.
	 */
	static class ReceiverThread extends Thread {
		
		UDPLayer udpLayer
	
		new(UDPLayer udpLayer){
			this.udpLayer = udpLayer
		}
		
		@Override
		override public void run() {
			while (true) {
				var buffer = newByteArrayOfSize(1024)
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
	
	def getSocket(){
		return socket
	}
	
	/**
	 * Decides if the listener thread persists after the main thread terminates
	 * 
	 * @param on True if the listener thread should stay alive after the main
	 * thread terminates. This is useful for e.g. server applications
	 */
	def setDaemon(boolean on) {
		receiverThread.setDaemon(on)
	}

	/**
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

	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		var uri = msg.getURI
		var InetAddress address = null
		var port = DEFAULT_PORT
		if (msg.hasOption(Option.PROXY_URI)) {
			var URI proxyUri = null
			try {
				proxyUri = new URI(msg.getFirstOption(Option.PROXY_URI).displayValue)
			} catch (URISyntaxException e) {
				System.err.printf("[" + getClass.getName + "] Failed to set URI: " + e.getMessage)
				return
			}
			address = InetAddress.getByName(proxyUri.getHost)
			if (proxyUri != null) {
				port = proxyUri.getPort
			} else {
				port = DEFAULT_PORT
			}
		} else {
			address = msg.getAddress
			if(uri != null){
				port = uri.getPort
			}
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

	/**
	 * Method that receive a datagram and analyzes it.
	 * 
	 * @param datagram The datagram received.
	 */
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