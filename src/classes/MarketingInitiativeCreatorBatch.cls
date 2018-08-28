global class MarketingInitiativeCreatorBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	private String query;
	private Id salesSeasonId;
	private Id salesChannelId;
	private Id userId;
	private Map<String, Id> field2RecordTypeId;
	private Date startDate;
	private Integer totalInitiativesCreated;
	private Integer totalInitiativesFailed;

	private static final List<String> miFiedls = new List<String>{
		'of_Events__c',
		'of_Premium_Windows__c',
		'of_Special_Areas__c',
		'of_Standard_Windows__c',
		'of_Tech_Rep_Visits__c',
		'of_Walls__c'
	};
	
	global MarketingInitiativeCreatorBatch(Id salesSeasonId, Id salesChannelId, Date startDate) {
		this.salesSeasonId = salesSeasonId;
		this.salesChannelId = salesChannelId;
		this.userId = UserInfo.getUserId();
		this.query = 'SELECT Id,Account__c,'+ String.join(miFiedls, ',') +
			+' FROM Sales_Planning__c WHERE Sales_Season__c = :salesSeasonId AND Sales_Channel__c = :salesChannelId';
		this.startDate = startDate;
		this.totalInitiativesCreated = 0;
		this.totalInitiativesFailed = 0;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		assignRtIds();
		return Database.getQueryLocator(query);
	}

	private void assignRtIds() {
		field2RecordTypeId = new Map<String, Id>();
		field2RecordTypeId.put(
			'of_Events__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Event')
		);
		field2RecordTypeId.put(
			'of_Premium_Windows__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Premium_Window')
		);
		field2RecordTypeId.put(
			'of_Special_Areas__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Special_Area')
		);
		field2RecordTypeId.put(
			'of_Standard_Windows__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Standard_Window')
		);
		field2RecordTypeId.put(
			'of_Tech_Rep_Visits__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Tech_Rep_Visit')
		);
		field2RecordTypeId.put(
			'of_Walls__c'.toLowerCase(),
			RecordTypeService.getRecordTypeIdByDeveloperName('Marketing_Initiative__c', 'Wall')
		);
	}

   	global void execute(Database.BatchableContext BC, List<Sales_Planning__c> scope) {
		List<Marketing_Initiative__c> lInitiatives = new List<Marketing_Initiative__c>();
		LogService logSrv = LogService.getLogService();
		try {
			for(Sales_Planning__c sp: scope) {
				for(String fName: miFiedls) {
					Integer numberOfMI = killNullWithFire((Decimal)sp.get(fName));
					for(Integer i = 0; i < numberOfMI; i++) {
						lInitiatives.add(
							new Marketing_Initiative__c(
								Account__c = sp.Account__c,
								Start_Date__c = this.startDate,
								Status__c = 'planned',
								RecordTypeId = field2RecordTypeId.get(fName.toLowerCase())
							)
						);
					}
				}
			}
			insert lInitiatives;
			totalInitiativesCreated += lInitiatives.size();
		} catch(Exception e) {
			totalInitiativesFailed += lInitiatives.size();
			logSrv.addError().type(MarketingInitiativeCreatorBatch.class.getName()).exception(e).info(String.join(new List<Id>((new Map<Id, Sales_Planning__c>(scope).keySet())),','));
		}
		logSrv.save();
	}
	
	global void finish(Database.BatchableContext BC) {
		informUser();
	}

	private void informUser() {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setTargetObjectId(userId);
		mail.setSubject('Marketing Initiatives Created');
		mail.setPlainTextBody('Hi,\nfor Season: '+salesSeasonId+'\nTotal initiatives created: '+totalInitiativesCreated+
			'\nTotal initiatives failed: '+totalInitiativesFailed+'\n\nbest regards,\nMichał');
		mail.setSaveAsActivity(false);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
	}

	public static Integer killNullWithFire(Decimal inVal) {
		Decimal outVal = inVal != null ? inVal : 0;
		return Integer.valueOf(outVal);
	}
	
}