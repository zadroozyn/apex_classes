public class WebOrderNotifier implements Queueable, Database.AllowsCallouts{

	private Id stageId;
	private String sessionId;

	public WebOrderNotifier(Id stageId) {
		this.stageId = stageId;
		this.sessionId = Userinfo.getSessionId();
	}

	public void execute(QueueableContext context) {
		LogService log = LogService.getLogService();
		Order_Stage__c stage = [SELECT Id, Stage__c, Sales_Order__c, Sales_Order__r.Fulfiller__c FROM Order_Stage__c WHERE Id =: this.stageId FOR UPDATE];
		List<PBSI__Shipped_Sales_Order_Line__c> pLines = [SELECT Id FROM PBSI__Shipped_Sales_Order_Line__c WHERE Shipment_status__c = 'New' AND PBSI__Sales_Order__c =: stage.Sales_Order__c];
		try {
			stage.Stage__c = 'Processing';
			update stage;
		} catch (Exception e) {
			log.addError().type('WEB_NOTIFICATION').relatedObjId(stage.Sales_Order__c).info('Coulnd\'t find order stage with stage \'new\'');
		}

		boolean error = false;
		try {
			for(PBSI__Shipped_Sales_Order_Line__c current : pLines) {
				current.Shipment_status__c = 'Processing';
				current.Notification_transaction__c = this.stageId;
			}
			update pLines;
		} catch (Exception e) {
			error = true;
		}
		if(error || pLines.size() == 0) {
			log.addError().type('WEB_NOTIFICATION').relatedObjId(stage.Sales_Order__c).info('Couldn\'t update lines of SO, or no lines for notification.');
		} else {
			AsyncRequestManager rManager;
			if(stage.Sales_order__r.Fulfiller__c == 'KN') {
				rManager = new KN_SO_RequestBuilder(stage.Id, this.sessionId).getRequestManager();
			} else if(stage.Sales_Order__r.Fulfiller__c == 'CargoCare') {
				rManager = new CCRequestBuilder(stage.Id, this.sessionId).getRequestManager();
			}
			rManager.enqueue();
		}
		log.save();
	}
}