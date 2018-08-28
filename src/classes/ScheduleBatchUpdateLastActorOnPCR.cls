global class ScheduleBatchUpdateLastActorOnPCR implements Schedulable {
    global void execute(SchedulableContext sc) {
		BatchUpdateLookupWithLastActorInfo job = new BatchUpdateLookupWithLastActorInfo('SELECT Id, Approving_user__c FROM c2g__codaPurchaseCreditNote__c WHERE Approval_status__c = \'Submitted\'', 'Approving_user__c');
		Database.executeBatch(job);
	}
}