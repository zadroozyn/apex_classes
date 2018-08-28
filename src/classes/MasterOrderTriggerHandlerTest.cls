@isTest
class MasterOrderTriggerHandlerTest {

	@testSetup
	static void testsetup() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account tAccount = tdf.accounts.createSObject('Japan test', 'CHF', false);
		tdf.accounts.insertAll();
		Master_order__c tMO = tdf.masterOrders.createSObject(tAccount.Id, RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal'), false);
		Master_order__c tMO2 = tdf.masterOrders.createSObject(tAccount.Id, RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Order'), false);
		PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(tAccount.Id, 'Pre-order', null, false);
		PBSI__PBSI_Sales_Order__c so2 = tdf.salesOrders.createSObject(tAccount.Id, 'Pre-order', null, false);
		tdf.masterOrders.insertAll();
		tdf.salesOrders.insertAll();
		so.Master_order__c = tMO.Id;
		so2.Master_order__c = tMO2.Id;
		tdf.salesOrders.updateAll();
	}


	@isTest
	static void testWrapperWithLines() {
		TestDataFactory tdf = TestDataFactory.instance;
		Master_order__c mo = (Master_order__c)tdf.masterorders.getSObject('0');
		mo.Early_bird_discount__c = 10;
		mo.Pre_order_discount__c = 10;
		mo.Visibility_discount__c = 10;
		update mo;
		tdf.salesorders.refresh();
		PBSI__PBSI_Sales_Order__c so = (PBSI__PBSI_Sales_Order__c)tdf.salesorders.getSObject('0');
		System.assertEquals(mo.Early_bird_discount__c, so.Early_bird_discount__c);
		System.assertEquals(mo.Visibility_discount__c, so.Visibility_discount__c);
		System.assertEquals(mo.Pre_order_discount__c, so.Pre_Order_Discount_override__c);
	}

	@isTest
	static void testRecordTypePropagation() {
		TestDataFactory tdf = TestDataFactory.instance;
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Sales_order'), tdf.salesorders.getSObject('0').get('RecordTypeId'));
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Sales_order'), tdf.salesorders.getSObject('1').get('RecordTypeId'));
		Master_order__c mo1 = (Master_order__c)tdf.masterorders.getSObject('0');
		Master_order__c mo2 = (Master_order__c)tdf.masterorders.getSObject('1');
		Test.startTest();
		mo1.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Order');
		mo2.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal');
		tdf.masterorders.updateAll();
		Test.stopTest();

		tdf.salesorders.refresh();
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_Portal'), [select id, recordtypeid from PBSI__PBSI_Sales_Order__c where master_order__c =: mo1.Id].RecordTypeId);
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal'), [select id, recordtypeid from PBSI__PBSI_Sales_Order__c where master_order__c =: mo2.Id].RecordTypeId);
	}
}