package com.xtend.test

import static org.junit.Assert.*
import org.junit.Test

import com.xtend.coap.resource.Resource



class ResourceTest {
	@Test
	def void simpleTest () {
		var input = "</sensors/temp>ct=41n=\"TemperatureC\""
		var root = Resource.newRoot(input)
		var res = root.getResource("/sensors/temp")
		assertNotNull(res)
		assertEquals("temp",res.getResourceIdentifier)
		assertEquals(41,res.getContentTypeCode)
		assertEquals("TemperatureC", res.getResourceName)
	}
	
	@Test
	def void extendedTest () {
		var input = "</myUri/something>n=\"MyName\"d=\"/someRef/path\"ct=42sz=10obs"
		var root = Resource.newRoot(input)
		var res = root.getResource("/myUri/something")
		assertNotNull(res)
		assertEquals("something",res.getResourceIdentifier)
		assertEquals("MyName", res.getResourceName)
		assertEquals("/someRef/path", res.getInterfaceDescription)
		assertEquals(42,res.getContentTypeCode)
		assertEquals(10, res.getMaximumSizeEstimate)
		assertTrue(res.isObservable)
	}
	
	@Test
	def void conversionTest () {
		var ref = "</myUri>,</myUri/something>n=\"MyName\"d=\"/someRef/path\"ct=42sz=10obs"
		var res = Resource.newRoot(ref)
		var result = res.toLinkFormat
		System.out.println(result)
		assertEquals(ref, result)
	}
	
	@Test
	def void twoResourceTest () {
		var resourceInput1 = "</myUri>,</myUri/something>n=\"MyName\"d=\"/someRef/path\"ct=42sz=10obs"
		var resourceInput2 = "</sensors>,</sensors/temp>n=\"TemperatureC\"ct=41"
		var resourceInput = resourceInput1 + "," + resourceInput2
		var resource = Resource.newRoot(resourceInput)
		assertEquals(resourceInput, resource.toLinkFormat)
	}
}