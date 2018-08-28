@isTest
public class MasterOrderWrapperTest {

	@testSetup
	static void testsetup() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account tAccount = tdf.accounts.createSObject('Japan test', 'CHF', false);
		tdf.accounts.insertAll();
		Master_order__c tMO = tdf.masterOrders.createSObject(tAccount.Id, RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal'), false);
		Master_order__c tMO2 = tdf.masterOrders.createSObject(tAccount.Id, RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Order'), false);
		PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(tAccount.Id, 'Pre-order', null, false);
		so.Master_order__c = tMO2.Id;
		tdf.salesOrders.insertAll();
		tdf.masterOrders.insertAll();
	}

	@isTest
	static void testWrapperNoLines() {
		TestDataFactory tdf = TestDataFactory.instance;
		MasterOrderWrapper mow = new MasterOrderWrapper((Master_order__c)tdf.masterOrders.getSobject('0'), new List<PBSI__PBSI_Sales_Order__c>());
	}

	@isTest
	static void testWrapperWithLines() {
		TestDataFactory tdf = TestDataFactory.instance;
		MasterOrderWrapper mow = new MasterOrderWrapper((Master_order__c)tdf.masterOrders.getSobject('1'), new List<PBSI__PBSI_Sales_Order__c>{(PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObject('0')});
	}
}