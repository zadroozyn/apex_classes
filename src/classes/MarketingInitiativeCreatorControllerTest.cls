@isTest
private class MarketingInitiativeCreatorControllerTest {
	
	@isTest static void allSuccess() {
		Test.startTest();
		MarketingInitiativeCreatorController controller = new MarketingInitiativeCreatorController();
		controller.selectedChannel = [SELECT Id FROM Sales_Channel__c].Id;
		controller.selectedSeason = [SELECT Id FROM Sales_Season__c].Id;
		controller.contactEdit.Birthdate = System.today();
		controller.initMarketingInitiativesBatch();
		Test.stopTest();
		List<Marketing_Initiative__c> lInitiatives = [SELECT Id FROM Marketing_Initiative__c];
		System.assertEquals(12, lInitiatives.size());
	}
	
	@isTest static void missingSeason() {
		Test.startTest();
		MarketingInitiativeCreatorController controller = new MarketingInitiativeCreatorController();
		controller.selectedChannel = [SELECT Id FROM Sales_Channel__c].Id;
		controller.selectedSeason = null;
		controller.contactEdit.Birthdate = System.today();
		controller.initMarketingInitiativesBatch();
		Test.stopTest();
		List<Marketing_Initiative__c> lInitiatives = [SELECT Id FROM Marketing_Initiative__c];
		System.assertEquals(0, lInitiatives.size());
	}

	@isTest static void missingChannel() {
		Test.startTest();
		MarketingInitiativeCreatorController controller = new MarketingInitiativeCreatorController();
		controller.selectedChannel = null;
		controller.selectedSeason = [SELECT Id FROM Sales_Season__c].Id;
		controller.contactEdit.Birthdate = System.today();
		controller.initMarketingInitiativesBatch();
		Test.stopTest();
		List<Marketing_Initiative__c> lInitiatives = [SELECT Id FROM Marketing_Initiative__c];
		System.assertEquals(0, lInitiatives.size());
	}

	@isTest static void missingStartDate() {
		Test.startTest();
		MarketingInitiativeCreatorController controller = new MarketingInitiativeCreatorController();
		controller.selectedChannel = [SELECT Id FROM Sales_Channel__c].Id;
		controller.selectedSeason = [SELECT Id FROM Sales_Season__c].Id;
		controller.contactEdit.Birthdate = null;
		controller.initMarketingInitiativesBatch();
		Test.stopTest();
		List<Marketing_Initiative__c> lInitiatives = [SELECT Id FROM Marketing_Initiative__c];
		System.assertEquals(0, lInitiatives.size());
	}

	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.createSObject('Test', 'EUR', true);
		Sales_Channel__c sc = new Sales_Channel__c(
			Name = 'Direct Markets'
		);
		insert sc;
		Sales_Season__c ss = new Sales_Season__c(
			current_season__c = true,
			Season__c = 'FW',
			Year__c = 18,
			Name = 'FW18'
		);
		insert ss;
		Sales_Planning__c sp1 = new Sales_Planning__c(
			Account__c = acc.Id,
			Sales_Channel__c = sc.Id,
			Sales_Season__c = ss.Id,
			of_Events__c = 2,
			of_Premium_Windows__c = 2,
			of_Special_Areas__c = 2,
			of_Standard_Windows__c = 2,
			of_Tech_Rep_Visits__c = 2,
			of_Walls__c = 2
		);
		insert sp1;
		Sales_Planning__c sp2 = sp1.clone(false, true, false, false);
		sp2.Sales_Channel__c = null;
		insert sp2;
	}
	
}