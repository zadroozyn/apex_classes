public with sharing class PayableCreditNoteMethods {

	public static void preventRejectionWithoutComment(Map<Id,c2g__codaPurchaseCreditNote__c> oldMap, Map<Id,c2g__codaPurchaseCreditNote__c> newMap){
		sObjectMethods.preventApprovalStep(oldMap, newMap, 'Approval_status__c', 'Rejected', System.Label.Pins_Rejection_Error_No_Comment);
	}

}