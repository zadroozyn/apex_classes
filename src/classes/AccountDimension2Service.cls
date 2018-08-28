public without sharing class AccountDimension2Service implements Queueable {

	private final static Set<Id> PROCESSED_ACCOUNTS = new Set<Id>();

	private final Map<Id, c2g__codaDimension2__c> dimensions;
	private final Map<Id, Account> accounts;
	private Final List<c2g__codaDimension2__c> newDimensions;

	public AccountDimension2Service(List<Account> accs) {
		this.accounts = new Map<Id, Account>(filterAccounts(accs).values().deepClone(true, true, true));
		this.dimensions = new Map<Id, c2g__codaDimension2__c>();
		this.newDimensions = new List<c2g__codaDimension2__c>();
	}

	public AccountDimension2Service(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		this.accounts = filterAccounts(oldAccounts, newAccounts);
		this.dimensions = new Map<Id, c2g__codaDimension2__c>();
		this.newDimensions = new List<c2g__codaDimension2__c>();
	}

	public void updateDimensionsName() {
		Set<Id> dims = this.getDimensionIds();
		if(dims.isEmpty()) {
			return;
		}
		this.dimensions.putAll([SELECT Id, Name, c2g__ReportingCode__c FROM c2g__codaDimension2__c WHERE Id IN : dims]);
		for(Account current : this.accounts.values()) {
			if(this.dimensions.containsKey(current.c2g__CODADimension2__c)) {
				this.dimensions.get(current.c2g__CODADimension2__c).Name = (current.Name.length() > 80) ? current.Name.substring(0, 80) : current.Name;
			}
		}
	}

	public void createNewDimensions() {
		final Map<String, c2g__codaDimension2__c> nDimensions = new Map<String, c2g__codaDimension2__c>();
		for(Account current : this.accounts.values()) {
			if(current.c2g__CODADimension2__c == null) {
				nDimensions.put(current.Account_Number_new__c, new c2g__codaDimension2__c(Name = current.Name, c2g__ReportingCode__c = current.Account_Number_new__c));
			}
		}
		this.newDimensions.addAll(nDimensions.values());
		this.saveDimensions();
		for(Account current : this.accounts.values()) {
			if(current.c2g__CODADimension2__c == null) {
				current.c2g__CODADimension2__c = nDimensions.get(current.Account_Number_new__c).Id;
			}
		}
	}

	public void saveDimensions() {
		this.newDimensions.addAll(this.dimensions.values());
		this.processSaveResults(Database.upsert(this.newDimensions, false));
	}

	public void saveAccounts() {
		this.processSaveResults(Database.update(this.accounts.values(), false));
	}

	private void processSaveResults(List<Database.SaveResult> results) {
		LogService log = LogService.getLogService();
		for(Database.SaveResult current : results) {
			if(!current.isSuccess()){
				Log temp = log.addError().type('DATABASE').relatedObjId(current.getId()).info('Couldn\'t update Account with Dimension2 data.');
				for(Database.Error currentErr : current.getErrors()) {
					temp.info(temp.getLogObject().Info__c + currentErr.getStatusCode() + ' ' +  String.join(currentErr.getFields(), ', ') + ' ' + currentErr.getMessage() + '\n');
				}
			}
			log.addError();
		}
		log.save();
	}

	private void processSaveResults(List<Database.UpsertResult> results) {
		LogService log = LogService.getLogService();
		for(Database.UpsertResult current : results) {
			if(!current.isSuccess()){
				Log temp = log.addError().type('DATABASE').relatedObjId(current.getId()).info('Couldn\'t upsert dimension 2 for accounts.');
				for(Database.Error currentErr : current.getErrors()) {
					temp.info(temp.getLogObject().Info__c + '\n' + currentErr.getStatusCode() + ' ' +  String.join(currentErr.getFields(), ', ') + ' ' + currentErr.getMessage());
				}
			}
			log.addError();
		}
		log.save();
	}

	public void execute(QueueableContext qc) {
		this.createNewDimensions();
		this.saveAccounts();
	}

	private Set<Id> getDimensionIds() {
		final Set<Id> returnValue = new Set<Id>();
		for(Account current : this.accounts.values()) {
			returnValue.add(current.c2g__CODADimension2__c);
		}
		return returnValue;
	}

	private Map<Id, Account> filterAccounts(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
		final Map<Id, Account> returnValue = new Map<Id, Account>();
		for(Id current : newAccounts.keySet()) {
			if(!(oldAccounts.get(current).Name == newAccounts.get(current).Name || PROCESSED_ACCOUNTS.contains(current)
					|| newAccounts.get(current).RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Web_account'))) {
				returnValue.put(current, newAccounts.get(current));
			}
		}
		return returnValue;
	}

	private Map<Id, Account> filterAccounts(List<Account> accs) {
		Map<Id, Account> returnValue = new Map<Id, Account>();
		for(Account current : accs) {
			if(!(current.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Web_account'))) {
				returnValue.put(current.Id, current);
			}
		}
		return returnValue;
	}
}