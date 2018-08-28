@isTest
private class ONRLogisticsGatewayTest {
	@isTest static void testMethod1() {
		System.assert(!String.isBlank(ONRLogisticsGateway.KN_ENDPOINT));
	}
	@testSetup static void setup() {
		TestUtility.createKNIntegrationSettings(true);
	}
}