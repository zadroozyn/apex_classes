global class WebAccLanguageBatch implements Database.Batchable<sObject> {
	
	private static final Map<String, String> mapCountry2Lang = new Map<String, String>{
		'Andorra' => 'Spanish',
		'Australia' => 'English - Australian',
		'Austria' => 'German',
		'Belgium' => 'French',
		'Denmark' => 'Danish',
		'Finland' => 'Finnish',
		'France' => 'French',
		'Germany' => 'German',
		'Hong Kong' => 'Chinese (Traditional)',
		'Italy' => 'Italian',
		'Japan' => 'Japanese',
		'Korea' => 'Korean',
		'Liechtenstein' => 'German',
		'Luxembourg' => 'French',
		'Mexico' => 'Spanish',
		'Monaco' => 'French',
		'Portugal' => 'Portuguese',
		'Spain' => 'Spanish',
		'Switzerland' => 'German',
		'Thailand' => 'Thai',
		'United States' => 'English - American',
		'Brazil' => 'Portuguese (Brazilian)'
	};

	String query = 'select Id,BillingCountry from account where RecordTypeId = \'01257000000Bflh\' and Customer_Language__c = null';
	
	global WebAccLanguageBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(SObject accSObj: scope) {
			Account acc = (Account) accSObj;
			if(acc.BillingCountry != null) {
				if(mapCountry2Lang.containsKey(acc.BillingCountry)) {
					acc.Customer_Language__c = mapCountry2Lang.get(acc.BillingCountry);
				} else {
					acc.Customer_Language__c = 'English';
				}
			} else {
				acc.Customer_Language__c = 'English';
			} 
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}