public class KN_SO_RequestBuilder extends RequestBuilder {

	private KN_Order orderWrap;

	public KN_SO_RequestBuilder(Id stageId) {
		this(stageId, CustomApexLogin.getSessionId());
	}

	public KN_SO_RequestBuilder(Id stageId, String sessionId) {
		this.stageId = stageId;
		this.sessionId = sessionId;
		this.stage = [SELECT Id, Stage__c, Sales_Order__c, Transmission_Id__c, RecordTypeId,
			(SELECT Id, PBSI__Item__r.EAN_Number__c,
				   PBSI__Item__r.Name,
				   PBSI__Quantity_Shipped__c,
				   PBSI__Sales_Order_Line__r.PBSI__ItemDescription__c,
				   Shipment_status__c,
				   PBSI__Sales_Order__r.PBSI__From_Location__r.KN_Unit_of_measurement__c
	              	FROM Shipped_Sales_Order_Lines__r)
	        FROM Order_stage__c WHERE Id =: this.stageId];

		this.order = [SELECT Id,
			  Bill_Of_Delivery_B2C_Template_ID__c,
			  Bill_of_Delivery_Partial_Conga_ID__c,
			  Bill_of_Delivery__c,
			  Culture__c,
			  Customer_Number__c,
			  Delivery_Name__c,
			  Delivery_instructions__c,
			  Fulfiller__c,
			  Fulfiller_no_sms__c,
			  Name,
			  PBSI__Contact_Email__c,
			  PBSI__Contact__r.Id,
			  PBSI__Delivery_ATTN_to_Phone__c,
			  PBSI__Delivery_ATTN_to__c,
			  PBSI__Delivery_Address_line2__c,
			  PBSI__Delivery_City__c,
			  PBSI__Delivery_Company__c,
			  PBSI__Delivery_Postal_Code__c,
			  PBSI__Delivery_State__c,
			  PBSI__Delivery_Streetnew__c,
			  PBSI__Delivery_country__c,
			  PBSI__From_Location__r.KN_Client_Id__c,
			  PBSI__From_Location__r.KN_Email_Template_Id__c,
			  PBSI__From_Location__r.KN_Logical_Address__c,
			  PBSI__From_Location__r.KN_Order_type_code__c,
			  PBSI__From_Location__r.KN_Order_Type_Code_B2C__c,
			  PBSI__From_Location__r.KN_depot__c,
			  PBSI__From_Location__r.Name,
			  Packing_instructions__c,
			  Proforma_Template_ID__c,
			  Purchase_Confirmation__c,
			  RecordTypeId,
			  Return_Information_Template__c,
			  Sales_Order_Type__c,
			  Shipping_Confirmation_Invoice_Email_ID__c,
			  Shipping_Options__c,
			  TransmissionIdentification__c,
			  B2B_Return_Info__c,
			  B2B_Return_Info_Id__c,
			  (SELECT Id,
				   PBSI__Item__r.EAN_Number__c,
				   PBSI__Item__r.Name,
				   PBSI__Quantity_Shipped__c,
				   PBSI__Sales_Order_Line__r.PBSI__ItemDescription__c,
				   Shipment_status__c,
				   PBSI__Sales_Order__r.PBSI__From_Location__r.KN_Unit_of_measurement__c,
				   Notification_transaction__c
					   FROM PBSI__R00N60000001ZR62EAG__r),
			  (SELECT Id FROM PBSI__Sales_Order_Lines__r WHERE PBSI__Quantity_Left_To_Ship__c > 0)
				FROM PBSI__PBSI_Sales_Order__c
				WHERE Id =: this.stage.Sales_Order__c
				];
		this.stage.Sales_Order__r = this.order;
	}

	public override AsyncRequestManager getRequestManager() {
		orderWrap = new KN_OrderFactory().order(this.stage);
		SORequestManager rManager = new SORequestManager(this.order.Id, this.stageId);
		rManager.addRequestBuilder(this.getKnXmlRequestBuilder());

		CongaMsgBuilderKN cBuilder = new CongaMsgBuilderKN(this.order, this.sessionId);
		cBuilder.setTransmissionIdentification(this.stage.Transmission_Id__c);
		
		if(order.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order')) {
			rManager.addRequestBuilder(cBuilder.getB2CBODBuilder());
			rManager.addRequestBuilder(cBuilder.getConfirmationEmailBuilder());
		} else {
			if(this.isPartial()) {
				rManager.addRequestBuilder(cBuilder.getPartialBodBuilder(this.stageId));
			} else {
				rManager.addRequestBuilder(cBuilder.getFullBodBuilder());
			}
		}
		return rManager;
	}

	@testVisible
	private HttpRequestBuilder getKnXmlRequestBuilder() {
		HttpRequestBuilder output = new HttpRequestBuilder('Callout:K_N', 'POST');
        output.setHeader('Content-Type', 'text/xml');
		output.setBody(Blob.valueOf(new KNDeliveryXmlCreator(orderWrap).buildXml().toXmlString()));
		return output;
	}
}