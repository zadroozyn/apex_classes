public with sharing class ConsumeKNDesadvSOProcess implements IProcessDefinition {

	private static final List<String> steps = new List<String>{
		OrderShippingConfirmation.class.getName(),
		B24ConfirmMsgDespatchAdv.class.getName()
	};

	public Queue getStepsQueue() {
		return new Queue(steps);
	}

	public String getProcessName() {
		return ConsumeKNDesadvSOProcess.class.getName();
	}
}