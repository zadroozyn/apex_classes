@isTest
private class AccountFinanceCalculationTest {
	
	@isTest static void accountNoTransactions() {
		Test.startTest();
		new AccountFinanceCalculationScheduler().execute(null);
		Test.stopTest();
		Account testAcc = [Select Account_overdue_balance__c, Avg_days_overdue__c, 
								Account_Balance_new__c
							from Account];
		System.assertEquals(0, testAcc.Account_overdue_balance__c);
		System.assertEquals(0, testAcc.Avg_days_overdue__c);
		System.assertEquals(0, testAcc.Account_Balance_new__c);
	}

	@isTest static void singleAccountNoTransactions() {
		TestDataFactory tdf = TestDataFactory.instance;
		Id accId = tdf.accounts.getSObject('Test_account').Id;
		Test.startTest();
			AccountFinanceCalculationBatch.executeForSingleAccount(accId);
		Test.stopTest();
		Account testAcc = [Select Account_overdue_balance__c, Avg_days_overdue__c, 
								Account_Balance_new__c
							from Account where Id = :accId];
		System.assertEquals(0, testAcc.Account_overdue_balance__c);
		System.assertEquals(0, testAcc.Avg_days_overdue__c);
		System.assertEquals(0, testAcc.Account_Balance_new__c);
	}
	
	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test_account', 'CHF', false);
		tdf.accounts.getSObject('Test_account').put('Account_overdue_balance__c', 1000);
		tdf.accounts.getSObject('Test_account').put('Avg_days_overdue__c', 1);
		tdf.accounts.getSObject('Test_account').put('Account_Balance_new__c', 500);
		tdf.accounts.getSObject('Test_account').put('RecordTypeId', 
			new List<Id>(AccountFinanceCalculationBatch.sScopeRTs)[0]);
		tdf.accounts.insertAll();
	}
	
}