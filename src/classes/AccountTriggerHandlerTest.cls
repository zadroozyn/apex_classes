@isTest
private class AccountTriggerHandlerTest {
	
	@isTest static void accountToApprovalInsert() {
		User testUser = getUser();
		Account acc = getNewAccToApproval();
		System.runAs(testUser) {
			Test.startTest();
				insert acc;
			Test.stopTest();
		}
		Account accTest = [SELECT Approval_Required__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(true,accTest.Approval_Required__c);
	}
	
	@isTest static void accountNOTToApprovalInsert() {
		User testUser = getUser();
		Account acc = getNewAccNOTToApproval();
		System.runAs(testUser) {
			Test.startTest();
				insert acc;
			Test.stopTest();
		}
		Account accTest = [SELECT Approval_Required__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(false,accTest.Approval_Required__c);
	}

	static User getUser() {
		Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'On Backoffice'].Id;
		User testUser = TestUtility.createUser('testUser_ATHT',standardUserProfileId,true);
		return testUser;
	}

	static Account getNewAccToApproval() {
		Account acc = TestUtility.createAccount('Test Acc', 'EUR', false);
		Id accDealerRTId = new List<Id>(AccountApprovalService.sApprovalRequiredRTs)[0];
		acc.RecordTypeId = accDealerRTId;
		acc.Status__c = AccountApprovalService.STATUS_PROSPECT;
		acc.Approval_Required__c = false;
		acc.Account_Channel__c = 'Other';
		return acc;
	}

	static Account getNewAccNOTToApproval() {
		Account acc = TestUtility.createAccount('Test Acc', 'EUR', false);
		Id accNotToApproveRTId = 
			[SELECT Id FROM RecordType 
				WHERE sObjectType = 'Account' 
					AND IsActive = true 
					AND IsPersonType = false
					AND Id NOT IN :AccountApprovalService.sApprovalRequiredRTs
				LIMIT 1].Id;
		acc.RecordTypeId = accNotToApproveRTId;
		return acc;
	}
	
}