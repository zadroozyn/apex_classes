public class KN_TO_RequestManager extends KNRequestManager {

	private Id transferOrderId;
	private Set<Id> shippedLinesIds;
	private Id orderStageId;

	public KN_TO_RequestManager(Id toId, Id stageId) {
		this.transferOrderId = toId;
		this.orderStageId = stageId;
	}

	public override void onError(Exception e) {
		LogService log = LogService.getLogService();
		if(this.isCurrentRequestConga()) {
			this.callback(null);
		} else if(this.currentRepetition < 3){
			this.currentRepetition += 1;
			this.enqueue();
		} else {
			log.addError().exception(e).relatedObjId(this.transferOrderId);
			try {
				update new PBSI__Transfer_Order__c(
					Id = this.transferOrderId,
					Fulfiller_status__c = 'Error'
				);

				update new Order_stage__c(
					Id = this.orderStageId,
					Stage__c = 'Error'
				);
			} catch(Exception ex) {
				log.addError().exception(ex).type('UPDATE').relatedObjId(this.transferOrderId);
			}
		}
		log.save();
	}

	public override void execute(QueueableContext context){
		LogService log = LogService.getLogService();
		HttpResponse response;
		try {
			Log l = log.addCallout().type('KN_TO_REQUEST').relatedObjId(this.transferOrderId);
			if(this.getRequestBuilder().getRequest() != null) {
				l.attachment('request.txt', this.getRequestBuilder().getRequest().toString() + '\n' + this.getRequestBuilder().getRequest().getBody());
			}
			response = this.getRequestBuilder().sendRequest();
			if(response != null) {
				l.attachment('response.txt', response.toString() + '\n' + response.getBody());
			}
			this.callback(response);
		} catch (Exception e) {
			this.onError(e);
		}
		log.save();
	}

	private boolean isCurrentRequestConga() {
		return this.getRequestBuilder().getEndpoint().containsIgnoreCase('conga');
	}

	protected override void orderUpdate() {
		LogService log = LogService.getLogService();
		try {
			PBSI__Transfer_Order__c order = this.getOrder();
			order.Notified_Fulfiller__c = true;
			order.Fulfiller_status__c = 'Notified';
			Integer currentValue = order.Transmission_Count__c != null ? Integer.valueOf(order.Transmission_Count__c) : 0;
	    	order.Transmission_Count__c = ++currentValue;
	    	for (PBSI__Shipped_Tranfer_Line__c l: order.PBSI__Shipped_Tranfer_Lines__r) {
	        	l.Sent_to_Fulfiller__c = true;
	        }

	        Order_stage__c orderStage = new Order_stage__c();
	        orderStage.id = this.orderStageId;
	        orderStage.Stage__c = 'Finished';

	        Database.update(orderStage);
			Database.update(order);
			Database.update(order.PBSI__Shipped_Tranfer_Lines__r);
		} catch (DmlException e) {
			log.addError().exception(e).type('UPDATE').relatedObjId(this.transferOrderId);
		}
		log.save();
	}

	private PBSI__Transfer_Order__c getOrder() {
		LogService log = LogService.getLogService();
		PBSI__Transfer_Order__c order;
		try {
			order = [SELECT Id, Notified_Fulfiller__c, Transmission_Count__c,
						(SELECT Id FROM PBSI__Shipped_Tranfer_Lines__r WHERE Notification_transaction__c = :this.orderStageId) 
						FROM PBSI__Transfer_Order__c WHERE Id =: this.transferOrderId LIMIT 1 FOR UPDATE];
		} catch (Exception e) {
			log.addError().exception(e).type('QUERY').relatedObjId(this.transferOrderId);
		}
		log.save();
		return order;
	}
}