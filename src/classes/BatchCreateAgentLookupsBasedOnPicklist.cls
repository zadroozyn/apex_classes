global class BatchCreateAgentLookupsBasedOnPicklist implements Database.Batchable<sObject> {
	String query = 'SELECT Id, Agent__c, Agent_lookup__c FROM Account WHERE Agent__c != null AND Agent_lookup__c = null';
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		Agent__c agent_Headquarter = [SELECT Id FROM Agent__c WHERE Name = 'Headquarter'];
		Set<String> agents = new Set<String>();
		for(Account acc : scope){
			agents.add(acc.Agent__c);
		}

		List<Agent__c> lAgent = [SELECT Id, Name FROM Agent__c WHERE Name IN :agents];
		Map<String, Id> mapAgentName2Id = new Map<String, Id> ();

		for(Agent__c ag : lAgent){
			mapAgentName2Id.put(ag.Name, ag.Id);
		}

		for(Account ac : scope){
			if(ac.Agent__c == '0') { // agent '0'
				ac.Agent_lookup__c = agent_Headquarter.id;
			}else {
				ac.Agent_lookup__c = mapAgentName2Id.get(ac.Agent__c);
			}
		}

		List<Database.SaveResult> result = Database.update(scope, false);
		LogService log = LogService.getLogService();
		for(Database.SaveResult current : result) {
			if(!current.isSuccess()) {
				for(Database.Error err : current.getErrors()) {
					log.addError().type('Agent_lookup_error').relatedObjId(current.getId()).info(err.getStatusCode() + ': ' + err.getMessage() + '  Account fields that affected this error: ' + err.getFields());
				}
			}
			log.save();
		}
	}
	global void finish(Database.BatchableContext BC) {
	}

}