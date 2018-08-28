@isTest
private class MasterOrderDetailControllerExtensionTest {
	
	@isTest static void test_method_one() {
		TestDataFactory tdf = TestDataFactory.instance;
		ApexPages.StandardController  stdCtrl = 
			new ApexPages.StandardController(tdf.masterOrders.getAllSObjects()[0]);
		MasterOrderDetailControllerExtension ctrl = new MasterOrderDetailControllerExtension(stdCtrl);
	}

	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		SObject acc = tdf.accounts.createSObject('Parent_Account', 'CHF', true);
		SObject loc = tdf.locations.createSObject('EU-Stock', true);
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);
		
		Sizes__c size = new Sizes__c(
			Type__c = '1',
			European_Size__c = '20'
		);
		insert size;

		SObject item = tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', loc.Id, 
			itemGroup.Id, '7640165317761', false);
		tdf.items.getSObject('4.4102 W 6.5').put('Size__c', size.Id);
		tdf.items.insertAll();
		
		SObject mo = tdf.masterOrders.createSObject(acc.Id, 
			RecordTypeService.getRecordTypeIdByDeveloperName('Master_Order__c','Order'), true);

		SObject so = tdf.salesOrders.createSObject(acc.Id, 'Re-Order', loc.Id, false);
		tdf.salesOrders.getAllSObjects()[0].put('Master_Order__c', mo.Id);
		tdf.salesOrders.insertAll();
		PBSI__PBSI_Sales_Order_Line__c line = new PBSI__PBSI_Sales_Order_Line__c(
			PBSI__Sales_Order__c = so.Id,
			PBSI__Item__c = item.Id
		);
		insert line;
	}
	
}