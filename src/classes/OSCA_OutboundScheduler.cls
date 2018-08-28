global class OSCA_OutboundScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		OSCA_CreateStagingsNewPOs b = new OSCA_CreateStagingsNewPOs();
		b.executeOSCAOutbound(true);
		Database.executebatch(b, OSCA_CreateStagingsNewPOs.DEFAULT_BATCH_SIZE);
	}
}