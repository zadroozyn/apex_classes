@isTest
private class LogService_Test {
	
	@isTest static void test_method_one() {
		LogService logSrv = LogService.getlogService();
		Contact c = new Contact(
			LastName = 'Runner'
		);
		insert c;
		logSrv
			.addDebug()
			.type('NewContect')
			.relatedObjId(c.Id)
			.info(JSON.serialize(c))
			.createActivity();

		LogService exceptionLog = LogService.getlogService();
		try {
			c.LastName = '';
			update c;
		} catch (Exception e) {
			exceptionLog
				.addError()
				.type('ContactError')
				.relatedObjId(c.Id)
				.exception(e)
				.info(JSON.serialize(c))
				.createActivity();
			exceptionLog.save();
		}

		logSrv
			.addCallout()
			.type('CallOutside')
			.info('empty body');

		//test after save() on non-saving LogService
		List<Log__c> lLogs = [SELECT Id FROM Log__c];
		System.assertEquals(true,lLogs.isEmpty());
		List<Task> lTasks = [SELECT Id FROM Task];
		System.assertEquals(true,lTasks.isEmpty());
		//end

		logSrv.save();
		//make sure that is safe to save() again
		System.assertEquals(true,logSrv.loggerObj.allLogs.isEmpty());
		//test after save() on saving LogService
		lLogs = [SELECT Id FROM Log__c];
		System.assertEquals(3,lLogs.size());
		lTasks = [SELECT Id FROM Task];
		System.assertEquals(2,lTasks.size());
		//end
	}
	
}