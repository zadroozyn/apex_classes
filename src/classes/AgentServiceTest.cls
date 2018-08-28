@isTest class AgentServiceTest {
	
	@isTest static void test_with_good_agentName() {
		AgentService ags = new AgentService();
		Agent__c agent1 = new Agent__c(Name = 'agent1');
		insert agent1;
		Test.startTest();
		Id agentId = ags.getAgentIdByName(agent1.Name);
		Test.stopTest();

		System.assertEquals(agent1.Id, agentId);
	}

	@isTest static void test_with_bad_agentName() {
		AgentService ags = new AgentService();
		Agent__c agent1 = new Agent__c(Name = 'agent1');
		insert agent1;
		Test.startTest();
		Id agentId = ags.getAgentIdByName('NotExistingAgentName');
		Test.stopTest();

		System.assertEquals(null, agentId);
	}

	@isTest static void test_with_good_agentId() {
		AgentService ags = new AgentService();
		Agent__c agent1 = new Agent__c(Name = 'agent1');
		insert agent1;
		Id agId = [Select Id From Agent__c Where Name = 'agent1' limit 1].id;
		Test.startTest();
		String agentName = ags.getAgentNameById(agId);
		Test.stopTest();
		System.assertEquals(agent1.Name, agentName);
	}

	@isTest static void test_with_bad_agentId() {
		AgentService ags = new AgentService();
		Test.startTest();
		String agentName = ags.getAgentNameById(null);
		Test.stopTest();

		System.assertEquals(null, agentName);
	}




}