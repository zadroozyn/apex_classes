@isTest
private class CaseTriggerHandlerTest {
	
	@isTest static void caseCloseAccountActivationApproved() {
		Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Acc'];
		User testUser = [SELECT Id FROM User WHERE LastName = 'testUser_x'];
		System.runAs(testUser) {
			Case caseObj = createActivationCase(acc);
			insert caseObj;
			acc.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
			update acc;
			Approval.lock(acc);
			caseObj.Status = 'Approved';
			Test.startTest();
	            update caseObj;
			Test.stopTest();
		}
		Account testAcc = [SELECT Id,Name,Status__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(AccountApprovalService.STATUS_ACTIVE, testAcc.Status__c);
		System.assertEquals(false,Approval.isLocked(testAcc));
	}
	
	@isTest static void caseCloseAccountActivationDeclinedFromInactive() {
		Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Acc'];
		User testUser = [SELECT Id FROM User WHERE LastName = 'testUser_x'];
		System.runAs(testUser) {
			Case caseObj = createActivationCase(acc);
			insert caseObj;
			acc.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
			acc.Activated_At_Least_Once__c = true;
			update acc;
			Approval.lock(acc);
			caseObj.Status = 'Declined';
			Test.startTest();
	            update caseObj;
			Test.stopTest();
		}
		Account testAcc = [SELECT Id,Name,Status__c,Activated_At_Least_Once__c 
			FROM Account WHERE Id = :acc.Id];
			System.assertEquals(true,testAcc.Activated_At_Least_Once__c);
		System.assertEquals(AccountApprovalService.STATUS_INACTIVE, testAcc.Status__c);
		System.assertEquals(false,Approval.isLocked(testAcc));
	}

	@isTest static void caseCloseAccountActivationDeclinedFromProspect() {
		Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Acc'];
		User testUser = [SELECT Id FROM User WHERE LastName = 'testUser_x'];
		System.runAs(testUser) {
			Case caseObj = createActivationCase(acc);
			insert caseObj;
			acc.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
			acc.Activated_At_Least_Once__c = false;
			update acc;
			Approval.lock(acc);
			caseObj.Status = 'Declined';
			Test.startTest();
	            update caseObj;
			Test.stopTest();
		}
		Account testAcc = [SELECT Id,Name,Status__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(AccountApprovalService.STATUS_PROSPECT, testAcc.Status__c);
		System.assertEquals(false,Approval.isLocked(testAcc));
	}

	@isTest static void caseCloseAccountDeactivationApproved() {
		Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Acc'];
		User testUser = [SELECT Id FROM User WHERE LastName = 'testUser_x'];
		System.runAs(testUser) {
			Case caseObj = createDeactivationCase(acc);
			insert caseObj;
			acc.Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
			update acc;
			Approval.lock(acc);
			caseObj.Status = 'Approved';
			Test.startTest();
	            update caseObj;
			Test.stopTest();
		}
		Account testAcc = [SELECT Id,Name,Status__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(AccountApprovalService.STATUS_INACTIVE, testAcc.Status__c);
		System.assertEquals(false,Approval.isLocked(testAcc));
	}

	@isTest static void caseCloseAccountDeactivationDeclined() {
		Account acc = [SELECT Id,Name FROM Account WHERE Name = 'Test Acc'];
		User testUser = [SELECT Id FROM User WHERE LastName = 'testUser_x'];
		System.runAs(testUser) {
			Case caseObj = createDeactivationCase(acc);
			insert caseObj;
			acc.Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
			update acc;
			Approval.lock(acc);
			caseObj.Status = 'Declined';
			Test.startTest();
	            update caseObj;
			Test.stopTest();
		}
		Account testAcc = [SELECT Id,Name,Status__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(AccountApprovalService.STATUS_ACTIVE, testAcc.Status__c);
		System.assertEquals(false,Approval.isLocked(testAcc));
	}

	@testSetup
	static void setup() {
		Id standardUserProfileId = [SELECT Id FROM Profile WHERE Name = 'On Backoffice'].Id;
		User testUser = TestUtility.createUser('testUser_x',standardUserProfileId,true);
		Account acc = TestUtility.createAccount('Test Acc', 'EUR', false);
		Id accDealerRTId = new List<Id>(AccountApprovalService.sApprovalRequiredRTs)[0];
		acc.RecordTypeId = accDealerRTId;
		acc.Status__c = AccountApprovalService.STATUS_PROSPECT;
		insert acc;
	}

	private static Case createActivationCase(Account acc) {
		return new Case(
			AccountId = acc.Id,
			Subject = 'Account activation: '+acc.Name,
			RecordTypeId = 
				RecordTypeService.getRecordTypeIdByDeveloperName('Case', CaseTriggerHandler.RT_ACCOUNT_ACTIVATION)
		);
	}

	private static Case createDeactivationCase(Account acc) {
		return new Case(
			AccountId = acc.Id,
			Subject = 'Account deactivation: '+acc.Name,
			RecordTypeId = 
				RecordTypeService.getRecordTypeIdByDeveloperName('Case', CaseTriggerHandler.RT_ACCOUNT_DEACTIVATION)
		);
	}
	
}