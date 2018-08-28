@isTest
private class CustomApexLoginTest {

	@isTest
	static void testSuccesfullResponse(){
		Test.setMock(HttpCalloutMock.class, new CustomApexLoginMock());
		Test.startTest();

		boolean isError = false;
		String sessionId = '';

		try{
			sessionId = CustomApexLogin.getSessionId();
		} catch(Exception e) {
			isError = true;
		}

		System.assert(!isError);
		System.assert(String.isNotBlank(sessionId));

		Test.stopTest();
	}
}