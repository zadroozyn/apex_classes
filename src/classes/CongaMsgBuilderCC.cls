public class CongaMsgBuilderCC extends CongaMsgBuilder {

	public CongaMsgBuilderCC(PBSI__PBSI_Sales_Order__c order, String sessionId) {
		super(order, sessionId);
	}

	public CongaMsgBuilderCC(Id orderId, String sessionId) {
		super(orderId, sessionId);
	}

	public override HttpRequestBuilder getFullBodBuilder() {
		return this.addBodParameters(super.getFullBodBuilder());
	}

	public override HttpRequestBuilder getPartialBodBuilder(Id stageId) {
		return this.addBodParameters(super.getPartialBodBuilder(stageId));
	}

	public override HttpRequestBuilder getB2CBodBuilder() {
		HttpRequestBuilder output = addBodParameters(super.getB2CBodBuilder());
		output.setParam('TemplateId', this.order.Bill_Of_Delivery_B2C_Template_ID__c);
		return output;
	}

	public HttpRequestBuilder getB2CReturnInformation() {
		HttpRequestBuilder output = addBodParameters(super.getB2CBodBuilder());
		output.setParam('TemplateId', this.order.Return_Information_Template__c);
		output.setParam('MFTS1', 'Return_information_generated__c');
		output.setParam('OFN', 'Return+information');
		return output;
	}

	public HttpRequestBuilder getB2BReturnInformation() {
		HttpRequestBuilder output = addBodParameters(getDefaultBuilder());
		output.setParam('TemplateId', this.order.B2B_Return_Info_Id__c);
		output.setParam('MFTS1', 'Return_information_generated__c');
		output.setParam('OFN', 'Return+information');
		output.setParam('FP0', '1');
		return output;
	}

	private HttpRequestBuilder addBodParameters(HttpRequestBuilder val) {
		val.setParam('OFN', 'Bill+of+Delivery');
		val.setParam('DS7', '13');
		val.setParam('APIMode', '1');
		val.setParam('UF0', '1');
		val.setParam('MFTS1', 'BoD_Generated__c');
		val.setParam('MFTSValue1', 'true');
		return val;
	}
}