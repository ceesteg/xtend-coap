package xtend.coap.message

interface MessageReceiver {
	def void receiveMessage(Message msg)
}