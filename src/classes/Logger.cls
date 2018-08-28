public without sharing class Logger {
    private static Logger classInstance;
    
    @TestVisible 
    private List<Log> allLogs;
    
    private static final Set<Schema.SObjectType> objTypesWhoId = new Set<Schema.SObjectType>(Task.WhoId.getDescribe().getReferenceTo());
    private static final Set<Schema.SObjectType> objTypesWhatId = new Set<Schema.SObjectType>(Task.WhatId.getDescribe().getReferenceTo());

    static {
        classInstance = new Logger();
    }

    private Logger() {
        allLogs = new List<Log>();
    }

    public static Logger getInstance() {
        return classInstance;
    }

    public Log addLog(Log logObj) {
    	allLogs.add(logObj);
    	return logObj;
    }

    public void saveLogs() {
		List<Task> tasks = new List<Task>();
		insertLogs();
		for(Log wrapper: allLogs) {
			Log__c log = wrapper.getLogObject();
			if(wrapper.saveActivityIfPossible && log.Related_Object_ID__c != null && isAllowingActivities((Id)log.Related_Object_ID__c)) {
				tasks.add(
					new Task(
						WhatId = isWhatId((Id)log.Related_Object_ID__c) ? log.Related_Object_ID__c : null,
						WhoId = isWhoId((Id)log.Related_Object_ID__c) ? log.Related_Object_ID__c : null,
						Subject = getDefaultSubject(log),
						OwnerId = UserInfo.getUserId(),
						Log__c = log.Id,
						Description = getDefaultDescription(log),
						ActivityDate = System.today(),
						Status = 'Completed',
						Priority = getDefaultPriority(log)
					)
				);
			}
		}
		insert tasks;
		allLogs.clear();
	}

	private void insertLogs() {
		insert getLogObjects(allLogs);
		List<Attachment> attToInsert = new List<Attachment>();
		for(Log wrapper: allLogs) {
			List<Attachment> tmp = wrapper.attachments;
			for(Attachment att: tmp) {
				att.ParentId = wrapper.getLogObject().Id;
				attToInsert.add(att);
			}
		}
		insert attToInsert;
	}

	private static Boolean isAllowingActivities(Id objId) {
		return isWhoId(objId) || isWhatId(objId);
	}

	private static Boolean isWhatId(Id objId) {
		return objTypesWhatId.contains(objId.getSObjectType());
	}

	private static Boolean isWhoId(Id objId) {
		return objTypesWhoId.contains(objId.getSObjectType());
	}

	private static String getDefaultSubject(Log__c log) {
		String subject = 'Debug Log';
		if(log.RecordTypeId == ERROR_ID) {
			subject = 'Error occured';
		} else if(log.RecordTypeId == CALLOUT_ID) {
			subject = 'Callout error';
		}
		return subject;
	}

	private static String getDefaultDescription(Log__c log) {
		String description = 'See Log object for details';
		if(log.RecordTypeId == ERROR_ID || log.RecordTypeId == CALLOUT_ID) {
			description = log.Stack_trace__c;
		}
		return description;
	}

	private static String getDefaultPriority(Log__c log) {
		String priority = 'Low';
		if(log.RecordTypeId == ERROR_ID) {
			priority = 'High';
		} else if(log.RecordTypeId == CALLOUT_ID) {
			priority = 'Normal';
		}
		return priority;
	}

	public static Id ERROR_ID {
		get {
			if(ERROR_ID == null) {
				ERROR_ID = RecordTypeService.getRecordTypeIdByDeveloperName('Log__c','Error');
			}
			return ERROR_ID;
		}
		private set;
	}

	public static Id CALLOUT_ID {
		get {
			if(CALLOUT_ID == null) {
				CALLOUT_ID = RecordTypeService.getRecordTypeIdByDeveloperName('Log__c','Callout');
			}
			return CALLOUT_ID;
		}
		private set;
	}

	public static Id DEBUG_ID {
		get {
			if(DEBUG_ID == null) {
				DEBUG_ID = RecordTypeService.getRecordTypeIdByDeveloperName('Log__c','Debug');
			}
			return DEBUG_ID;
		}
		private set;
	}

	private List<Log__c> getLogObjects(List<Log> lLogWrappers) {
		List<Log__c> lLogs = new List<Log__c>();
		for(Log wrapper: lLogWrappers) {
			lLogs.add(wrapper.getLogObject());
		}
		return lLogs;
	}

}