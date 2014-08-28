package com.xtend.example

import org.apache.http.HttpHost
import org.apache.http.client.config.RequestConfig
import org.apache.http.client.methods.HttpGet
import org.apache.http.impl.client.HttpClients
import org.apache.http.util.EntityUtils
import org.apache.http.client.methods.HttpPost
import java.util.ArrayList
import org.apache.http.NameValuePair
import org.apache.http.message.BasicNameValuePair
import org.apache.http.client.entity.UrlEncodedFormEntity
import org.apache.http.client.methods.HttpDelete
import org.apache.http.client.methods.HttpPut

class SampleHttpClient {
	def static void main(String[] args) {
		var httpclient = HttpClients.createDefault
		try {
			
			var target = new HttpHost("localhost", 5683, "coap")
	        var proxy = new HttpHost("localhost", 8000, "http")
	        
	        var config = RequestConfig.custom.setProxy(proxy).build
//            var request = new HttpGet("/storage")
            var request = new HttpDelete("/storage")
//            var request = new HttpPut("/storage")
//			var request = new HttpPost("/storage")
//            var postParameters = new ArrayList<NameValuePair>
//            postParameters.add(new BasicNameValuePair("payload", "6"))
//            request.setEntity(new UrlEncodedFormEntity(postParameters))
            request.setConfig(config)

            System.out.println("Executing request " + request.getRequestLine() + " to " + target + " via " + proxy)

            var response = httpclient.execute(target, request)
            try {
                System.out.println("----------------------------------------")
                System.out.println(response.getStatusLine)
                if (response.getEntity != null) {
                	System.out.println(EntityUtils.toString(response.getEntity))
                }
                EntityUtils.consume(response.getEntity)
                
            } finally {
                response.close
            }
		} finally {
            httpclient.close
        }
	    
	}
}