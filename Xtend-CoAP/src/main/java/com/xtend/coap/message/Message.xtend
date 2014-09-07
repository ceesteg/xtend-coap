package com.xtend.coap.message

import java.io.UnsupportedEncodingException
import java.net.InetAddress
import java.net.URI
import java.net.URISyntaxException
import java.net.UnknownHostException
import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.TreeMap
import java.util.Arrays

import com.xtend.coap.utils.Option
import com.xtend.coap.utils.MessageType
import com.xtend.coap.utils.Code
import com.xtend.coap.utils.DatagramUtils
import com.xtend.coap.utils.ContentFormat
import com.xtend.coap.utils.HexUtils

/** 
 * Class that represents a Message.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class Message {
	
	val public static VER = 2
	val public static T = 2
	val public static TKL = 4
	val public static OPTION_COUNT = 4
	val public static CODE = 8
	val public static CODE_CLASS = 3
	val public static CODE_DETAIL = 5
	val public static ID = 16
	val public static OPTION_DELTA = 4
	val public static OPTION_LENGTH = 4
	val public static OPTION_EXT_13 = 8
	val public static OPTION_EXT_14 = 16
	val public static MAX_ID = 1.operator_doubleLessThan(ID) - 1
	
	byte[] payload_marker 
	
	URI uri
	byte[] payload
	boolean complete
	int version
	MessageType type
	String code
	int messageID
	Message buddy
	Map<Integer, List<Option>> optionMap
	long timestamp
	long token
	int tokenLength
	
	def getToken() {
		return this.token
	}
	
	def void setToken(long token, int tokenLength) {
		this.token = token
		setTokenLength(tokenLength)
	}
	
	def int getTokenLength() {
		return this.tokenLength
	}
	
	def void setTokenLength(int tokenLength) {
		this.tokenLength = tokenLength
	}
	
	/**
	 * Default constructor for a new CoAP message
	 */
	new() { 
		this.version = 1
		this.messageID = -1
		this.optionMap = new TreeMap<Integer, List<Option>>
		this.payload_marker = newByteArrayOfSize(1)
		this.payload_marker.set(0, 0xFF.byteValue)
	}

	/**
	 * Constructor for a new CoAP message
	 * 
	 * @param type The type of the CoAP message
	 * @param code The code of the CoAP message (See class CodeRegistry)
	 */
	new(MessageType type, String code) {
		this()
		this.type = type
		this.code = code
	}	
	
	/**
	 * Constructor for a new CoAP message
	 * 
	 * @param uri The URI of the CoAP message
	 * @param payload The payload of the CoAP message
	 */
	new(URI uri, MessageType type, String code, int id, byte[] payload) {
		this(type, code)
		this.uri = uri
		this.messageID = id
		this.payload = payload
	}
	
	def newReply(boolean ack) {
		var reply = new Message
		if (type == MessageType.CONFIRMABLE) {
			if (ack) {
				reply.type = MessageType.ACKNOWLEDGMENT
			} else {
				reply.type = MessageType.RESET
			}
		} else {
			reply.type = MessageType.NON_CONFIRMABLE
		}
		reply.messageID = this.messageID
		reply.setToken(getToken, getTokenLength)
		reply.uri = this.uri
		reply.code = Code.EMPTY_MESSAGE
		return reply
	}
	
	def static newAcknowledgement(Message msg) {
		var ack = new Message
		ack.setType(MessageType.ACKNOWLEDGMENT)
		ack.setID(msg.getID)
		ack.setURI(msg.getURI)
		ack.setCode(Code.EMPTY_MESSAGE)
		return ack
	}
	
	def static newReset(Message msg) {
		var rst = new Message
		rst.setType(MessageType.RESET)
		rst.setID(msg.getID)
		rst.setURI(msg.getURI)
		rst.setCode(Code.EMPTY_MESSAGE)
		return rst
	}
	
	/**
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

	/**
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
			var optionDeltaExtended = -1
			var optionDelta = opt.getOptionNumber - lastOptionNumber
			if (optionDelta >= 0xD && optionDelta < 0x10D) {
				optionDeltaExtended = optionDelta - 0xD
				optionDelta = 0xD
			} else if (optionDelta >= 0x10D && optionDelta <= 0xFFFF) {
				optionDeltaExtended = optionDelta - 0x10D
				optionDelta = 0xE
			} else if (optionDelta > 0xFFFF) {
				System.err.println("ERROR: Option number error.")
				return null
			}
			
			var optionLengthExtended = -1
			var optionLength = opt.getLength
			if (optionLength >= 0xD && optionLength < 0x10D) {
				optionLengthExtended = optionLength - 0xD
				optionLength = 0xD
			} else if (optionLength >= 0x10D && optionLength <= 0xFFFF) {
				optionLengthExtended = optionLength - 0x10D
				optionLength = 0xE
			} else if (optionLength > 0xFFFF) {
				System.err.println("ERROR: Option length error.")
				return null
			}
			
			optWriter.write(optionDelta, OPTION_DELTA)
			optWriter.write(optionLength, OPTION_LENGTH)
			if (optionDeltaExtended != -1) {
				if (optionDelta == 0xD) {
					optWriter.write(optionDeltaExtended, OPTION_EXT_13)
				} else if (optionDelta == 0xE) {
					optWriter.write(optionDeltaExtended, OPTION_EXT_14)
				}
			}
			if (optionLengthExtended != -1) {
				if (optionLength == 0xD) {
					optWriter.write(optionLengthExtended, OPTION_EXT_13)
				} else if (optionLength == 0xE) {
					optWriter.write(optionLengthExtended, OPTION_EXT_14)
				}
			}
			
			optWriter.writeBytes(opt.getRawValue)
			optionCount++
			lastOptionNumber = opt.getOptionNumber
		}
		var writer = new DatagramUtils(null)
		writer.write(version, VER)
		writer.write(type.ordinal, T)
		writer.write(tokenLength, TKL)
		writer.write(Code.codeClass(code), CODE_CLASS)
		writer.write(Code.codeDetail(code), CODE_DETAIL)
		writer.write(messageID, ID)
		if (code == Code.EMPTY_MESSAGE) {
			return writer.toByteArray
		}
		writer.writeBytes(HexUtils.longToBytes(token, tokenLength))
		writer.writeBytes(optWriter.toByteArray)
		if (payload != null && payload.length > 0) {
			if (optionCount > 0) {
				writer.writeBytes(payload_marker)
			}
			writer.writeBytes(payload)
		}
		return writer.toByteArray
	}

	/**
	 * Decodes the message from the its binary representation
	 * as specified in draft-ietf-core-coap-05, section 3.1
	 * 
	 * @param byteArray A byte array containing the CoAP encoding of the message
	 * 
	 */
	def static fromByteArray(byte[] byteArray) {
		var datagram = new DatagramUtils(byteArray)
		var version = datagram.read(VER)
		var type = getTypeByID(datagram.read(T))
		var tokLen = datagram.read(TKL)
		var codeClass = datagram.read(CODE_CLASS)
		var codeDetail = datagram.read(CODE_DETAIL)
		var code = Code.genCode(codeClass, codeDetail)
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
		msg.tokenLength = tokLen
		msg.code = code
		msg.messageID = datagram.read(ID)
		msg.token = HexUtils.bytesToLong(datagram.readBytes(msg.tokenLength))  // Read the token
		
		if (code == Code.EMPTY_MESSAGE) {
			if (msg.token != 0x0) {
				System.err.println("ERROR: Message format error.")
				return null
			}
		}
		var currentOption = 0
		
		var end = false
		var bytesLeft = datagram.readBytesLeft
		var aux = new DatagramUtils(bytesLeft)
		datagram = new DatagramUtils(bytesLeft)
		while (!end){
			var optionDelta = datagram.read(OPTION_DELTA)
			var optionLength = datagram.read(OPTION_LENGTH)
			if (optionDelta == 0xD) {
				optionDelta = datagram.read(OPTION_EXT_13) + 0xD
			} else if (optionDelta == 0xE) {
				optionDelta = datagram.read(OPTION_EXT_14) + 0x10D
			} else if(optionDelta == 0xF) {  // Reserverd for the payload_marker
				if(optionDelta != optionLength) {
					System.err.println("ERROR: Message format error.")
					return null
				}
			}
			if (optionLength == 0xD) {
				optionLength = datagram.read(OPTION_EXT_13) + 0xD
			} else if (optionDelta == 0xE) {
				optionLength = datagram.read(OPTION_EXT_14) + 0x10D
			} else if (optionLength == 0xF) {  // Reserverd for future use
				System.err.println("ERROR: Message format error.")
				return null
			}
			currentOption += optionDelta

			var rB = datagram.readBytes(optionLength)
			var opt = new Option (rB, currentOption)
			msg.addOption(opt)

			
			bytesLeft = datagram.readBytesLeft
			if (bytesLeft.length == 0) {
				end = true	
			} else {
				aux = new DatagramUtils(bytesLeft)
				datagram = new DatagramUtils(bytesLeft)
				if (Arrays.equals(aux.readBytes(msg.payload_marker.length), msg.payload_marker)) {	
					datagram.readBytes(msg.payload_marker.length)
					msg.payload = datagram.readBytesLeft
					if (msg.payload.length == 0) {
						System.err.println("ERROR: Message format error.")
						return null
					}
				}
			}
		}

		return msg
	}
	
	/**
	 * This procedure sets the URI of this CoAP message
	 * 
	 * @param uri The URI to which the current message URI should be set to
	 */
	def void setURI(URI uri) {		
		if (uri != null) {
			var path = uri.getPath()
			if (path != null && path.length() > 1) {
				
				var uriPaths = new ArrayList<Option>()
				for (String segment : path.split("/")) {
					
					if (!segment.isEmpty()) {
					
						var uriPath = new Option(segment, Option.URI_PATH)
					
						uriPaths.add(uriPath)
					}
				}
				
				setOptions(Option.URI_PATH, uriPaths)

			}
			
			var query = uri.getQuery()
			if (query != null) {

				var uriQuery = new ArrayList<Option>()
				for (String argument : query.split("&")) {
					
					uriQuery.add(new Option(argument, Option.URI_QUERY))
				}
				
				setOptions(Option.URI_QUERY, uriQuery)
			}
			this.uri = uri
		}
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
	
	/**
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
	
	/**
	 * This procedure sets the type of this CoAP message
	 * 
	 * @param msgType The message type to which the current message type should
	 *                be set to
	 */
	def void setType(MessageType msgType) {
		this.type = msgType
	}
	
	/**
	 * This procedure sets the code of this CoAP message
	 * 
	 * @param code The message code to which the current message code should
	 *             be set to
	 */
	def void setCode(String code) {
		this.code = code
	}
	
	/**
	 * This procedure sets the ID of this CoAP message
	 * 
	 * @param id The message ID to which the current message ID should
	 *           be set to
	 */
	def void setID(int id) {
		this.messageID = id
	}
	
	/**
	 * This function returns the URI of this CoAP message
	 * 
	 * @return The current URI
	 */
	def getURI() {
		return this.uri
	}
	
	/**
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
	
	/**
	 * This function returns the version of this CoAP message
	 * 
	 * @return The current version.
	 */
	def getVersion() {
		return this.version
	}
	
	/**
	 * This function returns the type of this CoAP message
	 * 
	 * @return The current type.
	 */
	def getType() {
		return this.type
	}
	
	/**
	 * This function returns the code of this CoAP message
	 * 
	 * @return The current code.
	 */
	def getCode() {
		return this.code
	}
	
	/**
	 * This function returns the ID of this CoAP message
	 * 
	 * @return The current ID.
	 */
	def getID() {
		return this.messageID
	}

	
	/**
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
	
	/**
	 * This function returns all options with the given option number
	 * 
	 * @param optionNumber The option number
	 * @return A list containing the options with the given number
	 */
	def getOptions(int optionNumber) {
		return optionMap.get(optionNumber)
	}

	/**
	 * Sets all options with the specified option number
	 * 
	 * @param optionNumber The option number
	 * @param opt The list of the options
	 */
	def void setOptions(int optionNumber, List<Option> opt) {
		optionMap.put(optionNumber, opt)
	}
	
	/**
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
	
	/**
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

	/**
	 * Returns a sorted list of all included options
	 * 
	 * @return A sorted list of all options (copy)
	 */
	def getOptionList() {
		var list = new ArrayList<Option>
		for (List<Option> option : optionMap.values) {
			for (Option opt : option) {
				if (opt.getRawValue.length != 0) {
					list.add(opt)
				}
			}
		}
		return list
	}	
	
	/**
	 * This function returns the number of options of this CoAP message
	 * 
	 * @return The current number of options.
	 */
	def getOptionCount() {
		return getOptionList.size
	}
	
	/**
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
	
	/**
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
	
	/**
	 * Checks whether the message is complete, i.e. its payload
	 * was completely received.
	 * 
	 * @return True iff the message is complete
	 */
	def isComplete() {
		return complete
	}
	
	/**
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
	
	/**
	 * Sets the timestamp associated with this message.
	 * 
	 * @param timestamp The new timestamp, in milliseconds
	 */
	def void setTimestamp(long timestamp) {
		this.timestamp = timestamp
	}
	
	/**
	 * Returns the timestamp associated with this message.
	 * 
	 * @return The timestamp of the message, in milliseconds
	 */
	def getTimestamp() {
		return timestamp
	}
	
	/**
	 * Notification method that is called when the message's complete flag
	 * changed to true.
	 * 
	 * Subclasses may override this method to add custom handling code.
	 */
	def void completed() { }
	
	/**
	 * Notification method that is called when the transmission of this
	 * message was cancelled due to timeout.
	 * 
	 *  Subclasses may override this method to add custom handling code.
	 */
	def void timedOut() { }
	
	/**
	 * Notification method that is called whenever payload was appended
	 * using the appendPayload() method.
	 * 
	 * Subclasses may override this method to add custom handling code.
	 * 
	 * @param block A byte array containing the data that was appended
	 */
	def void payloadAppended(byte[] block) { }
	
	/**
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
				return MessageType.CONFIRMABLE
			case 1:
				return MessageType.NON_CONFIRMABLE
			case 2:
				return MessageType.ACKNOWLEDGMENT
			case 3:
				return MessageType.RESET
			default:
				return MessageType.CONFIRMABLE
		}
	}
	
	/**
	 * This function checks if the message is a request message
	 * 
	 * @return True if the message is a request
	 */
	def isRequest() {
		return Code.isRequest(code)
	}
	
	/**
	 * This function checks if the message is a response message
	 * 
	 * @return True if the message is a response
	 */
	def isResponse() {
		return Code.isResponse(code)
	}

	def isConfirmable() {
		return type == MessageType.CONFIRMABLE
	}
	
	def isNonConfirmable() {
		return type == MessageType.NON_CONFIRMABLE
	}
	
	def isAcknowledgement() {
		return type == MessageType.ACKNOWLEDGMENT
	}
	
	def isReset() {
		return type == MessageType.RESET
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
				case CONFIRMABLE     : 
					typeStr = "CON" 
				case NON_CONFIRMABLE : 
					typeStr = "NON" 
				case ACKNOWLEDGMENT : 
					typeStr = "ACK" 
				case RESET           : 
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
				case CONFIRMABLE : 
					return "CON"
				case NON_CONFIRMABLE : 
					return "NON"
				case ACKNOWLEDGMENT : 
					return "ACK"
				case RESET : 	
					return "RST"
				default : 
					return "???"
			}
		} 
		return null
	}
	
	def void log() {
		System.out.println("==============================================================")
		System.out.println("|                        COAP MESSAGE                        |")
		System.out.println("|------------------------------------------------------------|")
		var options = getOptionList
		var uriVal = "NULL"
		if (uri != null) {
			uriVal = uri.toString
		}
		System.out.println("| URI            : " + uriVal + printBlank(60 - 18 - uriVal.length) + "|")
		System.out.println("| Message ID     : " + messageID + printBlank(60 - 18 - String.valueOf(messageID).length) + "|")
		System.out.println("| Message Type   : " + typeString + printBlank(60 - 18 - typeString.length) + "|")
		var stCode = Code.toString(code)
		System.out.println("| CoAP Code      : " + stCode + printBlank(60 - 18 - stCode.length) + "|")
		var stToken = HexUtils.hex(HexUtils.longToBytes(getToken, getTokenLength))
		System.out.println("| Token          : " + stToken + printBlank(60 - 18 - stToken.length) + "|")
		System.out.println("| Options: " + options.size + printBlank(60 - 10 - String.valueOf(options.size).length) + "|")
		for (Option opt : options) {
			var noBlank = 10 + opt.getName.length + opt.getDisplayValue.length + String.valueOf(opt.getLength).length
			System.out.println("|  * " + opt.getName + ": " + opt.getDisplayValue + " (" + opt.getLength + " Bytes)" + printBlank(60 - noBlank) + "|")
		}
		System.out.println("| Payload: " + payloadSize + " Bytes" + printBlank(60 - 16 - String.valueOf(payloadSize).length) + "|") 
		System.out.println("==============================================================")
		if (payloadSize > 0) {
			System.out.println(getPayloadString)
		}
	}
	
	def private printBlank(int num) {
		var ret = ""
		for (var i = 0; i < num; i++) {
			ret += " "
		}
		return ret
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
	
	/**
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
	
	/**
	 * This method is overridden by subclasses according to the Visitor Pattern
	 *
	 * @param handler A handler for this message
	 */
	def void handleBy(MessageHandler handler) { }
}