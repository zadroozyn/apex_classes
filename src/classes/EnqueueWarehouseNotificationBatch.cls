/* IMPORTANT should always be executed with batch size 1 */
global class EnqueueWarehouseNotificationBatch implements Database.Batchable<Order_Stage__c>, Database.Allowscallouts {
	private List<Order_stage__c> stages;

	global EnqueueWareHOuseNotificationBatch(List<Order_stage__c> stages) {
		this.stages = stages;
	}

	global Iterable<Order_stage__c> start (Database.BatchableContext BC) {
		return this.stages;
	}
	global void execute(Database.BatchableContext BC, List<Order_stage__c> scope) {
		LogService log = LogService.getLogService();
		if(scope.size() > 1) {
			log.addDebug().type('MASS_NOTIFY').info('EnqueueWarehouseNotificationBatch has been executed with scope bigger than one. \n User: ' + Userinfo.getName() + ' ' + Userinfo.getUserId() + ' at ' + String.valueOf(Datetime.now()) + '. Batch job id: ' + BC.getJobId());
		}
		boolean error;
		AsyncRequestManager rManager;
		for(Order_stage__c current : scope) {
			error = false;
			try {
				if(current.Sales_order__r.Fulfiller__c == 'KN') {
					rManager = new KN_SO_RequestBuilder(current.Id).getRequestManager();
				} else if(current.Sales_Order__r.Fulfiller__c == 'CargoCare') {
					rManager = new CCRequestBuilder(current.Id).getRequestManager();
				}
			} catch (Exception e) {
				error = true;
				log.addError().type('MASS_NOTIFY').relatedObjId(current.Id).exception(e);
			} finally {
				if(!error) {
					rManager.enqueue();
				}
			}
		}
		log.save();
	}
	global void finish(Database.BatchableContext BC) {
	}
}