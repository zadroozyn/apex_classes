public class AccountInvoiceService {

	public void assignNewInvoiceEmail(List<Account> lAccounts) {
		Map<Id,Contact> mapContacts = new Map<Id,Contact>(
			[SELECT Id,Email FROM Contact WHERE Id IN :fetchFinanceContactsIds(lAccounts)]
		);
		for(Account acc: lAccounts) {
			Contact c = mapContacts.get(acc.c2g__CODAFinanceContact__c);
			acc.c2g__CODAInvoiceEmail__c = c != null ? c.Email : null;
		}
	}

	public void assignNewInvoiceEmail(Map<Id,Contact> mContactsOld, Map<Id,Contact> mContactsNew) {
		assignNewInvoiceEmail(
			filterChangedEmail(mContactsOld, mContactsNew)
		);
	}

	private void assignNewInvoiceEmail(List<Contact> lContacts) {
		List<Account> lAccountsToUpdate = [
			SELECT Id,c2g__CODAFinanceContact__c FROM Account 
			WHERE c2g__CODAFinanceContact__c IN :lContacts];
		Map<Id,Contact> mapContacts = new Map<Id,Contact>(lContacts);
		for(Account acc: lAccountsToUpdate) {
			acc.c2g__CODAInvoiceEmail__c = mapContacts.get(acc.c2g__CODAFinanceContact__c).Email;
		}
		update lAccountsToUpdate;
	}

	private List<Contact> filterChangedEmail(Map<Id,SObject> mapSObjectOld, 
		Map<Id,SObject> mapSObjectNew) {
		return (List<Contact>) filterChangedField(mapSObjectOld, mapSObjectNew, 'Email');
	}

	private static Set<Id> fetchFinanceContactsIds(List<Account> lAccounts) {
		return collectIdValues(lAccounts, 'c2g__CODAFinanceContact__c');
	}

	private static Set<Id> collectIdValues(List<sObject> lSObjects, String fName) {
		Set<Id> ids = new Set<Id>();
		for(sObject sObj: lSObjects) {
			ids.add((Id)sObj.get(fName));
		}
		return ids;
	}

	private static List<sObject> filterChangedField(Map<Id,SObject> mapSObjectOld, 
		Map<Id,SObject> mapSObjectNew, String fieldName) {
		return filterChangedField(mapSObjectOld,mapSObjectNew,new List<String>{fieldName});
	}


	private static List<sObject> filterChangedField(Map<Id,SObject> mapSObjectOld, 
		Map<Id,SObject> mapSObjectNew, List<String> fieldNames) {

        List<sObject> lSObjectFiltered = new List<sObject>();
        for(Id key: mapSObjectNew.keySet()) {
            sObject soOld = mapSObjectOld.get(key);
            sObject soNew = mapSObjectNew.get(key);

            for(String fName: fieldNames) {
            	if(soOld.get(fName) != soNew.get(fName)) {
                	lSObjectFiltered.add(soNew);
                	break;
            	}
            }
        }
        return lSObjectFiltered;
    }
}