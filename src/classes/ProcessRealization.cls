public class ProcessRealization {

	public class ProcessAlreadyStartedException extends Exception {}
	public class ProcessStepsNotDefinedException extends Exception {}

	private Queue stepsQueue;
	private String processName;
	private Boolean alreadyStarted;
	private List<Id> recordIds;
	private IProcessStepDefinition currentStepDefinition;
	public ProcessContext context;


	public ProcessRealization(Id recordId, IProcessDefinition procDef) {
		this(new List<Id>{recordId}, procDef);
	}

	public ProcessRealization(List<Id> recordIds, IProcessDefinition procDef) {
		this.stepsQueue = procDef.getStepsQueue();
		this.processName = procDef.getProcessName();
		alreadyStarted = false;
		this.recordIds = recordIds;
		context = new ProcessContext();
	}

	public void startProcess() {
		if(!alreadyStarted) {
			if(hasNextStep()) {
				alreadyStarted = true;
				System.enqueueJob(getNextStep());
			} else {
				throw new ProcessStepsNotDefinedException();
			}
		} else {
			throw new ProcessAlreadyStartedException();
		}
	}

	public Boolean hasNextStep() {
		return !stepsQueue.isEmpty();
	}

	public ProcessStep getNextStep() {
		String stepClassName = (String) stepsQueue.dequeue();
		currentStepDefinition = (IProcessStepDefinition) Type.forName(stepClassName).newInstance();
		return new ProcessStep(this);
	}

	public List<Id> getRecordIds() {
		return recordIds;
	}

	public String getProcessName() {
		return processName;
	}

	public IProcessStepDefinition getCurrentStep() {
		return currentStepDefinition;
	}

	public class ProcessContext {
		private Map<String, Object> valuesMap;
		public B24Authorization b24AuthObj;
		public ProcessContext() {
			valuesMap = new Map<String, Object>();
		}
		
		public void put(String name, Object value) {
			valuesMap.put(name.toLowerCase(), value);
		}

		public Object get(String name) {
			return valuesMap.get(name.toLowerCase());
		}

		public Set<String> getKeys() {
			return valuesMap.keySet();
		}
	}
}