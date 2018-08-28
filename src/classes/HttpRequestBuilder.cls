public virtual class HttpRequestBuilder {

	public class MethodException extends Exception {}
	
	public Map<String,String> mapParams;
	private Map<String,String> mapHeaders;
	private String endpoint;
	private Object body;
	protected String method;
	public Integer timeout = 120000;
	private String encodingScheme;

	public HttpRequestBuilder(String endpoint, String method) {
		this.endpoint = endpoint;
		this.method = method;
		mapParams = new Map<String,String>();
		mapHeaders = new Map<String,String>();
	}

	public virtual void setParam(String key, String value) {
		mapParams.put(key,value);
	}

	public void setHeader(String key, String value) {
		mapHeaders.put(key,value);
	}

	public void setTimeout(Integer val) {
		this.timeout = val;
	}

	public void clearParams() {
		mapParams.clear();
	}

	public void clearHeaders() {
		mapHeaders.clear();
	}

	public void setBody(Object body) {
		this.body = body;
	}

	public void setEncodingScheme(String encodingScheme) {
		this.encodingScheme = encodingScheme;
	}

	public String getEncodingScheme() {
		return encodingScheme;
	}

	public String getEndpoint() {
		return endpoint;
	}

	public Map<String, String> getMapHeaders() {
		return mapHeaders;
	}

	public HttpResponse sendRequest() {
		HttpRequest req = this.getRequest();
		System.debug('!!!### req '+req);
		return new Http().send(req);
	}

	@testVisible
	public virtual HttpRequest getRequest() {
		MethodBuilder builder;
		if(method.equalsIgnoreCase('get')) {
			builder = new GetBuilder(this);
		} else if(method.equalsIgnoreCase('post')) {
			builder = new PostBuilder(this);
		} else if(method.equalsIgnoreCase('put')) {
			builder = new PutBuilder(this);
		} else {
			throw new MethodException('Method not defined: '+method);
		}
		return builder.getRequest();
	}

	public interface MethodBuilder {
		HttpRequest getRequest();
	}

	private class GetBuilder implements MethodBuilder {
		private HttpRequestBuilder httpBuilder;
		public GetBuilder(HttpRequestBuilder httpBuilder) {
			this.httpBuilder = httpBuilder;
		}
		public HttpRequest getRequest() {
			HttpRequest req = new HttpRequest();
			req.setMethod('GET');
			String uri = httpBuilder.endpoint;
			if(!httpBuilder.mapParams.isEmpty()) {
				uri += '?';
			}
			List<String> params = new List<String>();
			for(String key: httpBuilder.mapParams.keySet()) {
				params.add(
					key+'='+httpBuilder.mapParams.get(key)
				);
			}
			uri += String.join(params,'&');
			uri.trim();
			for(String key: httpBuilder.mapHeaders.keySet()) {
				req.setHeader(key, httpBuilder.mapHeaders.get(key));
			}
			if(!String.isBlank(httpBuilder.encodingScheme)) {
				uri = EncodingUtil.urlEncode(uri, httpBuilder.encodingScheme);
			}
			req.setEndpoint(uri);
			req.setTimeout(this.httpBuilder.timeout);
			return req;
		}

	}

	private class PutBuilder implements MethodBuilder {
		private HttpRequestBuilder httpBuilder;
		public PutBuilder(HttpRequestBuilder httpBuilder) {
			this.httpBuilder = httpBuilder;
		}
		public HttpRequest getRequest() {
			HttpRequest req = new HttpRequest();
			req.setMethod('PUT');
			String uri = httpBuilder.endpoint;
			uri.trim();
			for(String key: httpBuilder.mapHeaders.keySet()) {
				req.setHeader(key, httpBuilder.mapHeaders.get(key));
			}
			if(!String.isBlank(httpBuilder.encodingScheme)) {
				uri = EncodingUtil.urlEncode(uri, httpBuilder.encodingScheme);
			}
			req.setEndpoint(uri);
			req.setTimeout(this.httpBuilder.timeout);
			return req;
		}
	}

	private class PostBuilder implements MethodBuilder {
		private HttpRequestBuilder httpBuilder;
		public PostBuilder(HttpRequestBuilder httpBuilder) {
			this.httpBuilder = httpBuilder;
		}
		public HttpRequest getRequest() {
			HttpRequest req = new HttpRequest();
			req.setMethod('POST');
			if(httpBuilder.body instanceof String) {
				req.setBody((String)httpBuilder.body);
			} else If(httpBuilder.body instanceof Blob) {
				req.setBodyAsBlob((Blob)httpBuilder.body);
			} else If(httpBuilder.body instanceof Dom.Document) {
				req.setBodyDocument((Dom.Document)httpBuilder.body);
			} else {
				throw new MethodException('Unsupported type of body.');
			}
			for(String key: httpBuilder.mapHeaders.keySet()) {
				req.setHeader(key, httpBuilder.mapHeaders.get(key));
			}
			String uri = httpBuilder.endpoint;
			if(!String.isBlank(httpBuilder.encodingScheme)) {
				uri = EncodingUtil.urlEncode(uri, httpBuilder.encodingScheme);
			}
			req.setEndpoint(uri);
			req.setTimeout(this.httpBuilder.timeout);
			return req;
		}
	}
}