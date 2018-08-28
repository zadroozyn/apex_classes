@isTest
private class PaymentTermsServiceTest {
	
	@isTest static void assignPreOrderTerms() {
		TestDataFactory tdf = TestDataFactory.instance;
		for(String soType: PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms) {
			tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), soType, null, false);
		}
		tdf.salesOrders.insertAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.assertEquals(tdf.paymentTerms.getSObjectId('Preorder'), so.get('On_Payment_Term__c'));
		}
	}
	
	@isTest static void assignNormalTerms() {
		TestDataFactory tdf = TestDataFactory.instance;
		for(String soType: getTypePicklistValues()) {
			if(!PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms.contains(soType)) {
				tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), soType, null, false);				
			}
		}
		tdf.salesOrders.insertAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.assertEquals(tdf.paymentTerms.getSObjectId('Normal'), so.get('On_Payment_Term__c'));
		}
	}
	@isTest static void updateOldPreorder() {
		TestDataFactory tdf = TestDataFactory.instance;
		for(String soType: PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms) {
			tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), soType, null, false);
		}
		tdf.salesOrders.insertAll();
		Set<String> allNotCoveredByPreorderTerms = new Set<String>(getTypePicklistValues());
		allNotCoveredByPreorderTerms.removeAll(PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms);
		String notCoveredByPreorderTerms = new List<String>(allNotCoveredByPreorderTerms)[0];
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			so.put('Sales_Order_Type__c', notCoveredByPreorderTerms);
		}

		tdf.salesOrders.updateAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.assertEquals(tdf.paymentTerms.getSObjectId('Normal'), so.get('On_Payment_Term__c'));
		}
	}
	
	@isTest static void updateNewPreorder() {
		TestDataFactory tdf = TestDataFactory.instance;
		for(String soType: getTypePicklistValues()) {
			if(!PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms.contains(soType)) {
				tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), soType, null, false);				
			}
		}
		tdf.salesOrders.insertAll();
		String coveredByPreorderTerms = new List<String>(PaymentTermsService.salesOrdersTypesDefaultPreOrderTerms)[0];
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			so.put('Sales_Order_Type__c', coveredByPreorderTerms);
		}

		tdf.salesOrders.updateAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.assertEquals(tdf.paymentTerms.getSObjectId('Preorder'), so.get('On_Payment_Term__c'));
		}
	}
	
	@isTest static void updateOldNormalNewEmptyTerms() {
		TestDataFactory tdf = TestDataFactory.instance;
		for(String soType: getTypePicklistValues()) {
			tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), soType, null, false);
		}
		tdf.salesOrders.insertAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.debug('Order: '+ so.get('Sales_Order_Type__c')+', Terms: '+so.get('On_Payment_Term__c'));
		}
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			so.put('On_Payment_Term__c', null);
		}

		tdf.salesOrders.updateAll();
		tdf.salesOrders.refresh();
		for(sObject so: tdf.salesOrders.getAllSObjects()) {
			System.assertNotEquals(null, so.get('On_Payment_Term__c'));
		}
	}

	@isTest static void assignTermsFromMasterOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		Master_Order__c mo = tdf.masterOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), RecordTypeService.getRecordTypeIdByDeveloperName('Master_Order__c', 'Order'), false);
		tdf.masterOrders.insertAll();
		system.debug(mo);
		Test.startTest();
		PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Pre-Order', null, false);
		so.Master_Order__c = mo.Id;
		tdf.salesOrders.insertAll();
		Test.stopTest();
		tdf.salesOrders.refresh();
		tdf.masterOrders.refresh();
		System.assertEquals(tdf.masterOrders.getSObject('0').get('On_Payment_Term__c'), tdf.salesOrders.getSObject('0').get('On_Payment_Term__c'));
	}

	@isTest static void updateChildOrderWithNewPaymentTerms() {
		TestDataFactory tdf = TestDataFactory.instance;
		Master_Order__c mo = tdf.masterOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), RecordTypeService.getRecordTypeIdByDeveloperName('Master_Order__c', 'Order'), false);
		mo.On_Payment_Term__c = tdf.paymentTerms.getSObjectId('MasterOrder');
		tdf.masterOrders.insertAll();
		PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Pre-Order', null, false);
		so.Master_Order__c = mo.Id;
		tdf.salesOrders.insertAll();
		Test.startTest();
		PaymentTermsService.mOrderHelper = null;
		so.On_Payment_Term__c = tdf.paymentTerms.getSObjectId('Preorder');
		tdf.salesOrders.upsertAll();
		Test.stopTest();
		tdf.salesOrders.refresh();
		tdf.masterOrders.refresh();
		System.assertEquals(tdf.masterOrders.getSObject('0').get('On_Payment_Term__c'), tdf.salesOrders.getSObject('0').get('On_Payment_Term__c'));
	}
	
	private static List<String> getTypePicklistValues() {
		List<String> values = new List<String>();
		List<Schema.PicklistEntry> ple = PBSI__PBSI_Sales_Order__c.Sales_Order_Type__c.getDescribe().getPicklistValues();
		for(Schema.PicklistEntry pe: ple) {
			values.add(pe.getValue());
		}
		return values;
	}
	
	@testSetup 
	static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.paymentTerms.createSObject('Normal', 7, false);
		tdf.paymentTerms.createSObject('Preorder', 7, false);
		tdf.paymentTerms.createSObject('MasterOrder', 7, false);
		tdf.paymentTerms.insertAll();
		System.debug(tdf.paymentTerms.getSObject('Normal'));
		System.debug(tdf.paymentTerms.getSObject('Preorder'));
		System.debug(tdf.paymentTerms.getSObject('MasterOrder'));
		tdf.accounts.createSObject('Test_account', 'CHF', false);
		tdf.accounts.getSObject('Test_account').put('On_Payment_Term__c', tdf.paymentTerms.getSObjectId('Normal'));
		tdf.accounts.getSObject('Test_account').put('On_Payment_Terms_Pre_Order__c', tdf.paymentTerms.getSObjectId('Preorder'));
		tdf.accounts.insertAll();
	}	
}