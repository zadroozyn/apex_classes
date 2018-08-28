@isTest
public class ProcessTest {
	
	@isTest static void process1Step() {
		Contact c = [SELECT Id,LastName FROM Contact];
		System.assertEquals('Smith', c.LastName);
		ProcessRealization pInstance = new ProcessRealization(c.Id, new TestProcess());
		Test.startTest();
			pInstance.startProcess();
		Test.stopTest();
		Contact cAfter = [SELECT Id,LastName FROM Contact WHERE Id = :c.Id];
		System.assertEquals('Not Smith',cAfter.LastName);
	}

	@isTest static void process1StepFail() {
		Contact c = [SELECT Id,LastName FROM Contact];
		System.assertEquals('Smith', c.LastName);
		ProcessRealization pInstance = new ProcessRealization(c.Id, new TestProcessFail());
		Test.startTest();
			pInstance.startProcess();
		Test.stopTest();
		Contact cAfter = [SELECT Id,LastName FROM Contact WHERE Id = :c.Id];
		System.assertEquals('Smith',cAfter.LastName);
	}

	@testSetup
	static void setup() {
		Contact c = new Contact(
			LastName = 'Smith'
		);
		insert c;
	}

	public class TestProcess implements IProcessDefinition {
		private List<String> steps = new List<String>{
			Step1.class.getName()
		};
	

		public Queue getStepsQueue() {
			return new Queue(steps);
		}
		
		public String getProcessName() {
			return 'TestProcess';
		}
	}

	public class Step1 implements IProcessStepDefinition {
		public void executeStep(ProcessRealization pInstance) {
			List<Id> recordId = pInstance.getRecordIds();
			Contact c = [SELECT Id,LastName FROM Contact Where Id IN :recordId];
			c.LastName = 'Not Smith';
			update c;
		}
		public String getStepName() {
			return 'Step1';
		}
	}

	public class TestProcessFail implements IProcessDefinition {
		private List<String> steps = new List<String>{
			Step1Fail.class.getName()
		};
	

		public Queue getStepsQueue() {
			return new Queue(steps);
		}
		
		public String getProcessName() {
			return 'TestProcessFail';
		}
	}

	public class Step1Fail implements IProcessStepDefinition {
		public void executeStep(ProcessRealization pInstance) {
			List<Id> recordId = pInstance.getRecordIds();
			Contact c = [SELECT Id,LastName FROM Contact Where Id IN :recordId];
			c.LastName = 'Not Smith';
			insert c;
		}
		public String getStepName() {
			return 'Step1Fail';
		}
	}
	
}