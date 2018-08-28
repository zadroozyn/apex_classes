@isTest
class WarrantyCaseServiceTest {
	@testsetup
	static void testsetup() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account a = tdf.accounts.createSObject('Test japan', 'CHF', true);
		Contact cc = tdf.contacts.createSObject('japan', 'japan@example-on.com', tdf.accounts.getSObjectId('Test japan'), true);
		tdf.itemgroups.createSObject('new shoe', '123', 'CHF', 'desc', null, true);
		tdf.locations.createSObject('jp-stock', true);
		PBSI__PBSI_Item__c i = tdf.items.createSObject('new shoe x', 119, 191, 'test desc', tdf.locations.getSObjectId('jp-stock'), tdf.itemgroups.getSObjectId('new shoe'), '123', true);
		Case ccc = new Case(AccountId = a.id, ContactId = cc.Id, RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Case', 'backstage_warranty'));
		insert ccc;
		Warranty_Line__c t = new Warranty_Line__c(Case__c = ccc.Id, Item__c=i.Id);
	}

	@isTest
	static void test1() {
		TestDataFactory tdf = TestDataFactory.instance;
		WarrantyCaseWebService.approveAndGenerateOrder([select id from case limit 1][0].id);
	}
}