public with sharing class CustomApexLogin {
	public static String getSessionId() {
		HttpRequest req = new HttpRequest();
		if(Test.isRunningTest()) {
			req.setEndpoint('http://callout.ApexConnector/services/apexrest/on/sessionInfo');
		} else {
			req.setEndpoint('callout:ApexConnector/services/apexrest/on/sessionInfo');
		}
		req.setMethod('GET');
		HTTPResponse res = new Http().send(req);
		return res.getBody().substring(1, res.getBody().length()-1);
	}
}