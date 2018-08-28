global class InitiateWarehouseNotificationBatch implements Database.Batchable<PBSI__Shipped_Sales_Order_Line__c>, Database.Stateful{

	private Set<Id> stageIds;
	private Map<Id, Id> orderId2StageId;
	private List<Order_stage__c> stages;
	private Set<Id> processedSOIds;
	private Map<Id, String> errors;

	global InitiateWarehouseNotificationBatch(Set<Id> stageIds) {
		this.stageIds = stageIds;
		this.processedSOIds = new Set<Id>();
		this.errors = new Map<Id, String>();
		this.orderId2StageId = new Map<Id, String>();
	}

	global Iterable<PBSI__Shipped_Sales_Order_Line__c> start (Database.BatchableContext BC) {
		this.stages = [SELECT Id, Stage__c, Sales_Order__c FROM Order_Stage__c WHERE Id IN : this.stageIds FOR UPDATE];

		Set<Id> filteredOrders = new Set<Id>();
		for(Order_stage__c current : this.stages) {
			this.orderId2StageId.put(current.Sales_order__c, current.Id);
			if(current.Stage__c == 'Scheduled') {
				filteredOrders.add(current.Sales_Order__c);
				current.Stage__c = 'Processing';
			}
		}

		update this.stages;
		return [SELECT Id, Shipment_status__c, PBSI__Sales_Order__c FROM PBSI__Shipped_Sales_Order_Line__c WHERE Shipment_status__c = 'New' AND PBSI__Sales_Order__c IN: filteredOrders];
	}
	global void execute(Database.BatchableContext BC, List<PBSI__Shipped_Sales_Order_Line__c> scope) {
		List<PBSI__Shipped_Sales_Order_Line__c> processedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		for(PBSI__Shipped_Sales_Order_Line__c current : scope) {
			if(!errors.keySet().contains(current.PBSI__Sales_Order__c)) {
				current.Shipment_status__c = 'Processing';
				current.Notification_transaction__c = this.orderId2stageId.get(current.PBSI__Sales_Order__c);
				this.processedSOIds.add(current.PBSI__Sales_Order__c);
				processedLines.add(current);
			}
		}
		List<Database.SaveResult> result = Database.update(processedLines, false);
		for(Integer i = 0; i < result.size(); i++) {
			Database.SaveResult current = result.get(i);
			if(!current.isSuccess()) {
				String temp;
				if(this.errors.containsKey(scope.get(i).PBSI__Sales_Order__c)) {
					temp = this.errors.get(scope.get(i).PBSI__Sales_Order__c);
				} else {
					temp = '';
				}
				for(Database.Error currentErr : current.getErrors()) {
					temp += scope.get(i).PBSI__Sales_Order__c + '; Status code: ' + currentErr.getStatusCode()  + '; Fields: ' + currentErr.getFields() + '; Message: ' + currentErr.getMessage();
				}
				this.errors.put(scope.get(i).PBSI__Sales_Order__c, temp);
			}
		}
	}

	global void finish(Database.BatchableContext BC) {
		if(this.processedSOIds.removeAll(errors.keySet())) {
			this.handleErrors();
		}
		// Due to scheduling queueable job EnqueueWarehouseNotificationBatch SHOULD ALWAys be run with size 1
		Database.executeBatch(new EnqueueWarehouseNotificationBatch([SELECT Id, Sales_Order__c, Sales_Order__r.Fulfiller__c FROM Order_Stage__c WHERE Id IN : this.stages AND Sales_order__c IN :this.processedSOIds]), 1);
	}

	private void handleErrors() {
		LogService log = LogService.getLogService();
		for(Id currentOId : this.errors.keySet()) {
			log.addError().type('MASS_NOTIFY').relatedObjId(currentOId).createActivity().attachment('Error_lines.txt', this.errors.get(currentOId));
		}
		log.save();
		Database.executeBatch(new CancelWarehouseNotificationBatch(this.errors.keySet()));
	}
}