global class CancelWarehouseNotificationBatch implements Database.Batchable<PBSI__Shipped_Sales_Order_Line__c>, Database.Stateful {

	private Set<Id> orderIds;
	private Map<Id, String> errors;

	global CancelWarehouseNotificationBatch(Set<Id> cancelledOrders) {
		this.orderIds = cancelledOrders;
		this.errors = new Map<Id, String>();
	}

	global Iterable<PBSI__Shipped_Sales_Order_Line__c> start(Database.batchableContext BC) {
		return [SELECT Id, PBSI__Sales_Order__c FROM PBSI__Shipped_Sales_Order_Line__c WHERE Shipment_status__c = 'Processing' AND PBSI__Sales_Order__c IN: this.orderIds];
	}

	global void execute(Database.BatchableContext BC, List<PBSI__Shipped_Sales_Order_Line__c> scope) {
		for(PBSI__Shipped_Sales_Order_Line__c current : scope) {
			current.Shipment_status__c = 'New';
		}
		List<Database.SaveResult> result = Database.update(scope, false);
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
		if(!errors.isEmpty()){
			this.handleErrors();
		}
		List<Order_Stage__c> stages = [SELECT Id, Stage__c FROM Order_Stage__c WHERE Stage__c = 'Processing' AND Sales_Order__c IN: this.orderIds FOR UPDATE];
		for(Order_stage__c current : stages) {
			current.Stage__c = 'Error';
		}
		List<Database.SaveResult> sResult = Database.update(stages, false);
		LogService log = LogService.getLogService();
		for(Database.SaveResult current : sResult) {
			if(!current.isSuccess()) {
				log.addError().type('MASS_NOTIFY').relatedObjId(current.getId()).attachment('Errors.txt', JSON.serialize(current.getErrors()));
			}
		}
		log.save();
	}

	private void handleErrors() {
		LogService log = LogService.getLogService();
		for(Id currentOId : this.errors.keySet()) {
			log.addError().type('MASS_NOTIFY').relatedObjId(currentOId).attachment('Error_lines.txt', this.errors.get(currentOId));
		}
		log.save();
		Database.executeBatch(new CancelWarehouseNotificationBatch(this.errors.keySet()));
	}
}