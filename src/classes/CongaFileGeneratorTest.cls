@isTest
private class CongaFileGeneratorTest {
	
	@isTest static void testCallout() {
		Test.setMock(HttpCalloutMock.class, new CongaFileGeneratorMock());
		Test.startTest();
		String reqBody = CongaFileGenerator.sendRequest('http://www.test.com'); // Not important !!
		System.assert(reqBody.length() > 0);
		Test.stopTest();
	}
	
	
}