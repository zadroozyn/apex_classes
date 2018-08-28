global class BatchCountItemsForPersonalAccount implements Database.Batchable<sObject> {

	private String query;
	private Set<Id> accounts;

	global BatchCountItemsForPersonalAccount (Set<Id> accounts){
		query = getQuery();
		this.accounts = accounts;
	}

	global Database.queryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		final List<AggregateResult> aggregateResults = [SELECT PBSI__Customer__c AccountId, SUM(Apparel_packed_on_order__c) Apparel_packed, SUM(Shoes_packed_on_order__c) Shoes_packed FROM PBSI__PBSI_Sales_Order__c WHERE PBSI__Customer__c IN : scope GROUP BY PBSI__Customer__c];
		final List<Account> accountsToUpdate = new List<Account>();
		final Map<Id, Account> accountsMap = new Map<Id, Account>();
		accountsMap.putAll(scope);
		Account tempAcc;
		for(AggregateResult currentAR : aggregateResults) {
			tempAcc = accountsMap.get((Id)currentAR.get('AccountId'));
			if(tempAcc.Total_shoes_ordered__c != currentAR.get('Shoes_packed') || tempAcc.Total_apparel_ordered__c != currentAR.get('Apparel_packed')){
				tempAcc.Total_shoes_ordered__c = (Decimal) currentAR.get('Shoes_packed');
				tempAcc.Total_apparel_ordered__c = (Decimal) currentAR.get('Apparel_packed');
				accountsToUpdate.add(tempAcc);
			} 

		}
		Database.update(accountsToUpdate, false);
	}

	global void finish(Database.BatchableContext BC) {

	}

	private String getQuery() {
		return 'SELECT Id, Total_shoes_ordered__c, Total_apparel_ordered__c FROM Account WHERE Id IN : accounts';
	}
}