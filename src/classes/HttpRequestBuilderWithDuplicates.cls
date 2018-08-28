public class HttpRequestBuilderWithDuplicates extends HttpRequestBuilder {

	private Map<String, Set<String>> mapParams;

	public HttpRequestBuilderWithDuplicates(String endpoint, String method) {
		super(endpoint, method);
		mapParams = new Map<String, Set<String>>();
	}

	public override void setParam(String key, String value) {
		if(!mapParams.containsKey(key)) {
			mapParams.put(key, new Set<String>());
		}
		mapParams.get(key).add(value);
	}

	public override HttpRequest getRequest() {
		MethodBuilder builder;
		if(method == 'get') {
			builder = new GetBuilder(this);
			return builder.getRequest();
		}
		return super.getRequest();
	}

	private class GetBuilder implements MethodBuilder {
		private HttpRequestBuilderWithDuplicates httpBuilder;
		public GetBuilder(HttpRequestBuilderWithDuplicates httpBuilder) {
			this.httpBuilder = httpBuilder;
		}
		public HttpRequest getRequest() {
			HttpRequest req = new HttpRequest();
			req.setMethod('GET');
			String uri = httpBuilder.getEndpoint();
			if(!httpBuilder.mapParams.isEmpty()) {
				uri += '?';
			}
			List<String> params = new List<String>();
			for(String key: httpBuilder.mapParams.keySet()) {
				for(String value : httpBuilder.mapParams.get(key)){
					params.add(key + '=' + value);
				}
			}
			uri += String.join(params,'&');
			uri.trim();
			for(String key: httpBuilder.getMapHeaders().keySet()) {
				req.setHeader(key, httpBuilder.getMapHeaders().get(key));
			}
			if(!String.isBlank(httpBuilder.getEncodingScheme())) {
				uri = EncodingUtil.urlEncode(uri, httpBuilder.getEncodingScheme());
			}
			req.setEndpoint(uri);
			req.setTimeout(this.httpBuilder.timeout);
			return req;
		}
	}
}