@isTest
private class BatchCreateAgentLookupsBasedOnPickliTest {

	@testSetup
	static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test France', 'EUR', false);
		tdf.accounts.createSObject('Test Switzerland', 'CHF', false);
		tdf.accounts.createSObject('Test', 'CHF', false);
		tdf.accounts.getSObject('Test France').put('Agent__c', 'Test1');
		tdf.accounts.getSObject('Test Switzerland').put('Agent__c', 'Test2');
		tdf.accounts.getSObject('Test').put('Agent__c', '0');
		tdf.accounts.insertAll();
		Agent__c agent1 = new Agent__c(Name = 'Test1');
		Agent__c agent2 = new Agent__c(Name = 'Test2');
		Agent__c agent3 = new Agent__c(Name = 'Headquarter');
		insert agent1;
		insert agent2;
		insert agent3;
	}
	
	@isTest static void accountLookupToApproval() {

		BatchCreateAgentLookupsBasedOnPicklist ba = new BatchCreateAgentLookupsBasedOnPicklist();

		Test.startTest();
		Database.executeBatch(ba);
		Test.stopTest();

		Account acc1 = [SELECT Id, Agent_lookup__r.Name FROM Account WHERE Name = 'Test France' limit 1];
		Account acc2 = [SELECT Id, Agent_lookup__r.Name FROM Account WHERE Name = 'Test Switzerland' limit 1];
		Account acc3 = [SELECT Id, Agent_lookup__r.Name FROM Account WHERE Name = 'Test' limit 1];

		System.assertEquals('Test1', acc1.Agent_lookup__r.Name);
		System.assertEquals('Test2', acc2.Agent_lookup__r.Name);
		System.assertEquals('Headquarter', acc3.Agent_lookup__r.Name);

	}
}