public class KN_TO_RequestBuilder {

	public class ShippedLinesException extends Exception {}

	private KN_Order orderWrap;
	private Order_stage__c orderStageObj;
	private Map<String, Conga_Query_Mapping__c> congaQueryMap;

	public KN_TO_RequestBuilder(Id orderStageId) {
		congaQueryMap = Conga_Query_Mapping__c.getAll();
		orderStageObj = [SELECT Id,Transmission_Id__c,RecordTypeId,
				Transfer_Order__r.Id, Transfer_Order__r.Name, Transfer_Order__r.Notified_Fulfiller__c, Transfer_Order__r.PBSI__From_Location__c, Transfer_Order__r.PBSI__From_Location__r.Name,
		        Transfer_Order__r.Special_Instructions__c,
		        Transfer_Order__r.PBSI__To_Location__r.Name,
		        Transfer_Order__r.Address_Line_1__c,
		        Transfer_Order__r.Address_Line_2__c,
		        Transfer_Order__r.State__c,
		        Transfer_Order__r.City__c,
		        Transfer_Order__r.Country__c,
		        Transfer_Order__r.Shipping_Options__c,
		        Transfer_Order__r.Postal_Code__c,
		        Transfer_Order__r.PBSI__From_Location__r.KN_Logical_Address__c,
		        Transfer_Order__r.PBSI__From_Location__r.KN_Client_Id__c,
		        Transfer_Order__r.PBSI__From_Location__r.KN_depot__c,
		        Transfer_Order__r.PBSI__From_Location__r.KN_Email_Template_Id__c,
		        	(SELECT Id, Name, PBSI__Item__r.Name, PBSI__Item__r.PBSI__description__c, PBSI__Quantity__c, PBSI__Item__r.EAN_Number__c,
	              	PBSI__Transfer_Order__r.PBSI__From_Location__r.KN_Unit_of_measurement__c 
	              	FROM Shipped_Transfer_Lines__r
	              	WHERE Sent_to_Fulfiller__c = false)
	            FROM Order_stage__c WHERE ID = :orderStageId];
	     if(orderStageObj.Shipped_Transfer_Lines__r == null || orderStageObj.Shipped_Transfer_Lines__r.isEmpty()) {
	        throw new ShippedLinesException('This Transfer Order has no lines to ship: '+orderStageObj.Transfer_Order__r.Name+', '+orderStageObj.Transfer_Order__r.Id);
	     }
		
	}

	public AsyncRequestManager getRequestManager() {
		orderWrap = new KN_OrderFactory().order(orderStageObj);
		KN_TO_RequestManager rManager = new KN_TO_RequestManager(orderStageObj.Transfer_Order__r.Id, orderStageObj.Id);
		rManager.addRequestBuilder(this.getKnXmlRequestBuilder());
		rManager.addRequestBuilder( getDefaultPackingSlipRequest() );
		return rManager;
	}

	private HttpRequestBuilder getDefaultPackingSlipRequest() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('Templateid', 'a0z5700000KZGn6');
		output.setParam('QueryId', '[ShippedTransferLines]' + congaQueryMap.get('knPackingSlip').Conga_Query_Id__c + '?pv0=' + orderStageObj.Transfer_Order__c + '~pv1=' + orderStageObj.Id);
		output.setParam('DefaultPDF', '1');
		output.setParam('AC0', '1');
		output.setParam('AC1', 'Packing+slip+Generated+By+On+AG');
		output.setParam('FP0', '1');
		output.setParam('SC0', '1');
		output.setParam('OFN', orderStageObj.Transmission_Id__c);
		output.setParam('DS7', '2');
		output.setParam('APIMode', '12');
		output.setParam('EmailToId', ONRLogisticsGateway.EMAIL_TO_ID);
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			output.setParam('EmailCC', ONRLogisticsGateway.EMAIL_CC);
		}
		output.setParam('EmailTemplateId', orderStageObj.Transfer_Order__r.PBSI__From_Location__r.KN_Email_Template_Id__c);
		return output;
	}

	private HttpRequestBuilder getDefaultURL() {
		HttpRequestBuilder output = new HttpRequestBuilderWithDuplicates(Conga_Composer_base_Url__c.getInstance().URL__c, 'GET');
		output.setParam('sessionId', CustomApexLogin.getSessionId());
		output.setParam('id', ((String)orderStageObj.Transfer_Order__r.Id).left(15));
		output.setParam('serverURL', System.URL.getSalesforceBaseURL().toExternalForm() + '/services/Soap/u/40.0/' + OrganizationService.getInstance().organizationId);
		return output;
		
	}

	@testVisible
	private HttpRequestBuilder getKnXmlRequestBuilder() {
		HttpRequestBuilder output = new HttpRequestBuilder('Callout:K_N', 'POST');
        output.setHeader('Content-Type', 'text/xml');
		output.setBody(Blob.valueOf(new KNDeliveryXmlCreator(orderWrap).buildXml().toXmlString()));
		return output;
	}
}