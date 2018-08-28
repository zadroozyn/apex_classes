@isTest
private class AccountApprovalServiceTest {
	
	@isTest static void markApprovalRequired() {
		Account accToApproval = getNewAccToApproval();
		AccountApprovalService approvalService = new AccountApprovalService(accToApproval);
		approvalService.markIsApprovalRequired();
		System.assertEquals(true,accToApproval.Approval_Required__c);

		Account accNOTToApproval = getNewAccNOTToApproval();
		approvalService = new AccountApprovalService(accNOTToApproval);
		approvalService.markIsApprovalRequired();
		System.assertEquals(false,accNOTToApproval.Approval_Required__c);		
	}
	
	@isTest static void startActivationPositive() {
		Account accToApproval = getNewAccToApproval();
		accToApproval.Approval_Required__c = true;
		insert accToApproval;
		AccountApprovalService approvalService = new AccountApprovalService(accToApproval);

		List<Approval.ProcessResult> lResults = approvalService.startActivationProcess(true);
		System.assertEquals(false,lResults.isEmpty());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(true,result.isSuccess());
		}
		Account testAcc = [SELECT Id,Status__c FROM Account WHERE Id =:accToApproval.Id];
		System.assertEquals(AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS,testAcc.Status__c);
		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(1,cases);
	}

	@isTest static void startActivationNegativeWrongStatuses() {
		List<Account> lAccWrongStatus = new List<Account>();
		for(Integer i=0; i<3; i++) {
			Account accTmp = getNewAccToApproval();
			accTmp.Approval_Required__c = true;
			lAccWrongStatus.add(
				accTmp
			);
		}
		lAccWrongStatus[0].Status__c = AccountApprovalService.STATUS_ACTIVE;
		lAccWrongStatus[1].Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
		lAccWrongStatus[2].Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
		insert lAccWrongStatus;
		AccountApprovalService approvalService = new AccountApprovalService(lAccWrongStatus);
		List<Approval.ProcessResult> lResults = approvalService.startActivationProcess();
		System.assertEquals(3,lResults.size());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(false,result.isSuccess());
		}
		System.assertEquals(AccountApprovalService.STATUS_ACTIVE,lAccWrongStatus[0].Status__c);
		System.assertEquals(AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS,lAccWrongStatus[1].Status__c);
		System.assertEquals(AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS,lAccWrongStatus[2].Status__c);
		
		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(0,cases);
	}

	@isTest static void startActivationNegativeNotForApproval() {
		Account accNOTToApproval = getNewAccNOTToApproval();
		insert accNOTToApproval;
		AccountApprovalService approvalService = new AccountApprovalService(accNOTToApproval);

		List<Approval.ProcessResult> lResults = approvalService.startActivationProcess();
		System.assertEquals(false,lResults.isEmpty());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(false,result.isSuccess());
		}

		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(0,cases);
	}

	@isTest static void startDeactivationPositive() {
		Account accToApproval = getNewAccToApproval();
		insert accToApproval;
		AccountApprovalService approvalService = new AccountApprovalService(accToApproval);

		List<Approval.ProcessResult> lResults = approvalService.startDeactivationProcess(true);
		System.assertEquals(false,lResults.isEmpty());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(true,result.isSuccess());
		}
		Account testAcc = [SELECT Id,Status__c FROM Account WHERE Id =:accToApproval.Id];
		System.assertEquals(AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS,testAcc.Status__c);
		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(1,cases);
	}

	@isTest static void startDeactivationNegativeWrongStatuses() {
		List<Account> lAccWrongStatus = new List<Account>();
		for(Integer i=0; i<4; i++) {
			Account accTmp = getNewAccToApproval();
			accTmp.Approval_Required__c = true;
			lAccWrongStatus.add(
				accTmp
			);
		}
		lAccWrongStatus[0].Status__c = AccountApprovalService.STATUS_INACTIVE;
		lAccWrongStatus[1].Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
		lAccWrongStatus[2].Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
		lAccWrongStatus[3].Status__c = AccountApprovalService.STATUS_PROSPECT;
		insert lAccWrongStatus;
		AccountApprovalService approvalService = new AccountApprovalService(lAccWrongStatus);
		List<Approval.ProcessResult> lResults = approvalService.startDeactivationProcess();
		System.assertEquals(4,lResults.size());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(false,result.isSuccess());
		}
		System.assertEquals(AccountApprovalService.STATUS_INACTIVE, lAccWrongStatus[0].Status__c);
		System.assertEquals(AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS, lAccWrongStatus[1].Status__c);
		System.assertEquals(AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS, lAccWrongStatus[2].Status__c);
		System.assertEquals(AccountApprovalService.STATUS_PROSPECT, lAccWrongStatus[3].Status__c);
		
		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(0,cases);
	}

	@isTest static void startDeactivationNegativeNotForApproval() {
		Account accNOTToApproval = getNewAccNOTToApproval();
		insert accNOTToApproval;
		AccountApprovalService approvalService = new AccountApprovalService(accNOTToApproval);

		List<Approval.ProcessResult> lResults = approvalService.startDeactivationProcess();
		System.assertEquals(false,lResults.isEmpty());
		for(Approval.ProcessResult result: lResults) {
			System.assertEquals(false,result.isSuccess());
		}

		Integer cases = [SELECT count() FROM Case];
		System.assertEquals(0,cases);
	}

	@isTest static void approveActivation() {
		Account accNew = getNewAccToApproval();
		accNew.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
		accNew.Activated_At_Least_Once__c = false;
		accNew.Approval_Required__c = true;
		insert accNew;

		AccountApprovalService approvalService = new AccountApprovalService(accNew);
		approvalService.approveActivation();
		System.assertEquals(false,Approval.isLocked(accNew));
		System.assertEquals(AccountApprovalService.STATUS_ACTIVE,accNew.Status__c);
		System.assertEquals(true,accNew.Activated_At_Least_Once__c);
	}

	@isTest static void revokeActivationApproval() {
		Account accOnceActivated = getNewAccToApproval();
		accOnceActivated.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
		accOnceActivated.Activated_At_Least_Once__c = true;
		accOnceActivated.Approval_Required__c = true;

		Account accNew = getNewAccToApproval();
		accNew.Status__c = AccountApprovalService.STATUS_IN_ACTIVATION_PROCESS;
		accNew.Activated_At_Least_Once__c = false;
		accNew.Approval_Required__c = true;

		List<Account> lAccs = new List<Account>{accOnceActivated,accNew};
		insert lAccs;

		AccountApprovalService approvalService = new AccountApprovalService(lAccs);
		approvalService.revokeAcivationApproval();

		for(Account acc: lAccs) {
			System.assertEquals(false,Approval.isLocked(acc));
			if(acc.Id == accNew.Id) {
				System.assertEquals(AccountApprovalService.STATUS_PROSPECT,acc.Status__c);
			} else if( acc.Id == accOnceActivated.Id) {
				System.assertEquals(AccountApprovalService.STATUS_INACTIVE,acc.Status__c);
			} else {
				System.assert(false,'You shall not pass!');
			}
		}
	}

	@isTest static void approveDeactivation() {
		Account accNew = getNewAccToApproval();
		accNew.Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
		accNew.Approval_Required__c = true;
		insert accNew;

		AccountApprovalService approvalService = new AccountApprovalService(accNew);
		approvalService.approveDeactivation();
		System.assertEquals(false,Approval.isLocked(accNew));
		System.assertEquals(AccountApprovalService.STATUS_INACTIVE,accNew.Status__c);
	}

	@isTest static void revokeDeactivationApproval() {
		Account accNew = getNewAccToApproval();
		accNew.Status__c = AccountApprovalService.STATUS_IN_DEACTIVATION_PROCESS;
		accNew.Approval_Required__c = true;
		insert accNew;

		AccountApprovalService approvalService = new AccountApprovalService(accNew);
		approvalService.revokeDeacivationApproval();
		System.assertEquals(false,Approval.isLocked(accNew));
		System.assertEquals(AccountApprovalService.STATUS_ACTIVE,accNew.Status__c);
	}

	@testSetup static void setup() {
		Customer_Support_Area__c csa = new Customer_Support_Area__c(
			Name = 'EU'
		);
		insert csa;
		pw_ccpro__CountryObject__c country = new pw_ccpro__CountryObject__c(
			Name = 'Switzerland',
			pw_ccpro__IsoCode_2__c = 'CH',
			pw_ccpro__IsoCode_3__c = 'CH',
			Customer_Support_Area__c = csa.Id
		);
		insert country;
	}


	static Account getNewAccToApproval() {
		Account acc = TestUtility.createAccount('Test Acc', 'EUR', false);
		acc.ShippingCountry = 'Switzerland';
		acc.pw_ccpro__ShippingCountryLookup__c = [select id from pw_ccpro__CountryObject__c].Id;
		Id accDealerRTId = new List<Id>(AccountApprovalService.sApprovalRequiredRTs)[0];
		acc.RecordTypeId = accDealerRTId;
		acc.Status__c = AccountApprovalService.STATUS_PROSPECT;
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