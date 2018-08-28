@isTest
class AccountDimension2ServiceTest {

	@testSetup
	static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test France', 'EUR', RecordTypeService.getRecordTypeIdByDeveloperName('Account','Business_Customer'),  false);
		tdf.accounts.createSObject('Test Switzerland', 'CHF', RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Business_Customer'), false);
		tdf.accounts.createSObject('Test', 'Webacc', 'CHF', false);
		tdf.accounts.insertAll();
		/*tdf.accounts.refresh();*/

		/*tdf.dimensions2.createSObject((Account)tdf.accounts.getSObject('Test France'), false);*/
		/*tdf.dimensions2.createSObject((Account)tdf.accounts.getSObject('Test Switzerland'), false);*/
		/*tdf.dimensions2.insertAll();*/
		/*tdf.dimensions2.refresh();*/

		/*tdf.accounts.getSObject('Test France').put('c2g__CODADimension2__c', tdf.dimensions2.getSObjectId('Test France'));*/
		/*tdf.accounts.getSObject('Test Switzerland').put('c2g__CODADimension2__c', tdf.dimensions2.getSObjectId('Test Switzerland'));*/
		/*tdf.accounts.updateAll();*/
	}

	@isTest
	static void testSetup() {
		TestDataFactory tdf = TestDataFactory.instance;
		System.assertNotEquals(null, tdf.dimensions2.getSObject('Test France'), 'Dimension2 object should be generated for each new account created');
		System.assertNotEquals(null, tdf.dimensions2.getSObject('Test Switzerland'), 'Dimension2 object should be generated for each new account created');
		System.assertEquals(null, tdf.dimensions2.getSObject('Test Webacc'), 'Dimension2 object should not be generated for web accounts');
		System.assertEquals(
			tdf.accounts.getSObject('Test France').get('Account_Number_new__c'),
			tdf.dimensions2.getSObject('Test France').get('c2g__ReportingCode__c'),
			'These values should be equal, set in AccountDimension2Service'
		);
		System.assertEquals(
			tdf.accounts.getSObject('Test Switzerland').get('Account_Number_new__c'),
			tdf.dimensions2.getSObject('Test Switzerland').get('c2g__ReportingCode__c'),
			'These values should be equal, set in AccountDimension2Service'
		);
		System.assertEquals(
				tdf.accounts.getSObject('Test France').get('c2g__CODADimension2__c'),
				tdf.dimensions2.getSObjectId('Test France'),
				'Account should be related to its dimension2'
		);
		System.assertEquals(
				tdf.accounts.getSObject('Test Switzerland').get('c2g__CODADimension2__c'),
				tdf.dimensions2.getSObjectId('Test Switzerland'),
				'Account should be related to its dimension2'
		);
		System.assertEquals(
				null,
				tdf.accounts.getSObject('Test Webacc').get('c2g__CODADimension2__c'),
				'Web account should not be related to dimension2'
		);

	}

	@isTest
	static void testUpdate() {
		TestDataFactory tdf = TestDataFactory.instance;
		c2g__codaDimension2__c tSwitzerland = (c2g__codaDimension2__c) tdf.dimensions2.getSObject('Test Switzerland');

		tdf.accounts.getSObject('Test Switzerland').put('Name', 'Changed name');
		update tdf.accounts.getSObject('Test Switzerland');

		tdf.accounts.refresh();
		tdf.dimensions2.refresh();

		System.assertEquals(tSwitzerland.Id, tdf.dimensions2.getSObjectId('Changed name'), 'This checks if existing dimension2 was updated.');
		System.assertEquals(
			tdf.accounts.getSObject('Changed name').get('c2g__CODADimension2__c'),
			tdf.dimensions2.getSObjectId('Changed name'),
			'This checks if account\'s link to dimension2 is the same, after update'
		);
	}

}