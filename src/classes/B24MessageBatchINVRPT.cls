global class B24MessageBatchINVRPT implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	private String query = 'SELECT Id FROM Report WHERE Id IN ';
	private Map<Id, Set<Id>> mapReportId2AccIds;
	private Id userToInform;
	private Set<Id> reportsIds;
	
	global B24MessageBatchINVRPT(Map<Id, Set<Id>> mapReportId2AccIds) {
		this.mapReportId2AccIds = mapReportId2AccIds;
		reportsIds = mapReportId2AccIds.keySet();
		query += ' :reportsIds';
	}

	global void setUserToInform(Id userId) {
		userToInform = userId;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Report> scope) {
		B24MessageFactory msgFactory = new B24MessageFactory();
		Set<Id> allAccIds = new Set<Id>();
		for(Report rpt: scope) {
			allAccIds.addAll(mapReportId2AccIds.get(rpt.Id));
		}
		Map<Id, Account> mapAccs = new Map<Id, Account>([SELECT Id, Name, GLN__c FROM Account WHERE Id IN :allAccIds]);

		List<String> allInvrptJSON = new List<String>();
		for(Report rpt: scope) {
			for(Id accId: mapReportId2AccIds.get(rpt.Id)) {
				Account acc = mapAccs.get(accId);
				if(!Test.isRunningTest()) {
					allInvrptJSON.add(
						msgFactory.invrpt(rpt.Id, acc.GLN__c)
					);
				}
			}
		}
		B24MessageSend msgSendSrv = new B24MessageSend();
		if(!Test.isRunningTest()) {
			for(String invrptMsg: allInvrptJSON) {
				msgSendSrv.sendInventoryReport(invrptMsg);
			}
		}
		
	}
	
	global void finish(Database.BatchableContext BC) {
		if(userToInform != null) {
			sendInfoToUser();
		}
	}

	private void sendInfoToUser() {
		//Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//mail.
	}
	
}