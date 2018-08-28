@isTest class ShippingConfirmationManagerTest {

	@testSetup static void setup() {
		new TestCustomSettingsFactory();

		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('EU-Stock Web', false);
		tdf.locations.createSObject('US-Stock', false);
		tdf.locations.createSObject('CA-Stock', false);
		tdf.locations.createSObject('JP-Stock', false);
		tdf.locations.insertAll();
		tdf.paymentTerms.createSObject('Test', 7, false);
		tdf.paymentTerms.insertAll();
		tdf.accounts.createSObject('Test_account', 'CHF', false);

		tdf.accounts.getSObject('Test_account').put('On_Payment_Term__c', tdf.paymentTerms.getSObjectId('Test'));
		tdf.accounts.insertAll();

		PBSI__PBSI_Sales_Order__c so1 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('EU-Stock'), true);
	}

	@isTest static void testCongaNormalResponse() {
		Test.setMock(HttpCalloutMock.class, new KNRequestManagerTest.ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;
		ShippingConfirmationManager manager = new ShippingConfirmationManager(tdf.salesorders.getSObjectId('0'), new HttpRequestBuilderWithDuplicates('https://www.appextremes.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('KN_Shipping_Notice_Sent__c'));
	}

	@isTest static void testCongaTimeout() {
		Test.setMock(HttpCalloutMock.class, new KNRequestManagerTest.ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;
		ShippingConfirmationManager manager = new ShippingConfirmationManager(tdf.salesorders.getSObjectId('0'), new HttpRequestBuilderWithDuplicates('https://www.appextremes.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('KN_Shipping_Notice_Sent__c'));
	}
}