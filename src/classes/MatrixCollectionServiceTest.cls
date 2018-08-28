@isTest
private class MatrixCollectionServiceTest {
	
	@isTest static void test_method_one() {
		MatrixCollectionService srv = new MatrixCollectionService();
		srv.getCollectionTypes('Re-Order');
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();
	}
	
}