public class CongaFileGenerator {
	public CongaFileGenerator () {}

	public static String sendRequest(String url) {
		HttpResponse res = getResponse(getRequest(url));
		return res.getBody();
	}

	private static HttpRequest getRequest(String url) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('GET'); 
		req.setTimeout(60000);
		return req;
	}

	private static HttpResponse getResponse(HttpRequest req){
		Http h = new Http();
		return h.send(req);
	}
}