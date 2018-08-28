@isTest
private class SalesSeasonTriggerHandler_Test {
	
	@isTest static void correctName() {
		Sales_Season__c season = new Sales_Season__c(
			Season__c = 'SS',
			Year__c = 18
		);

		Test.startTest();

		insert season;
		Sales_Season__c seasonAfterInsert = [SELECT Id,Name FROM Sales_Season__c WHERE Id = :season.Id];
		System.assertEquals('SS18', seasonAfterInsert.Name);
		seasonAfterInsert.Season__c = 'FW';
		update seasonAfterInsert;
		Sales_Season__c seasonAfterUpdate = [SELECT Id,Name FROM Sales_Season__c WHERE Id = :season.Id];
		System.assertEquals('FW18', seasonAfterUpdate.Name);
		Test.stopTest();
	}
	
}