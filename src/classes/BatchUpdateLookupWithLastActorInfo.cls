global class BatchUpdateLookupWithLastActorInfo implements Database.Batchable<sObject> {

	global String fieldName;
	global String query;

	global BatchUpdateLookupWithLastActorInfo(String query, String lookupFieldToUpdate) {
		this.fieldName = lookupFieldToUpdate;
		this.query = query;
	}

	global Database.queryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}	

	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		update sObjectMethods.getListOfObjectsWithChangedLookupToUpdate(sObjectMethods.getLatestActorInApproval(scope), scope, fieldName);
	}

	global void finish(Database.BatchableContext bc) {

	}
}