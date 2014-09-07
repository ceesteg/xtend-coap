package com.xtend.coap.resource

import java.io.PrintStream
import java.util.Map
import java.util.StringTokenizer
import java.util.TreeMap
import java.util.ArrayList

import com.xtend.coap.message.request.RequestHandler
import com.xtend.coap.message.request.PutRequest
import com.xtend.coap.message.request.GetRequest
import com.xtend.coap.message.request.PostRequest
import com.xtend.coap.message.request.DeleteRequest
import com.xtend.coap.utils.ContentFormat
import com.xtend.coap.message.response.Response
import com.xtend.coap.utils.Code
import java.util.HashMap
 
/**
 * Class that represents a Resource. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class Resource implements RequestHandler {


	protected Resource parent
	protected Map<String, Resource> subResources
	int totalSubResourceCount
	String resourceIdentifier
	String resourceName
	String interfaceDescription
	int contentTypeCode
	int maximumSizeEstimate
	boolean observable
	boolean hidden
	

	/**
	 * Constructor for a Resource object.
	 */
	new() {
		this(null)
	}
	
	/**
	 * Constructor for a Resource object.
	 * 
	 * @param resourceIdentifier The resource identifier.
	 */
	new(String resourceIdentifier) {
		this(resourceIdentifier, false)
	}
	
	/**
	 * Constructor for a Resource object.
	 * 
	 * @param resourceIdentifier The resource identifier.
	 * @param hidden If its true, the recurse is hidden.
	 */
	new(String resourceIdentifier, boolean hidden) {
		this.resourceIdentifier = resourceIdentifier
		this.resourceName = ""
		this.interfaceDescription = ""
		this.contentTypeCode = -1
		this.maximumSizeEstimate = -1
		this.observable = false
		this.hidden = hidden
	}
	
	/**
	 * This method sets an extension attribute given in a string of the form
	 * "...=..."
	 * 
	 * @param linkExtension The link extension string specifying a link
	 *                      extension and a value for it
	 */
	def void populateAttributeFromLinkExtension (String linkExtension) {
		var elements = linkExtension.split("=")
		
		var ext = elements.get(0)
		var value = elements.get(1)
		
		if (ext.equals("n")) {
			setResourceName(value.substring(1, value.length-1))
		} else if (ext.equals("d")) {
			setInterfaceDescription(value.substring(1, value.length-1))
		} else if (ext.equals("ct")) {
			setContentTypeCode(Integer.parseInt(value))
		} else if (ext.equals("sz")) {
			setMaximumSizeEstimate(Integer.parseInt(value))
		} else if (ext.equals("obs")) {
			setObservable(Boolean.parseBoolean(value))
		}
	}
	
	/**
	 * This method sets the resource identifier of the current resource
	 * 
	 * @param resourceURI The resource identifier
	 */
	def void setResourceIdentifier(String resourceIdentifier) {
		this.resourceIdentifier = resourceIdentifier
	}

	/**
	 * This method sets the resource name of the current resource
	 * 
	 * @param resourceName The resource name
	 */
	def void setResourceName(String resourceName) {
		this.resourceName = resourceName
	}

	/**
	 * This method sets the interface description of the current resource
	 * 
	 * @param interfaceDescription The resource interface description
	 */
	def void setInterfaceDescription(String interfaceDescription) {
		this.interfaceDescription = interfaceDescription
	}

	/**
	 * This method sets the content type code of the current resource
	 * 
	 * @param contentTypeCode The resource contentTypeCode
	 */
	def void setContentTypeCode(int contentTypeCode) {
		this.contentTypeCode = contentTypeCode
	}

	/**
	 * This method sets the maximum size estimate of the current resource
	 * 
	 * @param maximumSizeExtimate The resource maximum size estimate
	 */
	def void setMaximumSizeEstimate(int maximumSizeEstimate) {
		this.maximumSizeEstimate = maximumSizeEstimate
	}

	/**
	 * This method sets whether the current resource is observable
	 * 
	 * @param observable The boolean value whether the current resource is
	 *                   observable
	 */
	def void setObservable(boolean observable) {
		this.observable = observable
	}
	
	/**
	 * This method sets attributes of a given resource according to data from
	 * a given link extension string
	 * 
	 * @param res The resource containing the attributes which should be set
	 * @param linkExtension The string with the link extension data
	 */
	def static void populateAttributeFromLinkExtension (Resource res, String linkExtension) {
		//"extension=value" is split to [extension, value]
		var elements = linkExtension.split("=")
		
		//Set extension string fo first array element (containing extension)
		var ext = elements.get(0)
		
		//Set value string if available
		var value = new String
		if (elements.length > 1) {
			value = elements.get(1)
		}
		//Set attribute according to extension
		if (ext.equals("n")) {
			res.setResourceName(value.substring(1, value.length-1))
		} else if (ext.equals("d")) {
			res.setInterfaceDescription(value.substring(1, value.length-1))
		} else if (ext.equals("ct")) {
			res.setContentTypeCode(Integer.parseInt(value))
		} else if (ext.equals("sz")) {
			res.setMaximumSizeEstimate(Integer.parseInt(value))
		} else if (ext.equals("obs")) {
			res.setObservable(true)
		}
	}
	
	/**
	 * This method returns a resource set from a link format string
	 * 
	 * @param linkFormatString The link format representation of the resources
	 * @return The resource set
	 */
	def void addLinkFormat(String linkFormat) {
				
		//Resources are separated by comma ->tokenize input string
		var items = new StringTokenizer(linkFormat, ",")
		
		while (items.hasMoreTokens) {
			addLinkFormatItem(items.nextToken)
		}

	}
	
	/**
	 * This method returns a resource set from a link format item
	 * 
	 * @param item The link format item.
	 * @return The resource set.
	 */
	def void addLinkFormatItem(String item) {

		var tokens = new StringTokenizer(item, ";")
		
		//Get resource URI as <....> string 
		var identifier = tokens.nextToken
		
		//Trim </...>
		identifier = identifier.substring(2, identifier.length-1)
		
		//Retrieve specified resource, create if necessary
		var resource = subResource(identifier, true)
		
		//Rest of tokens has form ...=...
		while (tokens.hasMoreTokens) {
			populateAttributeFromLinkExtension(resource, tokens.nextToken)
		}
	}
	
	
	/**
	 * This method returns a link format string for the current resource
	 * 
	 * @return The link format string representing the current resource
	 */
	def String toLinkFormatItem() {
		var linkFormat = new StringBuilder
		linkFormat.append("<")
		linkFormat.append(getResourceIdentifier(true))
		linkFormat.append(">;")
		
		if (!this.getResourceName.isEmpty) {
			linkFormat.append("n=\"")
			linkFormat.append(this.getResourceName)
			linkFormat.append("\";")
		} 
		if (!this.getInterfaceDescription.isEmpty) {
			linkFormat.append("d=\"")
			linkFormat.append(this.getInterfaceDescription)
			linkFormat.append("\";")
		}
		if (this.getContentTypeCode != -1) {
			linkFormat.append("ct=")
			linkFormat.append(this.getContentTypeCode)
			linkFormat.append(";")
		} 
		if (this.getMaximumSizeEstimate != -1) {
			linkFormat.append("sz=")
			linkFormat.append(this.getMaximumSizeEstimate)
			linkFormat.append(";")
		} 
		if (this.isObservable) {
			linkFormat.append("obs;")
		}
		linkFormat.deleteCharAt(linkFormat.length-1)
		
		return linkFormat.toString
	}

	/**
	 * This method returns a link format string for the current sub-resource set
	 * 
	 * @return The link format string representing the current sub-resource set
	 */
	def String toLinkFormat() {
		
		var builder = new StringBuilder
		
		buildLinkFormat(builder)
		
		builder.deleteCharAt(builder.length-1)
		
		return builder.toString
	}
	
	/**
	 * This method is used to build the link format representation of the resources.
	 * 
	 */
	def void buildLinkFormat(StringBuilder builder) {

		if (subResources != null) {
			for (Resource resource : subResources.values) {
	
				if (!resource.hidden) {
				
					builder.append(resource.toLinkFormatItem)
					builder.append(',')
				}
				resource.buildLinkFormat(builder)
			}
		}
	}
	
	
	/**
	 * This method returns the resource URI of the current resource.
	 * 
	 * @return The current resource URI.
	 */
	def String getResourceIdentifier(boolean absolute) {
		if (absolute && parent != null) {
			
			var builder = new StringBuilder
			builder.append(parent.getResourceIdentifier(absolute))
			builder.append('/')
			builder.append(resourceIdentifier)
			
			return builder.toString
		} else {
			return resourceIdentifier
		}
	}
	
	/**
	 * This method returns the resource identifier of the current resource.
	 * 
	 * @return The current resource identifier.
	 */
	def String getResourceIdentifier() {
		return getResourceIdentifier(false)
	}

	/**
	 * This method returns the resource name of the current resource.
	 * 
	 * @return The current resource name.
	 */
	def String getResourceName() {
		return resourceName
	}

	/**
	 * This method returns the interface description of the current resource.
	 * 
	 * @return The current resource interface description.
	 */
	def String getInterfaceDescription() {
		return interfaceDescription
	}

	/**
	 * This method returns the content type code of the current resource
	 * 
	 * @return The current resource content type code
	 */
	def int getContentTypeCode() {
		return contentTypeCode
	}

	/**
	 * This method returns the maximum size estimate of the current resource
	 * 
	 * @return The current resource maximum size estimate
	 */
	def int getMaximumSizeEstimate() {
		return maximumSizeEstimate
	}

	/**
	 * This method returns whether the current resource is observable or not
	 * 
	 * @return Boolean value whether the current resource is observable
	 */
	def boolean isObservable() {
		return observable
	}
	
	/**
	 * This method returns the subresources count of the current resource.
	 * 
	 * @return The current resource subresources count.
	 */
	def int subResourceCount() {
		var res = 0
		if (subResources != null){
			res = subResources.size
		}
		return 0
	}
	
	def int totalSubResourceCount() {
		return totalSubResourceCount
	}
	
	/**
	 * This method returns the subresources count of the current resource.
	 * 
	 * @param resourceIdentifier The resource identifier.
	 * @param create If its true and the resource is null creates the resource.
	 * @return The resource identified by the resource identifier.
	 */
	def Resource subResource(String resourceIdentifier, boolean create) {
		
		var pos = resourceIdentifier.indexOf('/')
		var String head = null
		var String tail = null
		if (pos != -1 && pos < resourceIdentifier.length-1) {

			head = resourceIdentifier.substring(0, pos)
			tail = resourceIdentifier.substring(pos+1)
		} else {
			head = resourceIdentifier
			tail = null
		}

		var Resource resource = null
		if (subResources != null) {
			resource = subResources.get(head)
		}
		
		if (resource == null && create) {
			try {
				resource = getClass.newInstance
				
				resource.setResourceIdentifier(head)
				addSubResource(resource)
				
			} catch (InstantiationException e) {
				e.printStackTrace
			} catch (IllegalAccessException e) {
				e.printStackTrace
			}
		}
		
		if (resource != null && tail != null) {
			return resource.subResource(tail, create)
		} else {
			return resource
		}
		
	}
	
	def Resource subResource(String resourceIdentifier) {
		return subResource(resourceIdentifier, false)
	}
	
	def Resource getResource(String resourceIdentifier) {
		var pos = resourceIdentifier.indexOf('/')
		var String head = null
		var String tail = null
		if (pos != -1 && pos < resourceIdentifier.length-1) {

			head = resourceIdentifier.substring(0, pos)
			tail = resourceIdentifier.substring(pos+1)
		} else {
			head = resourceIdentifier
			tail = null
		}
		
		if (head.equals(this.resourceIdentifier)) {
			if (tail != null) {
				return subResource(tail)
			} else {
				return this
			}
		} else {
			return null
		}
	}

    def Resource[] getSubResources() {
		var Resource[] resources
		if (subResources != null) {
			var al = new ArrayList<Resource>
			for (var i = 0; i < subResources.size; i++) {
	  			al.add(null)
			}
			resources = al.toArray as Resource[]
		} else {
			return new ArrayList<Resource>(0).toArray as Resource[]
		}
		var content = subResources.entrySet
		var iter = content.iterator
		var pos = 0
		while (iter.hasNext) {
			var currentEntry = iter.next
			resources.set(pos, currentEntry.getValue)
			pos++
		}
		return resources
	}
	
	def void addSubResource(Resource resource) {
		if (resource != null) {
			if (subResources == null) {
				subResources = new TreeMap<String, Resource>
			}
			subResources.put(resource.resourceIdentifier, resource)
			
			resource.parent = this
			
			var p = resource.parent
			while (p != null) {
				p.totalSubResourceCount++
				p = p.parent
			}
		}
	}
	
	def void removeSubResource(Resource resource) {
		if (resource != null) {
			subResources.remove(resource.resourceIdentifier)
		
			var p = resource.parent
			while (p != null) {
				p.totalSubResourceCount--
				p = p.parent
			}
			
			resource.parent = null
		}
	}
	
	def void remove() {
		if (parent != null) {
			parent.removeSubResource(this)
		}
	}
	
	def void removeSubResource(String resourceIdentifier) {
		removeSubResource(subResource(resourceIdentifier))
	}
	
	def static Resource newRoot(String linkFormat) {
		var resource = new Resource
		resource.setResourceIdentifier("")
		resource.setResourceName("root")
		resource.addLinkFormat(linkFormat)
		return resource
	}
	
	def void log(PrintStream out, int intend) {
		for (var i = 0; i < intend; i++) out.append(' ')
		out.println("+[" + resourceIdentifier + "] " + resourceName)
		if (subResources != null) {
			for (Resource sub : subResources.values) {
				sub.log(out, intend+2)
			}
		}
	}
	def void log (){
		log(System.out, 0)
	}
	
	def void createNew(PutRequest request, String newIdentifier) { }
	
	override performGet(GetRequest request) { }
	
	override performPost(PostRequest request) { }
	
	override performPut(PutRequest request) { }
	
	override performDelete(DeleteRequest request) { }
}
/**
 * Class that represents a Local Resource. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class LocalResource extends Resource {

	Map<String, GetRequest> observeRequests
	
	new (String resourceIdentifier, boolean hidden) {
		super(resourceIdentifier, hidden)
	}
	new (String resourceIdentifier) {
		super(resourceIdentifier, false)
	}

	def void addObserveRequest(GetRequest request) {
		if (request != null) {
			if (observeRequests == null) {
				observeRequests = new HashMap<String, GetRequest>
			}
			observeRequests.put(request.endpointID, request)
			System.out.println("Observation relationship between " 
				+ request.endpointID + " and " + getResourceIdentifier 
				+ " established."
			)
		}
	}
	
	def void removeObserveRequest(String endpointID) {
		
		if (observeRequests != null) {
			if (observeRequests.remove(endpointID) != null) {
				System.out.println("Observation relationship between " 
					+ endpointID + " and " + getResourceIdentifier 
					+ " terminated."
				)
			}
		}
	}

	def isObserved(String endpointID) {
		return observeRequests != null && observeRequests.containsKey(endpointID)
	}
	
	def protected void processObserveRequests() {
		if (observeRequests != null) {
			for (GetRequest request : observeRequests.values) {
				performGet(request)
			}
		}
	}
	
	def protected void changed() {
		processObserveRequests
	}
	
	@Override
	override void performGet(GetRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}

	@Override
	override void performPut(PutRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}
	
	@Override
	override void performPost(PostRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}
	
	@Override
	override void performDelete(DeleteRequest request) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}

	@Override
	override void createNew(PutRequest request, String newIdentifier) {
		request.respond(Code.RESP_NOT_IMPLEMENTED)
	}		
}
/**
 * Class that represents a Read Only Resource. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class ReadOnlyResource extends LocalResource {
	
	/**
	 * Constructor for a new ReadOnlyResource
	 * 
	 * @param resourceIdentifier The resource identifier
	 */
	new(String resourceIdentifier) {
		super(resourceIdentifier)
	}
	
	@Override
	override void performPut(PutRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void performPost(PostRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void performDelete(DeleteRequest request) {
		request.respond(Code.RESP_METHOD_NOT_ALLOWED)
	}
	
	@Override
	override void createNew(PutRequest request, String newIdentifier) {
		request.respond(Code.RESP_FORBIDDEN)
	}
}
/**
 * Class that represents a Discovery Resource. 
 *
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
class DiscoveryResource extends ReadOnlyResource {
	
	val public static String DEFAULT_IDENTIFIER = "core"
	
	Resource root
	
	/**
	 * Constructor for a new DiscoveryResource
	 * 
	 * @param root The root resource for the discovery
	 */
	new (Resource root) {
		super(DEFAULT_IDENTIFIER)
		this.root = root
		setContentTypeCode(ContentFormat.LINK_FORMAT)
	}
	
	@Override
	override void performGet(GetRequest request) {
		var response = new Response(Code.RESP_CONTENT)
		response.setPayload(root.toLinkFormat, getContentTypeCode)
		request.respond(response)
	}
}