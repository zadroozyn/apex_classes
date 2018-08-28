public class MarketingInitiativeCreatorController {
	
	public List<SelectOption> availableSeasons {get; private set;}
	public List<SelectOption> availableChannels {get; private set;}
	public Id selectedSeason {get; set;}
	public Id selectedChannel {get; set;}
	public Contact contactEdit {get; set;}
	
	public MarketingInitiativeCreatorController() {
		reloadPicklists();
		contactEdit = new Contact();
		contactEdit.Birthdate = System.today();
	}

	private void reloadPicklists() {
		getSeasonPicklistValues();
		getSalesChannelValues();
	}

	private void getSeasonPicklistValues() {
		List<Sales_Season__c> seasons = [SELECT Id,Name FROM Sales_Season__c WHERE Marketing_Initiatives_Calculated__c = false];
		availableSeasons = createPicklistValues(seasons);
	}

	private void getSalesChannelValues() {
		List<Sales_Channel__c> channels = [SELECT Id,Name FROM Sales_Channel__c];
		availableChannels = createPicklistValues(channels);
	}

	private static List<SelectOption> createPicklistValues(List<SObject> lSObjects) {
		List<SelectOption> retList = new List<SelectOption>();
		retList.add(
				new SelectOption('', '-- select --',true)
		);
		for(SObject sObj: lSObjects) {
			retList.add(
				new SelectOption(sObj.Id, (String) sObj.get('name'))
			);
		}
		return retList;
	}

	public void initMarketingInitiativesBatch() {
		if(validate()) {
			Database.executeBatch(new MarketingInitiativeCreatorBatch(selectedSeason, selectedChannel, contactEdit.Birthdate), 10);
			Sales_Season__c season = new Sales_Season__c(
				Id = selectedSeason,
				Marketing_Initiatives_Calculated__c = true
			);
			update season;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Batch job for creating marketing initiatives was started, you will getn an email when it\'s done.'));
			reloadPicklists();
		}
	}

	private boolean validate() {
		Boolean retVal = true;
		if(String.isBlank(selectedSeason)) {
			retVal = false;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select Season!'));
		}
		if(String.isBlank(selectedChannel)) {
			retVal = false;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Select Channel!'));
		}
		if(contactEdit.Birthdate == null || contactEdit.Birthdate < System.today()) {
			retVal = false;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Date invalid'));
		}
		return retVal;
	}
}