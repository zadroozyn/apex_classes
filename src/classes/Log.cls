public class Log {
	private Log__c logObj;
	public Boolean saveActivityIfPossible { get; private set; }
	public List<Attachment> attachments { get; private set; }

	public Log() {
		attachments = new List<Attachment>();
		saveActivityIfPossible = false;
	}

	public Log(Log__c logObj) {
		this();
		this.logObj = logObj;
	}

	public Log type(String logType) {
		logObj.Type__c = logType;
		return this;
	}

	public Log relatedObjId(Id objId) {
		logObj.Related_Object_ID__c = objId;
		return this;
	}

	public Log info(String additionalInfo) {
		logObj.Info__c = additionalInfo;
		return this;
	}

	public Log exception(Exception e) {
		logObj.Stack_trace__c = e == null ? '' : e.getMessage() + '\n\n' + e.getStackTraceString();
		return this;
	}

	public Log recordType(Id recordTypeId) {
		logObj.RecordTypeId = recordTypeId;
		return this;
	}

	public Log createActivity() {
		saveActivityIfPossible = true;
		return this;
	}

	public Log__c getLogObject() {
		return logObj;
	}

	public Log__c attachment(String fileName, String fileBody) {
		attachments.add(
			new Attachment(
				Name = fileName,
				Body = Blob.valueOf(fileBody)
			)
		);
		return logObj;
	}			

}