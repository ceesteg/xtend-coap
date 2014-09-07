package com.xtend.coap.message

/** 
 * Interface with the methods of a Message receiver.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
interface MessageReceiver {
	/**
	 * Method to receive a Message.
	 * 
	 * @param msg The message to receive.
	 */
	def void receiveMessage(Message msg)
}