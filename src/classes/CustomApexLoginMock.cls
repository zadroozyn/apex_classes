@isTest
public class CustomApexLoginMock implements HttpCalloutMock {

	protected Integer code;
	protected String status;
	protected String body;

	public CustomApexLoginMock() {
		this.body = '12309183910283091283109238';
		this.status = 'OK';
		this.code = 200;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setBody(this.body);
		res.setStatusCode(this.code);
		res.setStatus(this.status);
		return res;
	}
}