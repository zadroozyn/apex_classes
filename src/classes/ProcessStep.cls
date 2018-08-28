public class ProcessStep implements Queueable, Database.AllowsCallouts {

	private ProcessRealization pInstance;

	public ProcessStep(ProcessRealization pInstance) {
		this.pInstance = pInstance;
	}

	public void execute(QueueableContext context) {
		LogService logSrv = LogService.getlogService();
		try {
			pInstance.getCurrentStep().executeStep( pInstance );
			if(pInstance.hasNextStep()) {
				System.enqueueJob( pInstance.getNextStep() );
			}
		} catch(Exception e) {
			logSrv.addError()
				.type(pInstance.getProcessName()+'_'+pInstance.getCurrentStep().getStepName())
				.exception(e)
				.info(pInstance.getProcessName() + '\n' + JSON.serialize(pInstance.context));
		}
		logSrv.save();
	}
}