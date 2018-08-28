global without sharing class InvoiceCreditNoteValidator {
	webservice static Boolean canCreateCreditNote(Id invoiceId) {
		return [SELECT Id FROM c2g__codaCreditNote__c WHERE c2g__invoice__c =: invoiceId AND c2g__CreditNoteStatus__c != 'Discarded'].isEmpty();
	}
}