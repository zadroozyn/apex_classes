public with sharing class PayableInvoiceTriggerHandler {
	private static PayableInvoiceTriggerHandler handler;
	
	public static PayableInvoiceTriggerHandler getHandler() {
		if (null == handler) {
			handler = new PayableInvoiceTriggerHandler();
		}
		return handler;
	}
	public void beforeInsert (List<c2g__codaPurchaseInvoice__c> newlist) {
		PayableInvoiceMethods.validateESRNumber(Trigger.new);
	}
	
	public void beforeUpdate (Map<Id, c2g__codaPurchaseInvoice__c> oldMap, Map<Id, c2g__codaPurchaseInvoice__c> newMap) {
		PayableInvoiceMethods.validateESRNumber(Trigger.oldMap, Trigger.newMap);
	}
	
	public void beforeDelete (Map<Id, c2g__codaPurchaseInvoice__c> oldMap, Map<Id, c2g__codaPurchaseInvoice__c> newMap) {
		//nothing currently
	}
	
	public void afterInsert (Map<Id, c2g__codaPurchaseInvoice__c> newMap) {
		//nothing currently
	}
	
	public void afterUpdate (Map<Id, c2g__codaPurchaseInvoice__c> oldMap, Map<Id, c2g__codaPurchaseInvoice__c> newMap) {
		PayableInvoiceMethods.preventRejectionWithoutComment(oldMap, newMap);
	}
	public void afterDelete (Map<Id, c2g__codaPurchaseInvoice__c> oldMap) {
		//nothing currently
	}
	
	public void afterUnDelete (Map<Id, c2g__codaPurchaseInvoice__c> oldMap) {
		//nothing currently
	}
	
}