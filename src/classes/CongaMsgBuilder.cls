public virtual without sharing class CongaMsgBuilder {

	protected PBSI__PBSI_Sales_Order__c order;
	protected String sessionId;
	private Id organizationId;
	private Map<String, Conga_Query_Mapping__c> congaQueryMap;

	public CongaMsgBuilder(PBSI__PBSI_Sales_Order__c order, String sessionId) {
		this.order = order;
		this.sessionId = sessionId;
		congaQueryMap = Conga_Query_Mapping__c.getAll();
	}

	public CongaMsgBuilder(Id orderId, String sessionId) {
		this([SELECT Id, Culture__c, Bill_of_Delivery__c, Bill_of_Delivery_Partial_Conga_ID__c,
				PBSI__Contact__c, Shipping_Confirmation_Invoice_Email_ID__c, Purchase_Confirmation__c,
				TransmissionIdentification__c, Bill_Of_Delivery_B2C_Template_ID__c, Return_Information_Template__c,
				Proforma_Template_ID__c, PBSI__From_Location__r.KN_Email_Template_Id__c
				FROM PBSI__PBSI_Sales_Order__c WHERE Id =: orderId LIMIT 1], sessionId);
	}

	@testVisible
	protected HttpRequestBuilder getDefaultBodBuilder() {
		HttpRequestBuilder output = this.getDefaultBuilder();
		output.setParam('AC0', '1');
		output.setParam('AC1', 'Bill+of+Delivery+Generated+By+On+AG');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('FP0', '1');
		return output;
	}

	public virtual HttpRequestBuilder getFullBodBuilder() {
		HttpRequestBuilder output = this.getDefaultBodBuilder();
		output.setParam('TemplateId', this.order.Bill_of_Delivery__c);
		output.setParam('QueryId', '[LineItems]' + this.congaQueryMap.get('fullBodLines').Conga_Query_Id__c + '?pv0=' + this.order.Id);
		return output;
	}

	public virtual HttpRequestBuilder getPartialBodBuilder(Id stageId) {
		HttpRequestBuilder output = this.getDefaultBodBuilder();
		output.setParam('TemplateId', this.order.Bill_of_Delivery_Partial_Conga_ID__c);
		output.setParam('QueryId', '[LineItems]' + this.congaQueryMap.get('partialBodLines').Conga_Query_Id__c + '?pv0=' + stageId
				+ ',[AlreadyDelTot]'+ this.congaQueryMap.get('partialBodAlreadyDeliveredTotals').Conga_Query_Id__c + '?pv0=' + stageId + '~pv1=' + this.order.Id
				+ ',[InThisShip]'+ this.congaQueryMap.get('partialBodInThisShipment').Conga_Query_Id__c + '?pv0=' + stageId
				);
		return output;
	}

	@testVisible
	protected virtual HttpRequestBuilder getB2CBodBuilder() {
		HttpRequestBuilder output = this.getDefaultBodBuilder();
		output.setParam('QueryId', '[LineItems]' + this.congaQueryMap.get('fullBodLines').Conga_Query_Id__c + '?pv0=' + this.order.Id);
		return output;
	}

	@testVisible
	protected HttpRequestBuilder getDefaultBuilder() {
		HttpRequestBuilder output = new HttpRequestBuilder(Conga_Composer_base_Url__c.getInstance().URL__c, 'GET');
		output.setParam('sessionId', this.sessionId);
		output.setParam('id', this.order.Id);
		output.setParam('serverURL', System.URL.getSalesforceBaseURL().toExternalForm()
				+ '/services/Soap/u/40.0/' + OrganizationService.getInstance().organizationId);
		return output;
	}

	private HttpRequestBuilder getDefaultConfirmationBuilder() {
		HttpRequestBuilder output = this.getDefaultBuilder();
		output.setParam('EmailToId', this.order.PBSI__Contact__c);
		output.setParam('EmailFromId', '0D2D0000000027T');
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			output.setParam('EmailBCC', ONRLogisticsGateway.EMAIL_CC);
		}
		output.setParam('DS7', '2');
		output.setParam('APIMode', '12');
		return output;
	}

	public HttpRequestBuilder getShippingEmailBuilder() {
		HttpRequestBuilder output = this.getDefaultConfirmationBuilder();
		output.setParam('CETID', this.order.Shipping_Confirmation_Invoice_Email_ID__c);
		output.setParam('QueryId',  this.congaQueryMap.get('shippingConfirmationLines').Conga_Query_Id__c + '?pv0=' + this.order.Id);
		return output;
	}

	public HttpRequestBuilder getConfirmationEmailBuilder() {
		HttpRequestBuilder output = this.getDefaultConfirmationBuilder();
		output.setParam('CETID', this.order.Purchase_Confirmation__c);
		output.setParam('QueryId', this.congaQueryMap.get('fullBodLines').Conga_Query_Id__c + '?pv0=' + this.order.Id);
		return output;
	}
}