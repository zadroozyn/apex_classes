public class JournalLineItemService {

	public void setInitialFieldValues(List<c2g__codaJournalLineItem__c> lines) {
		DataHelper dh = new DataHelper(lines);
		for(c2g__codaJournalLineItem__c current : lines) {
			if(dh.ledgerAccounts.keySet().contains(current.c2g__GeneralLedgerAccount__c)) {
				c2g__codaJournal__c parent = dh.journals.get(current.c2g__Journal__c);
				current.c2g__Dimension1__c = dh.country2Dim1Id.get(parent.Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c);
				current.c2g__Dimension2__c = parent.Ascent2FF__Sales_Order__r.PBSI__Customer__r.c2g__codaDimension2__c;
			}
		}
	}

	private class DataHelper {

		Map<Id, c2g__codaJournal__c> journals;
		Map<Id, c2g__codaGeneralLedgerAccount__c> ledgerAccounts;
		Map<String, Id> country2Dim1Id;

		private DataHelper(List<c2g__codaJournalLineItem__c> input) {
			journals = new Map<Id, c2g__codaJournal__c>();
			ledgerAccounts = new Map<Id, c2g__codaGeneralLedgerAccount__c>();
			country2Dim1Id = new Map<String, Id>();
			processLineItems(input);
		}

		private void processLineItems(List<c2g__codaJournalLineItem__c> input) {
			Set<Id> journalIds = new Set<Id>();
			Set<Id> ledgerAccountIds = new Set<Id>();
			Set<String> countries = new Set<String> {'Webshop', 'Other'};
			for(c2g__codaJournalLineItem__c current : input) {
				journalIds.add(current.c2g__Journal__c);
				ledgerAccountIds.add(current.c2g__GeneralLedgerAccount__c);
			}
			journalIds.remove(null);
			ledgerAccountIds.remove(null);
			if(!journalIds.isEmpty()) {
				journals.putAll([SELECT Id, Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c, Ascent2FF__Sales_Order__r.RecordTypeId, Ascent2FF__Sales_Order__r.PBSI__Customer__r.c2g__codaDimension2__c FROM c2g__codaJournal__c WHERE Id IN :journalIds]);
			}
			if(!ledgerAccountIds.isEmpty()) {
				ledgerAccounts.putAll([SELECT Id, c2g__TrialBalance4__c FROM c2g__codaGeneralLedgerAccount__c WHERE Id IN :ledgerAccountIds AND c2g__TrialBalance4__c = 'COGS (incl. Duties & Freight)']);
			}
			for(c2g__codaJournal__c current : journals.values()) {
				countries.add(current.Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c);
			}
			countries.remove(null);
			if(!countries.isEmpty()) {
				for (c2g__codaDimension1__c current : [SELECT Id, Name FROM c2g__codaDimension1__c WHERE Name IN :countries]){
					this.country2Dim1Id.put(current.name, current.Id);
				}
			}
		}

	}

}