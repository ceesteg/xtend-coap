package xtend.coap.utils
	/*
	 * The message's type which can have the following values:
	 * 
	 * 0: Confirmable
	 * 1: Non-Confirmable
	 * 2: Acknowledgment
	 * 3: Reset
	 */
enum MessageType {
	Confirmable,
	Non_Confirmable,
	Acknowledgement,
	Reset
}