public class CCRequestBuilder extends RequestBuilder {

	public CCRequestBuilder(Id stageId) {
		this(stageId, CustomApexLogin.getSessionId());
	}

	public CCRequestBuilder(Id stageId, String sessionId) {
		this.stageId = stageId;
		this.sessionId = sessionId;
		this.stage = [SELECT Id, Sales_Order__c, Stage__c FROM Order_stage__c WHERE Id =: this.stageId];
		this.order = [SELECT Id,
			  Bill_Of_Delivery_B2C_Template_ID__c,
			  Bill_of_Delivery_Partial_Conga_ID__c,
			  Bill_of_Delivery__c,
			  Culture__c,
			  Fulfiller__c,
			  PBSI__Contact__r.Id,
			  PBSI__From_Location__r.KN_Email_Template_Id__c,
			  Proforma_Template_ID__c,
			  Purchase_Confirmation__c,
			  RecordTypeId,
			  Return_Information_Template__c,
			  Shipping_Confirmation_Invoice_Email_ID__c,
			  B2B_Return_Info__c,
			  B2B_Return_Info_Id__c,
			  (SELECT Id, Shipment_status__c, Notification_transaction__c FROM PBSI__R00N60000001ZR62EAG__r),
			  (SELECT Id FROM PBSI__Sales_Order_Lines__r WHERE PBSI__Quantity_Left_To_Ship__c > 0)
				FROM PBSI__PBSI_Sales_Order__c
				WHERE Id =: this.stage.Sales_Order__c
				];
	}

	public override AsyncRequestManager getRequestManager() {
		SORequestManager rManager = new SORequestManager(this.order.Id, this.stageId);
		CongaMsgBuilderCC cBuilder = new CongaMsgBuilderCC(this.order, this.sessionId);
		if(order.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order')) {
			rManager.addRequestBuilder(cBuilder.getB2CBODBuilder());
			rManager.addRequestBuilder(cBuilder.getB2CReturnInformation());
			rManager.addRequestBuilder(cBuilder.getConfirmationEmailBuilder());
		} else {
			if(this.isPartial()) {
				rManager.addRequestBuilder(cBuilder.getPartialBodBuilder(this.stageId));
			} else {
				rManager.addRequestBuilder(cBuilder.getFullBodBuilder());
			}
		}
		if(order.B2B_Return_Info__c) {
			rManager.addRequestBuilder(cBuilder.getB2BReturnInformation());
		}

		return rManager;
	}
}