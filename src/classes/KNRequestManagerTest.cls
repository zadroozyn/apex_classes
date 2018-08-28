@isTest global class KNRequestManagerTest {

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
		tdf.orderStages.createSObject('Processing', so1.Id, false);
		tdf.orderStages.insertAll();
	}

	@isTest static void testCongaNormalResponse() {
		Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilderWithDuplicates('https://www.appextremes.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	@isTest static void testCongaTimeout() {
		Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilderWithDuplicates('https://www.appextremes.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	@isTest static void testAnyRequestNormalResponse() {
		Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilderWithDuplicates('example.net', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	global class TimeoutThrower implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest req) {
			throw new CalloutException();
			return null;
		}
	}

	global class ResponseMock implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest req) {
			return new HttpResponse();
		}
	}
}