package xtend.coap.layers

import java.io.IOException 
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.Map 
import java.util.Timer
import java.util.TimerTask

import xtend.coap.message.Message

class MessageLayer extends UpperLayer { 
	
	val static RESPONSE_TIMEOUT = 2000
	val static RESPONSE_RANDOM_FACTOR = 1.5
	val static MAX_RETRANSMIT = 4
	val static MESSAGE_CACHE_SIZE = 100 
	
	Timer timer = new Timer(true) 
	Map<Integer, TxContext> txTable = new HashMap<Integer, TxContext>
	MessageCache dupCache = new MessageCache
	MessageCache replyCache = new MessageCache
	int messageID
 
	private static class TxContext { 
		Message msg
		RetransmitTask retransmitTask
		int numRetransmit
		int timeout
	}
	/*
	 * Utility class used for duplicate detection and reply retransmissions
	 */
	@SuppressWarnings("serial")
	private static class MessageCache extends LinkedHashMap<String, Message> {
		@Override
		override protected boolean removeEldestEntry(Map.Entry<String, Message> eldest) {
			return size > MESSAGE_CACHE_SIZE
		}
	}
	
	/*
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
	
	new() {
		this.messageID = 0x1D00
	}
	
	@Override
	override protected void doSendMessage(Message msg) throws IOException {
		if (msg.getID < 0) {
			msg.setID(nextMessageID)
		}
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
			} else {
				System.out.println("[" + getClass.getName + "] Duplicate dropped: " + msg.key)
				return
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
			System.out.printf("[" + getClass.getName + "] Retransmitting " + ctx.msg.key + " (" + ctx.numRetransmit + " of " + MAX_RETRANSMIT + ")")
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
	
	/*
	 * Returns the next message ID to use out of a consecutive range
	 * 
	 * @return The message ID
	 */
	def private int nextMessageID() {
		var ID = messageID
		messageID++
		if (messageID > Message.MAX_ID) {
			messageID = 1
		}
		return ID
	}
	
	/*
	 * Calculates the initial timeout for outgoing Confirmable messages.
	 * 
	 * @Return The timeout in milliseconds
	 */
	def private static int initialTimeout() {
		return rnd(RESPONSE_TIMEOUT, (RESPONSE_TIMEOUT * RESPONSE_RANDOM_FACTOR).intValue)
	} 
	
	/*
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