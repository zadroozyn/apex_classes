@isTest
private class B24AuthorizationTest {
	
	@isTest static void authorization() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout('SLSRPT'));
		B24Authorization authObj = new B24Authorization();
		Test.startTest();
    	authObj.authorize();
		Test.stopTest();

		System.assertNOTEquals(null, authObj.getEndpointKey());
		System.assertNOTEquals(null, authObj.getAuthHeader());
		System.assert(authObj.isValid());
	}
	
	@testSetup static void setup() {
		new TestCustomSettingsFactory();
	}
}