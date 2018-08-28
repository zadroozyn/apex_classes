global class BatchCountTotalsPersonAccountStart implements Database.Batchable<sObject>, Database.Stateful {

	final global Set<Id> accountIds;
	final private String query;

	public BatchCountTotalsPersonAccountStart() {
		this.accountIds = new Set<Id>();
		query = getQuery();
	}

	public BatchCountTotalsPersonAccountStart(String period) {
		this.accountIds = new Set<Id>();
		query = getQuery(period);
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<PBSI__PBSI_Sales_Order__c> scope) {
		for(PBSI__PBSI_Sales_Order__c current : scope) {
		    this.accountIds.add(current.PBSI__Customer__c);
		}
	}

	global void finish(Database.BatchableContext BC) {
		BatchCountItemsForPersonalAccount bj = new BatchCountItemsForPersonalAccount(accountIds);
		Database.executeBatch(bj);
	}

	private String getQuery(){
		return 'SELECT PBSI__Customer__c FROM PBSI__PBSI_Sales_Order__c WHERE Id IN (SELECT PBSI__Sales_Order__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE isDeleted = FALSE) AND PBSI__Customer__r.RecordType.Name=\'Person Account\' ALL ROWS';
	}

	private String getQuery(String period){
		return 'SELECT PBSI__Customer__c from PBSI__PBSI_Sales_Order__c WHERE Id IN (SELECT PBSI__Sales_Order__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE LastModifiedDate = ' + period + ') AND isDeleted = FALSE AND PBSI__Customer__r.RecordType.Name=\'Person Account\' ALL ROWS';
	}
}