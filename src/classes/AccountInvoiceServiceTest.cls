@isTest
private class AccountInvoiceServiceTest {
	
	@isTest static void newFinanceContact() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.getSObject('Test_account');
		acc.c2g__CODAFinanceContact__c = (Id) tdf.contacts.getSObject('Smith').get('Id');
		Test.startTest();
		update acc;
		Test.stopTest();
		Account testAcc = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(testAcc.c2g__CODAInvoiceEmail__c, tdf.contacts.getSObject('Smith').get('Email'));
	}
	
	@isTest static void replaceFinanceContact() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.getSObject('Test_account');
		acc.c2g__CODAFinanceContact__c = (Id) tdf.contacts.getSObject('Smith').get('Id');
		update acc;
		Test.startTest();
		acc.c2g__CODAFinanceContact__c = (Id) tdf.contacts.getSObject('Not Smith').get('Id');
		update acc;
		Test.stopTest();
		Account testAcc = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(testAcc.c2g__CODAInvoiceEmail__c, tdf.contacts.getSObject('Not Smith').get('Email'));
	}

	@isTest static void existingFinanceContactEmailChange() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.getSObject('Test_account');
		acc.c2g__CODAFinanceContact__c = (Id) tdf.contacts.getSObject('Smith').get('Id');
		update acc;
		Test.startTest();
		tdf.contacts.getSObject('Smith').put('Email','new_smith@example.com');
		tdf.contacts.updateAll();
		Test.stopTest();
		Account testAcc = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(testAcc.c2g__CODAInvoiceEmail__c, tdf.contacts.getSObject('Smith').get('Email'));
	}

	@isTest static void newAccountForExistingContact() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = new Account(
			Name = 'brand new',
			c2g__CODAFinanceContact__c = (Id) tdf.contacts.getSObject('Smith').get('Id')
		);
		Test.startTest();
		insert acc;
		Test.stopTest();

		Account testAcc = [SELECT c2g__CODAInvoiceEmail__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(testAcc.c2g__CODAInvoiceEmail__c, tdf.contacts.getSObject('Smith').get('Email'));
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test_account', 'CHF', true);
		tdf.contacts.createSObject('Smith', 'smith@example.com', null, true);
		tdf.contacts.createSObject('Not Smith', 'smith2@example.com', null, true);
	}
	
}