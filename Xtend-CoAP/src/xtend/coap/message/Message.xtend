package xtend.coap.message

import java.io.PrintStream
import java.io.UnsupportedEncodingException
import java.net.InetAddress
import java.net.URI
import java.net.URISyntaxException
import java.net.UnknownHostException
import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.TreeMap

import xtend.coap.utils.Option
import xtend.coap.utils.MessageType
import xtend.coap.utils.Code
import xtend.coap.utils.DatagramUtils
import xtend.coap.utils.ContentFormat

class Message {
	
	val public static VERSION_BITS = 2
	val public static TYPE_BITS = 2
	val public static OPTIONCOUNT_BITS = 4
	val public static CODE_BITS = 8
	val public static ID_BITS = 16
	val public static OPTIONDELTA_BITS = 4
	val public static OPTIONLENGTH_BASE_BITS = 4
	val public static OPTIONLENGTH_EXTENDED_BITS = 8
	val public static MAX_ID = (1 << ID_BITS)- 1
	val public static MAX_OPTIONDELTA = (1 << OPTIONDELTA_BITS) - 1
	val public static MAX_OPTIONLENGTH_BASE = (1 << OPTIONLENGTH_BASE_BITS) - 2
	
	URI uri
	byte[] payload
	boolean complete
	int version = 1
	MessageType type
	int code
	int messageID = -1
	Message buddy
	Map<Integer, List<Option>> optionMap = new TreeMap<Integer, List<Option>>
	long timestamp
	
	// Constructors ////////////////////////////////////////////////////////////
	/*
	 * Default constructor for a new CoAP message
	 */
	new() { }

	/*
	 * Constructor for a new CoAP message
	 * 
	 * @param type The type of the CoAP message
	 * @param code The code of the CoAP message (See class CodeRegistry)
	 */
	new(MessageType type, int code) {
		this.type = type
		this.code = code
	}	
	
	/*
	 * Constructor for a new CoAP message
	 * 
	 * @param uri The URI of the CoAP message
	 * @param payload The payload of the CoAP message
	 */
	new(URI uri, MessageType type, int code, int id, byte[] payload) {
		this.uri = uri
		this.type = type
		this.code = code
		this.messageID = id
		this.payload = payload
	}
	

	
	// Static Functions ////////////////////////////////////////////////////////
	
	def newReply(boolean ack) {
		var reply = new Message
		if (type == MessageType.Confirmable) {
			if (ack) {
				reply.type = MessageType.Acknowledgement
			} else {
				reply.type = MessageType.Reset
			}
		} else {
			reply.type = MessageType.Non_Confirmable
		}
		reply.messageID = this.messageID
		reply.setOption(getFirstOption(Option.TOKEN))
		reply.uri = this.uri
		reply.code = Code.EMPTY_MESSAGE
		return reply
	}
	
	def static newAcknowledgement(Message msg) {
		var ack = new Message
		ack.setType(MessageType.Acknowledgement)
		ack.setID(msg.getID)
		ack.setURI(msg.getURI)
		ack.setCode(Code.EMPTY_MESSAGE)
		return ack
	}
	
	def static newReset(Message msg) {
		var rst = new Message
		rst.setType(MessageType.Reset)
		rst.setID(msg.getID)
		rst.setURI(msg.getURI)
		rst.setCode(Code.EMPTY_MESSAGE)
		return rst
	}
	
	/*
	 * Matches two messages to buddies if they have the same message ID
	 * 
	 * @param msg1 The first message
	 * @param msg2 the second message
	 * @return True iif the messages were matched to buddies
	 */
	def static matchBuddies(Message msg1, Message msg2) {
		if (msg1 != null && msg2 != null && msg1 != msg2 && msg1.getID == msg2.getID) {
			msg1.buddy = msg2
			msg2.buddy = msg1
			return true
		} else {
			return false
		}
	}
	
	// Serialization ///////////////////////////////////////////////////////////

	/*
	 * Encodes the message into its raw binary representation
	 * as specified in draft-ietf-core-coap-05, section 3.1
	 * 
	 * @return A byte array containing the CoAP encoding of the message
	 * 
	 */
	def toByteArray() {
		var optWriter = new DatagramUtils(null)
		var optionCount = 0
		var lastOptionNumber = 0
		for (Option opt : getOptionList) {
			var optionDelta = opt.getOptionNumber - lastOptionNumber
			while (optionDelta > MAX_OPTIONDELTA) {
				var fencepostNumber = Option.nextJump(lastOptionNumber)
				var fencepostDelta = fencepostNumber - lastOptionNumber
				if (fencepostDelta <= 0) {
					System.err.println("Fencepost liveness violated: delta = " + fencepostDelta)
				}
				if (fencepostDelta > MAX_OPTIONDELTA) {
					System.out.println("Fencepost safety violated: delta = " + fencepostDelta)
				}
				optWriter.write(fencepostDelta, OPTIONDELTA_BITS)
				optWriter.write(0, OPTIONLENGTH_BASE_BITS)
				optionCount++
				lastOptionNumber = fencepostNumber
				optionDelta -= fencepostDelta
			}
			optWriter.write(optionDelta, OPTIONDELTA_BITS)
			var length = opt.getLength
			if (length <= MAX_OPTIONLENGTH_BASE) {
				optWriter.write(length, OPTIONLENGTH_BASE_BITS)
			} else {
				var baseLength = MAX_OPTIONLENGTH_BASE + 1
				optWriter.write(baseLength, OPTIONLENGTH_BASE_BITS)
				var extLength = length - baseLength
				optWriter.write(extLength, OPTIONLENGTH_EXTENDED_BITS)
			}
			optWriter.writeBytes(opt.getRawValue)
			optionCount++
			lastOptionNumber = opt.getOptionNumber
		}
		var writer = new DatagramUtils(null)
		writer.write(version, VERSION_BITS)
		writer.write(type.ordinal, TYPE_BITS)
		writer.write(optionCount, OPTIONCOUNT_BITS)
		writer.write(code, CODE_BITS)
		writer.write(messageID, ID_BITS)
		writer.writeBytes(optWriter.toByteArray)
		writer.writeBytes(payload)
		return writer.toByteArray
	}

	/*
	 * Decodes the message from the its binary representation
	 * as specified in draft-ietf-core-coap-05, section 3.1
	 * 
	 * @param byteArray A byte array containing the CoAP encoding of the message
	 * 
	 */
	def static fromByteArray(byte[] byteArray) {
		var datagram = new DatagramUtils(byteArray)
		var version = datagram.read(VERSION_BITS)
		var type = getTypeByID(datagram.read(TYPE_BITS))
		var optionCount = datagram.read(OPTIONCOUNT_BITS)
		var code = datagram.read(CODE_BITS)
		if (!Code.isValid(code)) {
			System.err.println("ERROR: Invalid message code: " + code)
			return null
		}
		var Message msg
		try {
			msg = Code.getMessageClass(code).newInstance
		} catch (InstantiationException e) {
			e.printStackTrace
			return null
		} catch (IllegalAccessException e) {
			e.printStackTrace
			return null
		}
		msg.version = version
		msg.type = type
		msg.code = code
		msg.messageID = datagram.read(ID_BITS)
		var currentOption = 0
		for (var i = 0; i < optionCount; i++) {
			var optionDelta = datagram.read(OPTIONDELTA_BITS)
			currentOption += optionDelta
			if (Option.jump(currentOption))
			{
				datagram.read(OPTIONLENGTH_BASE_BITS)
			} else {
				var length = datagram.read(OPTIONLENGTH_BASE_BITS)
				if (length > MAX_OPTIONLENGTH_BASE)
				{
					var lenAux = datagram.read(OPTIONLENGTH_EXTENDED_BITS)
					length += lenAux
				}
				var opt = new Option (datagram.readBytes(length), currentOption)
				msg.addOption(opt)
			}
		}
		msg.payload = datagram.readBytesLeft
		return msg
	}
	
	
	// Procedures //////////////////////////////////////////////////////////////
	
	/*
	 * This procedure sets the URI of this CoAP message
	 * 
	 * @param uri The URI to which the current message URI should be set to
	 */
	def void setURI(URI uri) {
		if (uri != null) {
			var path = uri.getPath
			if (path != null && path.length > 1) {
				setOption(new Option(path.substring(1), Option.URI_PATH))
			}
			var query = uri.getQuery
			if (query != null) {
				var uriQuery = new ArrayList<Option>
				for (String argument : query.split("&")) {
					uriQuery.add(new Option(argument, Option.URI_QUERY))
				}
				setOptions(Option.URI_QUERY, uriQuery)
			}
		}
		this.uri = uri
	}
	
	def setURI(String uri) {
		try {
			setURI(new URI(uri))
			return true
		} catch (URISyntaxException e) {
			System.err.printf("[" + getClass.getName + "] Failed to set URI: " + e.getMessage)
			return false
		}
	}
	
	/*
	 * This procedure sets the payload of this CoAP message
	 * 
	 * @param payload The payload to which the current message payload should
	 *                be set to
	 */
	def void setPayload(byte[] payload) {
		this.payload = payload
	}
	
	def void setPayload(String payload, int mediaType) {
		if (payload != null) {
			try {
				setPayload(payload.getBytes("UTF-8"))
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace
				return
			}
			setOption(new Option(mediaType, Option.CONTENT_FORMAT))
		}
	}
	
	def void setPayload(String payload) {
		setPayload(payload, ContentFormat.PLAIN)
	}
	
	/*
	 * This procedure sets the type of this CoAP message
	 * 
	 * @param msgType The message type to which the current message type should
	 *                be set to
	 */
	def void setType(MessageType msgType) {
		this.type = msgType
	}
	
	/*
	 * This procedure sets the code of this CoAP message
	 * 
	 * @param code The message code to which the current message code should
	 *             be set to
	 */
	def void setCode(int code) {
		this.code = code
	}
	
	/*
	 * This procedure sets the ID of this CoAP message
	 * 
	 * @param id The message ID to which the current message ID should
	 *           be set to
	 */
	def void setID(int id) {
		this.messageID = id
	}
	
	// Functions ///////////////////////////////////////////////////////////////
		
	/*
	 * This function returns the URI of this CoAP message
	 * 
	 * @return The current URI
	 */
	def getURI() {
		return this.uri
	}
	
	/*
	 * This function returns the payload of this CoAP message
	 * 
	 * @return The current payload.
	 */
	def getPayload() {
		return this.payload
	}
	
	def getPayloadString() {
		try {
			if (payload != null) {
				return new String(payload, "UTF-8")
			} else{
				return null
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace
			return null
		}
	}
	
	/*
	 * This function returns the version of this CoAP message
	 * 
	 * @return The current version.
	 */
	def getVersion() {
		return this.version
	}
	
	/*
	 * This function returns the type of this CoAP message
	 * 
	 * @return The current type.
	 */
	def getType() {
		return this.type
	}
	
	/*
	 * This function returns the code of this CoAP message
	 * 
	 * @return The current code.
	 */
	def getCode() {
		return this.code
	}
	
	/*
	 * This function returns the ID of this CoAP message
	 * 
	 * @return The current ID.
	 */
	def getID() {
		return this.messageID
	}

	
	/*
	 * This procedure adds an option to the list of options of this CoAP message
	 * 
	 * @param opt The option which should be added to the list of options of the
	 *            current CoAP message
	 */
	def void addOption(Option opt) {
		var list = optionMap.get(opt.getOptionNumber)
		if (list == null) {
			list = new ArrayList<Option>
			optionMap.put(opt.getOptionNumber, list)
		}
		list.add(opt)
	}	
	
	/*
	 * This function returns all options with the given option number
	 * 
	 * @param optionNumber The option number
	 * @return A list containing the options with the given number
	 */
	def getOptions(int optionNumber) {
		return optionMap.get(optionNumber)
	}

	/*
	 * Sets all options with the specified option number
	 * 
	 * @param optionNumber The option number
	 * @param opt The list of the options
	 */
	def void setOptions(int optionNumber, List<Option> opt) {
		optionMap.put(optionNumber, opt)
	}
	
	/*
	 * Returns the first option with the specified option number
	 * 
	 * @param optionNumber The option number
	 * @return The first option with the specified number, or null
	 */
	def getFirstOption(int optionNumber) {
		var list = getOptions(optionNumber)
		if (list != null && !list.isEmpty) {
			return list.get(0)
		} else{
			return null
		}
	}
	
	/*
	 * Sets the option with the specified option number
	 * 
	 * @param opt The option to set
	 */
	def void setOption(Option opt) {
		if (opt != null) {
			var options = new ArrayList<Option>
			options.add(opt)
			setOptions(opt.getOptionNumber, options)
		}
	}

	/*
	 * Returns a sorted list of all included options
	 * 
	 * @return A sorted list of all options (copy)
	 */
	def getOptionList() {
		var list = new ArrayList<Option>
		for (List<Option> option : optionMap.values) {
			list.addAll(option)
		}
		return list
	}	
	
	/*
	 * This function returns the number of options of this CoAP message
	 * 
	 * @return The current number of options.
	 */
	def getOptionCount() {
		return getOptionList.size
	}
	
	/*
	 * Appends data to this message's payload.
	 * 
	 * @param block The byte array containing the data to append
	 */
	def synchronized void appendPayload(byte[] block) {
		if (block != null) {
			if (payload != null) {
				var oldPayload = payload
				payload = newByteArrayOfSize(oldPayload.length + block.length)
				System.arraycopy(oldPayload, 0,	payload, 0, oldPayload.length)
				System.arraycopy(block, 0, payload, oldPayload.length, block.length)
			} else {
				payload = block.clone
			}
			notifyAll
			payloadAppended(block)
		}		
	}
	
	/*
	 * Reads the byte at the given position from the payload and blocks
	 * if the data is not yet available.
	 * 
	 * @pos The position of the byte to read
	 * @return The byte at the given position, or -1 if it does not exist
	 */
     def synchronized readPayload(int pos) {
		while (pos >= payload.length) {
			if (complete) {
				return -1
			} else try {
				wait
			} catch (InterruptedException e) {
				return -1
			}
		}
		return payload.get(pos)		
	}
	
	def payloadSize() {
		if (payload != null) {
			return payload.length
		} else{
			return 0
		}
	}
	
	/*
	 * Checks whether the message is complete, i.e. its payload
	 * was completely received.
	 * 
	 * @return True iff the message is complete
	 */
	def isComplete() {
		return complete
	}
	
	/*
	 * Sets the complete flag of this message.
	 * 
	 * @param complete The value of the complete flag
	 */
	def void setComplete(boolean complete) {
		this.complete = complete
		if (complete) {
			completed
		}
	}
	
	/*
	 * Sets the timestamp associated with this message.
	 * 
	 * @param timestamp The new timestamp, in milliseconds
	 */
	def void setTimestamp(long timestamp) {
		this.timestamp = timestamp
	}
	
	/*
	 * Returns the timestamp associated with this message.
	 * 
	 * @return The timestamp of the message, in milliseconds
	 */
	def getTimestamp() {
		return timestamp
	}
	
	/*
	 * Notification method that is called when the message's complete flag
	 * changed to true.
	 * 
	 * Subclasses may override this method to add custom handling code.
	 */
	def void completed() { }
	
	/*
	 * Notification method that is called when the transmission of this
	 * message was cancelled due to timeout.
	 * 
	 *  Subclasses may override this method to add custom handling code.
	 */
	def void timedOut() { }
	
	/*
	 * Notification method that is called whenever payload was appended
	 * using the appendPayload() method.
	 * 
	 * Subclasses may override this method to add custom handling code.
	 * 
	 * @param block A byte array containing the data that was appended
	 */
	def void payloadAppended(byte[] block) { }
	
	/*
	 * This function returns the buddy of this CoAP message
	 * Two messages are buddies iif they have the same message ID
	 * 
	 * @return The buddy of the message, if any
	 */
	def getBuddy() {
		return this.buddy
	}
	
	def static getTypeByID(int id) {
		switch (id) {
			case 0:
				return MessageType.Confirmable
			case 1:
				return MessageType.Non_Confirmable
			case 2:
				return MessageType.Acknowledgement
			case 3:
				return MessageType.Reset
			default:
				return MessageType.Confirmable
		}
	}
	
	/*
	 * This function checks if the message is a request message
	 * 
	 * @return True if the message is a request
	 */
	def isRequest() {
		return Code.isRequest(code)
	}
	
	/*
	 * This function checks if the message is a response message
	 * 
	 * @return True if the message is a response
	 */
	def isResponse() {
		return Code.isResponse(code)
	}

	def isConfirmable() {
		return type == MessageType.Confirmable
	}
	
	def isNonConfirmable() {
		return type == MessageType.Non_Confirmable
	}
	
	def isAcknowledgement() {
		return type == MessageType.Acknowledgement
	}
	
	def isReset() {
		return type == MessageType.Reset
	}
	
	def isReply() {
		return isAcknowledgement || isReset
	}
	
	def hasFormat(int mediaType) {
		var opt = getFirstOption(Option.CONTENT_FORMAT)
		if (opt != null) {
			return opt.getIntValue == mediaType
		} else{
			return false
		}
	}
	
	def hasOption(int optionNumber) {
		return getFirstOption(optionNumber) != null
	}
	
	@Override
	override public String toString() {
		var typeStr = "???"
		if (type != null) {
			switch (type) {
				case Confirmable     : 
					typeStr = "CON" 
				case Non_Confirmable : 
					typeStr = "NON" 
				case Acknowledgement : 
					typeStr = "ACK" 
				case Reset           : 
					typeStr = "RST" 
				default              : 
					typeStr = "???" 
			}
		}
		var String payloadStr = null
		if (payload != null) {
			payloadStr = new String(payload)
		} 
		return key + ": [" + typeStr + "] " + Code.toString(code) + " '" + payloadStr + " (" + payloadSize + ")"
	}
	
	def typeString() {
		if (type != null) {
			switch (type) {
				case Confirmable : 
					return "CON"
				case Non_Confirmable : 
					return "NON"
				case Acknowledgement : 
					return "ACK"
				case Reset : 	
					return "RST"
				default : 
					return "???"
			}
		} 
		return null
	}
	
	def void log(PrintStream out) {
		out.println("==[COAP MESSAGE]======================================")
		var options = getOptionList
		var uriVal = "NULL"
		if (uri != null) {
			uriVal = uri.toString
		}
		out.println("URI    : " + uriVal)
		out.println("ID     : " + messageID)
		out.println("Type   : " + typeString)
		out.println("Code   : " + Code.toString(code))
		out.println("Options: " + options.size)
		for (Option opt : options) {
			out.println("  * " + opt.getName + ": " + opt.getDisplayValue + " ( " + opt.getLength + " Bytes)")
		}
		out.printf("Payload: " + payloadSize + " Bytes")
		out.println("------------------------------------------------------")
		if (payloadSize > 0) {
			out.println(getPayloadString)
		}
		out.println("======================================================")
	}
	
	def void log() {
		log(System.out)
	}
	
	def endpointID() {
		var InetAddress address = null
		try {
			address = getAddress
		} catch (UnknownHostException e) {
		}
		var host = "NULL"
		if (address != null) {
			host = address.getHostAddress
		}
		var port = -1
		if (uri != null) {
			port = uri.getPort
		}
		return host + ":" + port
	}
	
	/*
	 * Returns a string that is assumed to uniquely identify a message
	 * 
	 * Note that for incoming messages, the message ID is not sufficient
	 * as different remote endpoints may use the same message ID.
	 * Therefore, the message key includes the identifier of the sender
	 * next to the message id. 
	 * 
	 * @return A string identifying the message
	 */
	def key() {
		return endpointID + "|" + typeString + "#" + messageID
	}
	
	def getAddress() throws UnknownHostException {
		var String host = null
		if (uri != null) {
			host = uri.getHost
		}
		return InetAddress.getByName(host)
	}
	
	/*
	 * This method is overridden by subclasses according to the Visitor Pattern
	 *
	 * @param handler A handler for this message
	 */
	def void handleBy(MessageHandler handler) { }
}