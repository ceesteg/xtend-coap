package xtend.coap.message.request

interface RequestHandler {
	def void performGet(GetRequest request)
	def void performPost(PostRequest request)
	def void performPut(PutRequest request)
	def void performDelete(DeleteRequest request)
}