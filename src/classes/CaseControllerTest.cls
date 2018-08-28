@isTest
private class CaseControllerTest {
	
	@isTest static void test_method_one() {
		TestDataFactory tdf = TestDataFactory.instance;
		Case c = new Case(
			Subject = 'test s',
			AccountId = tdf.accounts.getAllSObjects()[0].Id
		);
		insert c;
		Warranty_Line__c wl = new Warranty_Line__c(
			Case__c = c.Id,
			Customer_name__c = 'noname',
			Item__c = tdf.items.getAllSObjects()[0].Id
		);
		insert wl;
		Test.setCurrentPage(new PageReference('/'));
		ApexPages.currentPage().getParameters().put('id',c.Id);
		CaseController controller = new CaseController();
		controller.getCaseWrapper();
		controller.exit();
		controller.getCaseWrapper().getLines();
		controller.getCaseWrapper().getFormatedCaseDate();
		controller.getCaseWrapper().getIsRefundAvailable();
		controller.getCaseWrapper().saveAll();
		controller.getCaseWrapper().updateSource();
	}
	
	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', true);
		tdf.accounts.createSObject(
			'Test Account', 'EUR', true
		);
		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);
		tdf.items.createSObject(
			'Shoe1', 500, 600, 'a simple shoe', tdf.locations.getAllSObjects()[0].Id, tdf.itemGroups.getAllSObjects()[0].Id, '423646', false
		);
		Fabric__c fabric = new Fabric__c(
			Fabric_Description__c = 'Some desc'
		);
		insert fabric;

		Sizes__c size = new Sizes__c(
			Name = '42',
			European_Size__c = '42'
		); 
		insert size;
		PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.getAllSObjects()[0];
		item.Size__c = size.Id;
		item.Discontinued__c = '1';
		item.Fabric_Code__c = fabric.Id;
		item.PBSI__Item_Group__c = tdf.itemGroups.getAllSObjects()[0].Id;
		tdf.items.insertAll();


	}
	
}