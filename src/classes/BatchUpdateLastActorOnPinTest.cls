@isTest private class BatchUpdateLastActorOnPinTest{

	@testSetup private static void prepareData () {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			System.debug(dc.testAccount);
			System.debug(dc.testContact);
			System.debug(dc.testAdmin);
			System.debug(dc.originalApprover);
			System.debug(dc.newApprover);
			System.debug(dc.testCompany);
			System.debug(dc.testCurrency);
			System.debug(dc.testPeriod);

			List<c2g__codaPurchaseInvoice__c> lPinsToInsert = new List <c2g__codaPurchaseInvoice__c>();
			for(Integer i = 0; i< 10; i++) {
				lPinsToInsert.add(dc.createPIN(i, dc.originalApprover.Id));
			}
			insert lPinsToInsert;
		}
	}

	@isTest private static void testUpdateOfActualApprover() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			c2g__codaPurchaseInvoice__c testPin = TestUtility.createPayableInvoice('Test_Invoice', dc.testCompany.OwnerId, dc.testAccount.Id, dc.testCurrency.Id, dc.testPeriod.Id, false);
			testPin.Approving_user__c = dc.originalApprover.Id;
			insert testPin;
			
			System.debug(submitRecordToApprovalProcess(testPin.Id));
		}
	}

	@isTest private static void testBatchRunningWhenNoPinsInApproval() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			Test.startTest();
			BatchUpdateLookupWithLastActorInfo bj = new BatchUpdateLookupWithLastActorInfo('SELECT Id, Approving_user__c FROM c2g__codaPurchaseInvoice__c WHERE Approval_status__c = \'Submitted\'', 'Approving_user__c');
			Database.executeBatch(bj);
			Test.stopTest();
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				System.assert(current.Approving_user__c == dc.originalApprover.Id);
			}
		}
	}

	@isTest private static void testBatchRunningWhenNonePinsApproversWereUpdated() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				submitRecordToApprovalProcess(current.Id);
			}
			Test.startTest();
			BatchUpdateLookupWithLastActorInfo bj = new BatchUpdateLookupWithLastActorInfo('SELECT Id, Approving_user__c FROM c2g__codaPurchaseInvoice__c WHERE Approval_status__c = \'Submitted\'', 'Approving_user__c');
			Database.executeBatch(bj);
			Test.stopTest();
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				System.assert(current.Approval_status__c == 'Submitted');
				System.assert(current.Approving_user__c == dc.originalApprover.Id);
			}
		}
	}

	@isTest private static void testBatchRunningWhenSomePinsApproversWereUpdated() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				submitRecordToApprovalProcess(current.Id);
			}
			Integer i = 0;
			Map<Id, ProcessInstance> mTargetToProcessInstances = getTargetIdToProcessInstanceMap(dc.testPins.values());
			List<ProcessInstanceWorkitem> lProcessInstaceWorkItems = new List<ProcessInstanceWorkitem>();
			List<Id> lUpdatesPins = new List<Id>();
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				if(Math.mod(i, 2) == 0) {
					lUpdatesPins.add(current.Id);
					ProcessInstanceWorkitem tempPiw = mTargetToProcessInstances.get(current.Id).WorkItems[0];
					tempPiw.ActorId = dc.newApprover.Id;
					lProcessInstaceWorkItems.add(tempPiw);
				}
				i++;
			}
			update lProcessInstaceWorkItems;
			Test.startTest();
			BatchUpdateLookupWithLastActorInfo bj = new BatchUpdateLookupWithLastActorInfo('SELECT Id, Approving_user__c FROM c2g__codaPurchaseInvoice__c WHERE Approval_status__c = \'Submitted\'', 'Approving_user__c');
			Database.executeBatch(bj);
			Test.stopTest();

			i = 0;
			for(Id current : lUpdatesPins) {
				System.assertEquals('Submitted', dc.testPins.get(current).Approval_status__c);
				System.assertEquals(dc.newApprover.Id, dc.testPins.get(current).Approving_user__c);
			}
		}
	}

	@isTest private static void testBatchRunningWhenAllPinsApproversWereUpdated() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
				submitRecordToApprovalProcess(current.Id);
			}
			Map<Id, ProcessInstance> mTargetToProcessInstances = getTargetIdToProcessInstanceMap(dc.testPins.values());
			List<ProcessInstanceWorkitem> lProcessInstaceWorkItems = new List<ProcessInstanceWorkitem>();
			List<Id> lUpdatesPins = new List<Id>();
			for(c2g__codaPurchaseInvoice__c current : dc.testPins.values()) {
					lUpdatesPins.add(current.Id);
					ProcessInstanceWorkitem tempPiw = mTargetToProcessInstances.get(current.Id).WorkItems[0];
					tempPiw.ActorId = dc.newApprover.Id;
					lProcessInstaceWorkItems.add(tempPiw);
			}
			update lProcessInstaceWorkItems;
			Test.startTest();
			BatchUpdateLookupWithLastActorInfo bj = new BatchUpdateLookupWithLastActorInfo('SELECT Id, Approving_user__c FROM c2g__codaPurchaseInvoice__c WHERE Approval_status__c = \'Submitted\'', 'Approving_user__c');
			Database.executeBatch(bj);
			Test.stopTest();
			for(Id current : lUpdatesPins) {
				System.assertEquals('Submitted', dc.testPins.get(current).Approval_status__c);
				System.assertEquals(dc.newApprover.Id, dc.testPins.get(current).Approving_user__c);
			}
		}
	}

	private static Approval.ProcessResult submitRecordToApprovalProcess(Id objectId) {
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(objectId);
		return Approval.process(req);
	}

	private static Map<Id, ProcessInstance> getTargetIdToProcessInstanceMap(List<c2g__codaPurchaseInvoice__c> targets) {
		Map<Id, ProcessInstance> returnMap = new Map<Id, ProcessInstance>();
		for(ProcessInstance pi : [SELECT Id, TargetObjectId, (SELECT Id, ActorId, OriginalActorId FROM Workitems ORDER BY CreatedDate LIMIT 1) FROM ProcessInstance WHERE TargetObjectId IN : targets]){
			returnMap.put(pi.TargetObjectId, pi);
		}
		return returnMap;
	}
}