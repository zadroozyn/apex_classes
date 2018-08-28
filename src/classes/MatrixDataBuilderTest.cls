@isTest
private class MatrixDataBuilderTest {
	
	@isTest static void test_method_one() {
		TestDataFactory tdf = TestDataFactory.instance;
		Collection_Item__c cItem = new Collection_Item__c(
			Collection__c = tdf.collections.getAllSObjects()[0].Id,
			Item_Group__c = tdf.itemGroups.getAllSObjects()[0].Id,
			Fabric_Code__c = [Select Id from Fabric__c].Id
		);
		insert cItem;

		MatrixDataBuilder mdb = new MatrixDataBuilder(new List<Collection_Item__c>{cItem});
		mdb.populateData();
		mdb.getItemList();
		mdb.getItemMap();
		mdb.getOtherObjects();
		mdb.getSizes();
	}

	@testSetup
	static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', true);
		tdf.collections.createSObject(
			'Warranty',
			'Current collection',
			'Active',
			null,
			true
		);
		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);
		tdf.itemGroups.createSObject('CloudX group', '800', 'EUR', 'No desc', null, true);

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

		tdf.accounts.createSObject(
			'Test Account', 'EUR', true
		);
	}
}