public class OSCA_AdminController {

	private static final String OUTBOUND_CLASS = OSCA_Outbound.class.getName();
	private static final String NEW_PO_CLASS = OSCA_CreateStagingsNewPOs.class.getName();
	private static final String SCHEDULER_CLASS = OSCA_OutboundScheduler.class.getName();
	
	public Id outboundClassId {public get; private set;}
	public Id newPoClassId {public get; private set;}
	public Id shedulerClassId {public get; private set;}

	public OSCA_AdminController() {
		loadClassesStatus();
	}

	public String getOutboundClassName() {
		return OUTBOUND_CLASS;
	}

	public String getNewPoClassName() {
		return NEW_PO_CLASS;
	}

	public String getSchedulerClassName() {
		return SCHEDULER_CLASS;
	}

	private void loadClassesStatus() {
		outboundClassId = getActiveClassId(OUTBOUND_CLASS);
		newPoClassId = getActiveClassId(NEW_PO_CLASS);
		shedulerClassId = getActiveClassId(SCHEDULER_CLASS);
	}

	private Id getActiveClassId(String className) {
		Id retId;
		List<AsyncApexJob> lJobs = retrieveActiveJobs(className);
		if(!lJobs.isEmpty()) {
			retId = lJobs[0].Id;
		}
		return retId;
	}

	private List<AsyncApexJob> retrieveActiveJobs(String className) {
		return [SELECT Id FROM AsyncApexJob
			WHERE JobType='BatchApex' and ApexClass.Name = :className 
			and (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding')];
	}

	public Boolean getAnyClassActive() {
		return outboundClassId != null || newPoClassId != null || shedulerClassId != null;
	}

	public void turnOn() {
		new OSCA_OutboundScheduler().execute(null);
		loadClassesStatus();
	}

	public void turnOff() {
		List<AsyncApexJob> allJobs = new List<AsyncApexJob>();
		allJobs.addAll(retrieveActiveJobs(OUTBOUND_CLASS));
		allJobs.addAll(retrieveActiveJobs(NEW_PO_CLASS));
		allJobs.addAll(retrieveActiveJobs(SCHEDULER_CLASS));
		for(AsyncApexJob job: allJobs) {
			System.abortJob(job.Id);
		}
		loadClassesStatus();
	}

}