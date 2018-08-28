@isTest
global with sharing class SORequestManagerTest {

	@testSetup 
	static void setup() {
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

	@isTest
	static void testRequestWithResponseSave() {
		Test.setMock(HttpCalloutMock.class, new PositiveResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		/*System.assert('TEST' == (String)tdf.salesOrders.getSObject('0').get('Bill_Of_Delivery_PDF_Id__c'));*/
	}

	@isTest
	static void testRequestWithoutResponseSave() {
		Test.setMock(HttpCalloutMock.class, new PositiveResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
	}

	@isTest
	static void testRequestWithResponseSaveTimeout() {
		Test.setMock(HttpCalloutMock.class, new TimeoutThrower());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert(!(boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
	}

	@isTest
	static void testCongaNormalResponse() {
		Test.setMock(HttpCalloutMock.class, new PositiveResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	@isTest
	static void testCongaTimeout() {
		Test.setMock(HttpCalloutMock.class, new PositiveResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	@isTest
	static void testAnyRequestNormalResponse() {
		Test.setMock(HttpCalloutMock.class, new PositiveResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('example.net', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		tdf.salesOrders.refresh();
		System.assert((boolean)tdf.salesOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assert(tdf.salesOrders.getSObject('0').get('Transmission_Count__c') == 1);
	}

	@isTest
	static void testCongaError() {
		Test.setMock(HttpCalloutMock.class, new CongaErrorResponse());
		TestDataFactory tdf = TestDataFactory.instance;
		SORequestManager manager = new SORequestManager(tdf.salesorders.getSObjectId('0'), tdf.orderStages.getSObjectId('0'));
		manager.addRequestBuilder(new HttpRequestBuilder('https://www.composer.congamerge.com/apps/Conga/PM.aspx', 'GET'));
		Test.startTest();
		manager.enqueue();
		Test.stopTest();
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Type__c = 'CONGA_FAILURE'];
		System.assert(!logs.isEmpty());
	}

	global class TimeoutThrower implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest req) {
			throw new CalloutException();
		}
	}

	global class PositiveResponse implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest req) {
			HttpResponse resp = new HttpResponse();
			resp.setStatusCode(200);
			resp.setStatus('OK');
			resp.setBody('TEST');
			return resp;
		}
	}

	global class CongaErrorResponse implements HttpCalloutMock {
		global HttpResponse respond(HttpRequest req) {
			HttpResponse resp = new HttpResponse();
			resp.setStatusCode(200);
			resp.setStatus('OK');
			resp.setBody('error: Failed to run the post merge process.');
			return resp;
		}
	}
}