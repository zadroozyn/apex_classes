public without sharing class BatchBackstageShares implements Database.Batchable<sObject>, Database.Stateful {
	public enum Target_object {SALES_ORDER, SALES_INVOICE, SALES_CREDIT_NOTE}

	private Schema.sObjectType contextType;
	private String whereClause;

	public BatchBackstageShares(Target_object target, String whereClause) {
		this.whereClause = String.isBlank(whereClause) ? '' : whereClause;
		if(target == Target_object.SALES_ORDER) {
			contextType = Schema.PBSI__PBSI_Sales_Order__c.sObjectType;
		} else if(target == Target_object.SALES_INVOICE) {
			contextType = Schema.c2g__codaInvoice__c.sObjectType;
		} else if(target == Target_object.SALES_CREDIT_NOTE) {
			contextType = Schema.c2g__codaCreditNote__c.sObjectType;
		} else {
			throw new NullPointerException();
		}
	}

    public Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, ' + BackstageShareService.OBJ_NAME_TO_ACC_REF.get(String.valueOf(this.contextType)) + ' FROM ' + String.valueOf(this.contextType)  + ' WHERE '
			+ BackstageShareService.OBJ_NAME_TO_ACC_REF.get(String.valueOf(this.contextType)) + ' != null ' + this.whereClause;
		return  Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
		BackstageShareService srv = new BackstageShareService();
		Database.insert(srv.createSharesForObjects(scope, this.contextType), false);
	}

    public void finish(Database.BatchableContext bc) {
	}
}