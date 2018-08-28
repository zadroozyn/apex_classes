global without sharing class AccountDimension2Batch implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Name, Account_Number_new__c, RecordTypeId FROM Account WHERE RecordTypeId != \'' + RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Web_account') + '\'');
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		Map<Id, Account> accs = new Map<Id, Account>(scope);
		SavePoint save = Database.setSavePoint();
		List<Database.SaveResult> results = Database.update(accs.values(), false);
		Database.rollback(save);
		for(Database.SaveResult current : results) {
			if(!current.isSuccess()){
				accs.remove(current.getId());
			}
		}
		AccountDimension2Service service = new AccountDimension2Service(accs.values());
		service.createNewDimensions();
		service.saveAccounts();
	}

	global void finish(Database.BatchableContext BC) {
	}

}