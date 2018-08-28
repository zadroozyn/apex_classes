public class CongaMsgBuilderKN extends CongaMsgBuilder {

	private String transmissionIdentification;

	public CongaMsgBuilderKN(PBSI__PBSI_Sales_Order__c order, String sessionId) {
		super(order, sessionId);
	}

	public CongaMsgBuilderKN(Id orderId, String sessionId) {
		super(orderId, sessionId);
	}

	public override HttpRequestBuilder getFullBodBuilder() {
		HttpRequestBuilder output = this.addBodParameters(super.getFullBodBuilder());
		if(this.order.B2B_Return_Info__c) {
			attachB2BReturnInfo(output);
		} else {
			output.setParam('OFN', getTransmissionIdentification() );
		}
		return output;
	}

	public override HttpRequestBuilder getPartialBodBuilder(Id stageId) {
		HttpRequestBuilder output = this.addBodParameters(super.getPartialBodBuilder(stageId));
		if(this.order.B2B_Return_Info__c) {
			attachB2BReturnInfo(output);
		} else {
			output.setParam('OFN', getTransmissionIdentification() );
		}
		return output;
	}

	private HttpRequestBuilder attachB2BReturnInfo(HttpRequestBuilder httpReq) {
		String existingTemplateIds = httpReq.mapParams.get('TemplateId');
		String allTemplates = '';
		if(!String.isEmpty(existingTemplateIds)) {
			allTemplates = existingTemplateIds + ',';
		}
		String b2bRetInfoTemplateId = this.order.B2B_Return_Info_Id__c;
		allTemplates += b2bRetInfoTemplateId;
		httpReq.setParam('TemplateId', allTemplates);
		httpReq.setParam('MTOFN', getTransmissionIdentification() );
		httpReq.setParam('Zippdfs', '1');
		return httpReq;
	}

	public override HttpRequestBuilder getB2CBodBuilder() {
		HttpRequestBuilder output = addBodParameters(super.getB2CBodBuilder());
		output.setParam('TemplateId', this.order.Bill_Of_Delivery_B2C_Template_ID__c
				+ ',' + this.order.Return_Information_Template__c
				+ (String.isNotBlank(this.order.Proforma_Template_ID__c) ? ',' + this.order.Proforma_Template_ID__c : ''));
		output.setParam('MTOFN', getTransmissionIdentification() );
		output.setParam('Zippdfs', '1');
		return output;
	}

	private HttpRequestBuilder addBodParameters(HttpRequestBuilder val) {
		val.setParam('DS7', '2');
		val.setParam('APIMode', '12');
		val.setParam('DefaultPDF', '1');
		val.setParam('EmailToId', ONRLogisticsGateway.EMAIL_TO_ID);
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			val.setParam('EmailCC', ONRLogisticsGateway.EMAIL_CC);
		}
		val.setParam('EmailTemplateId', this.order.PBSI__From_Location__r.KN_Email_Template_Id__c);
		return val;
	}

	public String getTransmissionIdentification() {
		return !String.isBlank(this.transmissionIdentification) ? this.transmissionIdentification : this.order.TransmissionIdentification__c;
	}

	public void setTransmissionIdentification(String transmissionId) {
		this.transmissionIdentification = transmissionId;
	}
}