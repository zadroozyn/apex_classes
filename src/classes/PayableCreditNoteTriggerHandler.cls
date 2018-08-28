public with sharing class PayableCreditNoteTriggerHandler {
	private static PayableCreditNoteTriggerHandler handler;
	
	public static PayableCreditNoteTriggerHandler getHandler() {
		if (null == handler) {
			handler = new PayableCreditNoteTriggerHandler();
		}
		return handler;
	}
	public void beforeInsert (List<c2g__codaPurchaseCreditNote__c> newlist) {
		//nothing currently
	}
	
	public void beforeUpdate (Map<Id, c2g__codaPurchaseCreditNote__c> oldMap, Map<Id, c2g__codaPurchaseCreditNote__c> newMap) {
		//nothing currently
	}
	
	public void beforeDelete (Map<Id, c2g__codaPurchaseCreditNote__c> oldMap, Map<Id, c2g__codaPurchaseCreditNote__c> newMap) {
		//nothing currently
	}
	
	public void afterInsert (Map<Id, c2g__codaPurchaseCreditNote__c> newMap) {
		//nothing currently
	}
	
	public void afterUpdate (Map<Id, c2g__codaPurchaseCreditNote__c> oldMap, Map<Id, c2g__codaPurchaseCreditNote__c> newMap) {
		PayableCreditNoteMethods.preventRejectionWithoutComment(oldMap, newMap);
	}
	public void afterDelete (Map<Id, c2g__codaPurchaseCreditNote__c> oldMap) {
		//nothing currently
	}
	
	public void afterUnDelete (Map<Id, c2g__codaPurchaseCreditNote__c> oldMap) {
		//nothing currently
	}
	
}