global class AgentService {
	private static Map<String, Id> mapAgentName2Id {
		get {
			if(mapAgentName2Id == null) {
				initialiseMaps();
			}
			return mapAgentName2Id;
		}
		private set;
	}

	private static Map<Id, String> mapAgentId2Name {
		get {
			if(mapAgentId2Name == null) {
				initialiseMaps();
			}
			return mapAgentId2Name;
		}
		private set;
	}

	public Id getAgentIdByName(String agentName){
		return mapAgentName2Id.get(agentName);
	}

	public String getAgentNameById(Id agentId){
		return mapAgentId2Name.get(agentId);
	}

	private static void initialiseMaps(){
		mapAgentName2Id = new Map<String, Id>();
		mapAgentId2Name = new Map<Id, String>();
		for(Agent__c ag : getAgents()){
			mapAgentName2Id.put(ag.Name, ag.Id);
			mapAgentId2Name.put(ag.Id, ag.Name);
		}
	}

	private static List<Agent__c> getAgents(){
		return [SELECT Id, Name FROM Agent__c];
	}

}