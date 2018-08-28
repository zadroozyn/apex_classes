@isTest
private class B24ConfirmMsgDeliveryStepTest {
	
	@isTest static void confirmDelivery() {
		TestDataFactory tdf = TestDataFactory.instance;
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		ProcessRealization pInstance = new ProcessRealization(tdf.salesOrders.getAllSObjects()[0].Id, new MockProcess());
		pInstance.context.b24AuthObj = new B24Authorization();
		Test.startTest();
			B24ConfirmMsgDeliveryStep step = new B24ConfirmMsgDeliveryStep();
 			step.executeStep(pInstance);
 			step.getStepName();
		Test.stopTest();
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		Sobject acc = tdf.accounts.createSObject('Parent_Account', 'CHF', true);
		tdf.salesOrders.createSObject(acc.Id, 'Re-Order', null, true);
	}

	public class MockProcess implements IProcessDefinition {
		private List<String> steps = new List<String>{};

		public Queue getStepsQueue() {
			return new Queue(steps);
		}
		
		public String getProcessName() {
			return 'MockProcess';
		}
	}
	

	
}