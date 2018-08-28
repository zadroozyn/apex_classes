public class LogService {

	private static Boolean unUsed = true;
	private Boolean topLevel;

	@TestVisible
	private Logger loggerObj;

	private LogService(Boolean isTopLevel) {
		topLevel = isTopLevel;
		loggerObj = Logger.getInstance();
	}

	public static LogService getlogService() {
		LogService newLogService = new LogService(unUsed);
		if(unUsed) {
			unUsed = false;
		}
		return newLogService;
	}

	public void save() {
		if(topLevel) {
			System.debug('LogService: I\'m the top level, saving... ');
			loggerObj.saveLogs();
			unUsed = true;
		} else {
			System.debug('LogService: I\'m NOT the top level, skipping');
		}
	}

	public Log addError() {
		return addLog(
			new Log__c(
				RecordTypeId = Logger.ERROR_ID
			)
		);
	}

	public Log addCallout() {
		return addLog(
			new Log__c(
				RecordTypeId = Logger.CALLOUT_ID
			)
		);
	}

	public Log addDebug() {
		return addLog(
			new Log__c(
				RecordTypeId = Logger.DEBUG_ID
			)
		);
	}

	private Log addLog(Log__c logObj) {
		Log logWrapper = new Log(logObj);
		loggerObj.addLog(
			logWrapper
		);
		return logWrapper;
	}

}