public without sharing class SalesCreditNotesMethods {

    public static void recalculateSharesForPortalUsers(Map<Id, SObject> mOldSobjects, Map<Id, SObject> mNewSobjects) {
        Map<Id, c2g__codaCreditNote__c> mOldCredits = (Map<Id, c2g__codaCreditNote__c>) mOldSobjects;
        Map<Id, c2g__codaCreditNote__c> mNewCredits = (Map<Id, c2g__codaCreditNote__c>) mNewSobjects;
        List<Id> creditIdsWithChangedCustomer = getCreditIdsWithChangedAcc(mOldCredits, mNewCredits);
        if(creditIdsWithChangedCustomer.size() == 0) {
            return;
        }
        List<c2g__codaCreditNote__c> lNewChangedCredits = getCreditsFromMap(creditIdsWithChangedCustomer, mNewCredits);
        List<SObject> oldShares = ShareHandler.getShares(creditIdsWithChangedCustomer, 'c2g__codaCreditNote__c', 'Portal_user_access__c');
        delete oldShares;
		BackstageShareService srv = new BackstageShareService();
		insert srv.createSharesForObjects(lNewChangedCredits, Schema.c2g__codaCreditNote__c.sObjectType);

    }

    private static List<Id> getCreditIdsWithChangedAcc(Map<Id, c2g__codaCreditNote__c> mOldCreditNotes, Map<Id, c2g__codaCreditNote__c> mNewICreditNotes) {
        List<Id> resultList = new List<Id>();
        for(Id currentId : mOldCreditNotes.keySet()) {
            if(mOldCreditNotes.get(currentId).c2g__Account__C != mNewICreditNotes.get(currentId).c2g__Account__C) {
                resultList.add(mNewICreditNotes.get(currentId).Id);
            }
        }
        return resultList;
    }

    private static List<c2g__codaCreditNote__c> getCreditsFromMap(List<Id> creditNotesIds, Map<Id, c2g__codaCreditNote__c> mCreditNotes) {
        List<c2g__codaCreditNote__c> resultList = new List<c2g__codaCreditNote__c>();
        for(Id currentId :creditNotesIds) {
            resultList.add(mCreditNotes.get(currentId));
        }
        return resultList;
    }

}