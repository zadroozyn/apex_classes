public class SORequestManager extends KNRequestManager {

	private Id orderId;
	private Id stageId;

	public SORequestManager(Id orderId, Id stageId) {
		this.orderId = orderId;
		this.stageId = stageId;
	}

	public override void onError(Exception e) {
		LogService log = LogService.getLogService();
		if(this.currentRepetition < 3 && !Test.isRunningTest()){
			this.currentRepetition += 1;
			this.enqueue();
		} else {
			log.addError().exception(e).type('WAREHOUSE_TRANSFER_FAILURE').relatedObjId(this.orderId).info('Request failed for ' + this.currentRepetition + 'times. See attached request').attachment('request.txt', this.getRequestBuilder().getRequest().toString() + '\n' + this.getRequestBuilder().getRequest().getBody());
			try {
				update new PBSI__PBSI_Sales_Order__c(
						Id = orderId,
						Fulfiller_status__c = 'Error'
						);
			} catch(Exception ex) {
				log.addError().exception(ex).type('UPDATE').relatedObjId(this.orderId);
			}
		}
		log.save();
	}

	public override void execute(QueueableContext context){
		LogService log = LogService.getLogService();
		HttpResponse response;
		try {
			Log l = log.addCallout().type(this.getCurrentRequestType()).relatedObjId(this.orderId);
			if(this.getRequestBuilder().getRequest() != null) {
				l.attachment('request.txt', this.getRequestBuilder().getRequest().toString() + '\n' + this.getRequestBuilder().getRequest().getBody());
			}
			response = this.getRequestBuilder().sendRequest();
			if(response != null) {
				l.attachment('response.txt', response.toString() + '\n' + response.getBody());
			}
			this.handleResponse(response);
		} catch (Exception e) {
			this.onError(e);
		}
		log.save();
	}

	private void handleResponse(HttpResponse response) {
		if(this.getCurrentRequestType() == 'CONGA') {
			String resp = response.getBody();
			if(resp == CongaResponse.FAIL_POST_MERGE) {
				if(this.currentRepetition < 5 && !Test.isRunningTest()) {
					this.currentRepetition += 1;
					this.enqueue();
				} else {
					this.logCongaError(response);
				}
			} else if(resp == CongaResponse.NO_AUTH) {
				this.logCongaError(response);
			} else if(resp == CongaResponse.DONE
					|| resp == CongaResponse.FAIL_TO_GET_DOCS
					|| Pattern.matches('[a-zA-Z0-9]{18}|[a-zA-Z0-9]{15}', resp)) {
				this.callback(response);
			} else  {
				LogService log = LogService.getLogService();
				log.addError().type('CONGA_INFO').relatedObjId(this.orderId).info('Unexpected conga response.').attachment('response.txt', resp);
				log.save();
				this.callback(response);
			}
		} else {
			this.callback(response);
		}
	}

	private void logCongaError(HttpResponse response) {
		LogService log = LogService.getLogService();
		log.addError().type('CONGA_FAILURE').relatedObjId(this.orderId).info('Conga failed to generate merge document for ' + (this.currentRepetition + 1) + ' times. Full endpoint was:\n' + this.getRequestBuilder().getRequest().getEndpoint());
		log.save();
	}

	private String getCurrentRequestType() {
		if(this.getRequestBuilder().getEndpoint().containsIgnoreCase('composer.congamerge.com')) {
			return 'CONGA';
		}
		return 'KN';
	}

	protected override void orderUpdate() {
		LogService log = LogService.getLogService();
		PBSI__PBSI_Sales_Order__c order = this.getOrder();
		final List<PBSI__Shipped_Sales_Order_Line__c> lines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		for(PBSI__Shipped_Sales_Order_Line__c current : order.PBSI__R00N60000001ZR62EAG__r) {
			if(order.Fulfiller__c == 'CargoCare') {
				current.Shipment_status__c = 'Ready to ship';
			} else {
				current.Shipment_status__c = 'In Shipment';
			}
			lines.add(current);
		}
		order.Id = this.orderId;
		order.Notified_Fulfiller__c = true;
		order.Fulfiller_status__c = 'Notified';
		if(order.Fulfiller__c != 'CargoCare') {
			order.Transmission_Count__c += 1;
		}
		try {
			Database.update(lines);
			Database.update(order);
			if(order.Order_stages__r.size() != 0) {
				order.Order_stages__r[0].Stage__c = 'Finished';
				Database.update(order.Order_stages__r[0]);
			}
		} catch (DmlException e) {
			log.addError().exception(e).type('UPDATE').relatedObjId(this.orderId);
		}
		log.save();
	}

	private PBSI__PBSI_Sales_Order__c getOrder() {
		LogService log = LogService.getLogService();
		PBSI__PBSI_Sales_Order__c order;
		try {
			order = [SELECT Id, 
				  Notified_Fulfiller__c, 
				  Transmission_Count__c,
				  Fulfiller__c,
				  (SELECT Id, Shipment_status__c FROM PBSI__R00N60000001ZR62EAG__r WHERE Notification_transaction__c =: this.stageId),
				  (SELECT Id, Stage__c FROM Order_stages__r WHERE Id =: this.stageId)
					  FROM PBSI__PBSI_Sales_Order__c WHERE Id =: this.orderId LIMIT 1 FOR UPDATE];
		} catch (Exception e) {
			log.addError().exception(e).type('QUERY').relatedObjId(this.orderId);
		}
		log.save();
		return order;
	}
}