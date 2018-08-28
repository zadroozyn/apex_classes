global class B24DesadvOrderStageController extends B24DesadvController {
	
	public Map<Id, Order_Stage__c> orderStages {get; private set;}
	public String selectedOrderStageId  {get; set;}

	public B24DesadvOrderStageController() {
		//sObjId = ApexPages.currentPage().getParameters().get('id');
		if(orderStages.values().size() == 1) {
			selectedOrderStageId = orderStages.values()[0].Id;
			orderStageSelection();
		}
	}

	private void loadOrderStages() {
		if(isTransferOrder()) {
			orderStages = new Map<Id, Order_Stage__c>([SELECT Id, Name, Transmission_Id__c FROM Order_Stage__c WHERE Transfer_Order__c = :sObjId]);
		} else {
			orderStages = new Map<Id, Order_Stage__c>([SELECT Id, Name, Transmission_Id__c FROM Order_Stage__c WHERE Sales_Order__c = :sObjId]);
		}
	}

	public List<SelectOption> getAllOrderStages() {
		List<SelectOption> ret = new List<SelectOption>();
		ret.add( new SelectOption('', '-- select --') );
		for(Order_Stage__c stage: orderStages.values()) {
			ret.add( new SelectOption(stage.Id, stage.Name) );
		}
		return ret;
	}

	public String getOrdersSize() {
		return String.valueOf(orderStages.keySet().size());
	}

	public void orderStageSelection() {
		createLinesWrappers();
		packageNumber = getTransmissionId();
	}

	public String getTransmissionId() {
		return orderStages.containsKey(selectedOrderStageId) ? orderStages.get(selectedOrderStageId).Transmission_Id__c : 'none';
	}

	public override void createLinesWrappers() {
		if(orderStages == null) {
			loadOrderStages();
		}
		lines = new List<LineWrapper>();
		if(orderStages.containsKey(selectedOrderStageId)) {
			if(isTransferOrder()) {
	            for(PBSI__Shipped_Tranfer_Line__c line: [SELECT Id,Name,PBSI__Item__r.Name,PBSI__Item__r.EAN_Number__c,PBSI__Quantity__c, CreatedDate , DESADV_sent__c
	                    FROM PBSI__Shipped_Tranfer_Line__c WHERE Notification_Transaction__c = :selectedOrderStageId]) {
	                lines.add( new LineWrapper(line) );
	            }
	        } else {
	            for(PBSI__Shipped_Sales_Order_Line__c line: [SELECT Id,Name, PBSI__Item__r.Name, PBSI__Item__r.EAN_Number__c,PBSI__Quantity_Shipped__c, PBSI__Sales_Order_Line__r.Line_Order_Number__c,CreatedDate,DESADV_sent__c 
	                        FROM PBSI__Shipped_Sales_Order_Line__c WHERE Notification_Transaction__c = :selectedOrderStageId]) {
	                lines.add( new LineWrapper(line) );
	            }
	        }
		}
	}

	protected override String createJsonString() {
		return msgFactory.desadv(orderStages.get(selectedOrderStageId), selectedCarrier);
	}
}