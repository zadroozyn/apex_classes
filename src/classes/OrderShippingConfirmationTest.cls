@isTest
private class OrderShippingConfirmationTest {

	@isTest static void shippingConfirmationB2C() {
		new TestCustomSettingsFactory();
		TestUtility.enableAllFeatures();
		String currencyIsoCode = 'EUR';

		Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
		test_account.BillingCountry = 'Poland';
		test_account.BillingCity = 'Warsaw';
		test_account.BillingPostalCode = '00-123';
		test_account.BillingStreet = 'Marszałkowska 123';
		insert test_account;

		Contact test_contact = TestUtility.createContact('Test Contact', test_account, false);
		test_contact.Email = 'test@example.com';
		insert test_contact;

		Id weborderRecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order');
		PBSI__PBSI_Location__c location = TestUtility.createLocation('test location', null, false);
		location.Shipment_Provider__c = 'UPS';
		insert location;

		Tracking_Providers__c provider = new Tracking_Providers__c(
			Name = 'UPS',
			Base_Url__c = 'www.example.com?track='
			);
		insert provider;

		PBSI__PBSI_Sales_Order__c salesOrder = TestUtility.createSalesOrder(test_account, test_contact, weborderRecordTypeId, currencyIsoCode, false);
		salesOrder.PBSI__From_Location__c = location.Id;
		insert salesOrder;

		ProcessRealization pInstance = new ProcessRealization(salesOrder.Id, new MockProcess());
		Tracking__c tr = new Tracking__c(Sales_Order__c = salesOrder.Id, Service_Provider__c = provider.Name, Contact__c = test_contact.Id);
		insert tr;

		pInstance.context.put('trackingObjId', tr.Id);

		Test.startTest();
		OrderShippingConfirmation step = new OrderShippingConfirmation();
		step.executeStep(pInstance);
		step.getStepName();
		Test.stopTest();
		PBSI__PBSI_Sales_Order__c order = [SELECT Id, KN_Shipping_Notice_Sent__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: salesOrder.Id];
		System.assertEquals(true, order.KN_Shipping_Notice_Sent__c);
	}

	@isTest static void shippingConfirmationB2B() {
		TestUtility.enableAllFeatures();
		String currencyIsoCode = 'EUR';

		Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
		test_account.BillingCountry = 'Poland';
		test_account.BillingCity = 'Warsaw';
		test_account.BillingPostalCode = '00-123';
		test_account.BillingStreet = 'Marszałkowska 123';
		insert test_account;

		Contact test_contact = TestUtility.createContact('Test Contact', test_account, false);
		test_contact.Email = 'test@example.com';
		insert test_contact;

		Id b2bRecordTypeID = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_Portal');
		PBSI__PBSI_Location__c location = TestUtility.createLocation('test location', null, false);
		location.Shipment_Provider__c = 'UPS';
		insert location;

		Tracking_Providers__c provider = new Tracking_Providers__c(
			Name = 'UPS',
			Base_Url__c = 'www.example.com?track='
			);
		insert provider;

		PBSI__PBSI_Sales_Order__c salesOrder = TestUtility.createSalesOrder(test_account, test_contact, b2bRecordTypeID, currencyIsoCode, false);
		salesOrder.PBSI__From_Location__c = location.Id;
		insert salesOrder;

		ProcessRealization pInstance = new ProcessRealization(salesOrder.Id, new MockProcess());
		Tracking__c tr = new Tracking__c(Sales_Order__c = salesOrder.Id);
		insert tr;

		pInstance.context.put('trackingObjId', tr.Id);

		Test.startTest();
		OrderShippingConfirmation step = new OrderShippingConfirmation();
		step.executeStep(pInstance);
		step.getStepName();
		Test.stopTest();
		PBSI__PBSI_Sales_Order__c order = [SELECT Id, KN_Shipping_Notice_Sent__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: salesOrder.Id];
		System.assertEquals(true, order.KN_Shipping_Notice_Sent__c);
	}

	public class MockProcess implements IProcessDefinition {
		private List<String> steps = new List<String>{};

		public Queue getStepsQueue() {
			return new Queue(steps);
		}
		
		public String getProcessName() {
			return 'MockProcess';
		}
	}
	
}