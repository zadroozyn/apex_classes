@isTest
class PortalLanguageSyncTest {

	@testSetup
	static void testSetup() {
		Test.startTest();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test_Dealer', 'CHF', false);
		tdf.accounts.getSObject('Test_Dealer').put('Status__c', 'Active');
		tdf.accounts.insertAll();

		tdf.contacts.createSObject('testname', 'testname@example.com', tdf.accounts.getSObjectId('Test_Dealer'), false);
		tdf.contacts.getSObject('testname').put('Function__c', 'B2B-Portal-User');
		tdf.contacts.insertAll();
		tdf.contacts.getSObject('testname').put('Portal_users_language__c', 'fr');
		tdf.contacts.updateAll();
		Test.stopTest();
	}

	/*@isTest
	static void syncUserTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		Contact c = (Contact)tdf.contacts.getSObject('testname');
		User u = [SELECT Id, LanguageLocaleKey, ContactId FROM User WHERE ContactId =: c.Id];
		Test.startTest();
		u.LanguageLocaleKey = 'ja';
		update u;
		PortalLanguageSync syncer = PortalLanguageSync.instance;
		syncer.syncRelatedContacts(new Set<Id> {u.Id});
		Test.stopTest();
		tdf.contacts.refresh();
		System.assertEquals('ja', (String)tdf.contacts.getSObject('testname').get('Portal_Users_Language'));
	}*/


	@isTest
	static void syncContactTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		Contact c = (Contact)tdf.contacts.getSObject('testname');
		Test.startTest();
		PortalLanguageSync syncer = PortalLanguageSync.instance;
		syncer.syncRelatedUsers(new Set<Id> {c.Id});
		Test.stopTest();
		User u = [SELECT Id, LanguageLocaleKey, ContactId FROM User WHERE ContactId =: c.Id];
		System.assertEquals('fr', u.LanguageLocaleKey);
	}
}