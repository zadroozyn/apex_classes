public class ONRCongoComposer {

	public static final String FULL_B2C = 'full_b2c';
	public static final String FULL = 'full';
	public static final String PARTIAL = 'partial';
	public static final String BACKORDER = 'backorder';

	private PBSI__PBSI_Sales_Order__c order;
	@testVisible private String pdfType;
	private String sessionId;

	public ONRCongoComposer(PBSI__PBSI_Sales_Order__c order, Boolean isPartial, String sessionId) {
		this.order = order;
		this.sessionId = sessionId;
		this.pdfType = this.determinePDFType(isPartial);
	}

	public ONRCongoComposer(PBSI__PBSI_Sales_Order__c order, String sessionId) {
		this.order = order;
		this.sessionId = sessionId;
	}

	public HttpRequestBuilder getBodBuilder() {
		if(this.order.Fulfiller__c == 'KN') {
			return this.getBillOfDeliveryURLByType(this.pdfType);
		} else if (this.order.Fulfiller__c == 'CargoCare'){
			return this.getBODUrlCCByType(this.pdfType);
		}
		return null;
	}

	private HttpRequestBuilder getBODUrlCCByType(String type) {
		if(type == ONRCongoComposer.FULL_B2C) {
			return this.getFullB2cBodUrlCC();
		} else if(type == ONRCongoComposer.PARTIAL) {
			return this.getPartialB2bBodUrlCC();
		}
		return this.getFullB2bBodUrlCC();
	}

	private HttpRequestBuilder getFullB2cBodUrlCC() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('Templateid', this.order.Bill_Of_Delivery_B2C_Template_ID__c);
		output.setParam('QueryId=[LineItems]a1n57000000vor4?pv0', get15CharsFormattedId());
		output.setParam('AC0', '1');
		output.setParam('AC1', 'Bill+of+Delivery+Generated+By+On+AG');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('OFN', 'Bill+of+Delivery');
		output.setParam('FP0', '1');
		output.setParam('DS7', '13');
		output.setParam('APIMode', '1');
		output.setParam('UF0', '1');
		output.setParam('MFTS1', 'BoD_Generated__c');
		output.setParam('MFTSValue1', 'true');
		return output;
	}

	private HttpRequestBuilder getPartialB2bBodUrlCC() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('TemplateId', this.order.Bill_of_Delivery_Partial_Conga_ID__c);
		output.setParam('ReportID=[AlreadyDelivered]00OD0000005tU5J?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[LineItems]00OD0000005tKe8?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[LineItemsLefttoShip]00OD0000005soAF?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[ShippedTotals]00OD0000005tKe9?pv0', get15CharsFormattedId());
		output.setParam('QueryId', '[AlreadyDelTot]a1nD0000000snWF,[InthisShip]a1nD0000000snWU');
		output.setParam('AC0', '1');
		output.setParam('AC1', 'Partial+Bill+of+Delivery');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('OFN', 'Bill+of+Delivery' );
		output.setParam('SC0', '1');
		output.setParam('FP0', '1');
		output.setParam('DS7', '13');
		output.setParam('APIMode', '1');
		output.setParam('UF0', '1');
		output.setParam('MFTS1', 'BoD_Generated__c');
		output.setParam('MFTSValue1', 'true');
		return output;
	}

	private HttpRequestBuilder getFullB2bBodUrlCC() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('Templateid', this.order.Bill_of_Delivery__c);
		output.setParam('ReportID=[LineItems]00OD0000005smfv?pv0', get15CharsFormattedId());
		output.setParam('AC0', '1');
		output.setParam('AC1', 'Bill+of+Delivery+Generated+By+On+AG');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('OFN', 'Bill+of+Delivery');
		output.setParam('FP0', '1');
		output.setParam('DS7', '13');
		output.setParam('APIMode', '1');
		output.setParam('UF0', '1');
		output.setParam('MFTS1', 'BoD_Generated__c');
		output.setParam('MFTSValue1', 'true');
		return output;
	}

	public HttPRequestBuilder getReturnInformationUrlCC() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('TemplateID', this.order.Return_Information_Template__c);
		output.setParam('QueryId=[LineItems]a1nD0000000bCGA?pv0', get15CharsFormattedId());
		output.setParam('FP0', '1');
		output.setParam('AC0', '1');
		output.setParam('APIMode', '1');
		output.setParam('DefaultPDF', '1');
		output.setParam('UF0', '1');
		output.setParam('MFTS1', 'Return_information_generated__c');
		output.setParam('MFTSValue1', 'true');
		output.setParam('OFN', 'Return+information');
		return output;
	}

	public HttpRequestBuilder getBillOfDeliveryURLByType(String t) {
		if(t == ONRCongoComposer.FULL) {
			return this.getFullB2BBillOfDeliveryURL();
		} else if(t == ONRCongoComposer.FULL_B2C) {
			return this.getFullB2CBillOfDeliveryURL();
		} else if(t == ONRCongoComposer.PARTIAL) {
			return this.getPartialB2BBillOfDeliveryURL();
		}
		return this.getFullB2BBillOfDeliveryURL();
	}

	public HttpRequestBuilder getConfirmationEmailURL() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('CETID', this.order.Purchase_Confirmation__c);
		output.setParam('QueryId=a1n57000000vor4?pv0', get15CharsFormattedId());
		output.setParam('EmailToID', this.order.PBSI__Contact__c);
		output.setParam('EmailFromId', '0D2D0000000027T');
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			output.setParam('EmailBCC', ONRLogisticsGateway.EMAIL_CC);	
		}
		output.setParam('DS7', '2');
		output.setParam('APIMode', '12');
		return output;
	}

	public HttpRequestBuilder getShippingEmailURL() {
		HttpRequestBuilder output = this.getDefaultURL();
		output.setParam('CETID', this.order.Shipping_Confirmation_Invoice_Email_ID__c);
		output.setParam('QueryId=a1nD0000000bCGA?pv0', get15CharsFormattedId());
		output.setParam('EmailtoID', this.order.PBSI__Contact__c);
		output.setParam('EmailFromId', '0D2D0000000027T');
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			output.setParam('EmailBCC', ONRLogisticsGateway.EMAIL_CC);
		}
		output.setParam('ds7', '2');
		output.setParam('APIMode', '12');
		return output;
	}

	private String determinePDFType(Boolean isPartial) {
		if(order.RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Web_Order')) {
			return ONRCongoComposer.FULL_B2C;
		}
		if(isPartial) {
			return ONRCongoComposer.PARTIAL;
		}
		return ONRCongoComposer.FULL;
	}

	@testVisible
	private HttpRequestBuilder getDefaultURL() {
		HttpRequestBuilder output = new HttpRequestBuilderWithDuplicates('https://composer.congamerge.com/composer8/index.html', 'GET');
		output.setParam('sessionId', this.sessionId);
		output.setParam('id', get15CharsFormattedId());
		output.setParam('serverURL', 'https://'+System.URL.getSalesforceBaseURL().getHost()+'/services/Soap/u/8.0/00DM0000001XgkY');
		return output;
	}

	@testVisible
	private HttpRequestBuilder getDefaultDeliveryURL() {
		HttpRequestBuilder output = new HttpRequestBuilderWithDuplicates('https://composer.congamerge.com/composer8/index.html', 'GET');
		output.setParam('sessionId', this.sessionId);
		output.setParam('id', get15CharsFormattedId());
		output.setParam('serverURL', 'https://'+System.URL.getSalesforceBaseURL().getHost()+'/services/Soap/u/8.0/00DM0000001XgkY');
		output.setParam('DefaultPDF', '1');
		output.setParam('AC0', '1');
		output.setParam('FP0', '1');
		output.setParam('DS7', '2');
		output.setParam('APIMode', '12');
		output.setParam('EmailToId', ONRLogisticsGateway.EMAIL_TO_ID);
		if(ONRLogisticsGateway.EMAIL_CC != null) {
			output.setParam('EmailCC', ONRLogisticsGateway.EMAIL_CC);
		}
		output.setParam('EmailTemplateId', this.order.PBSI__From_Location__r.KN_Email_Template_Id__c);
		return output;
	}

	@testVisible
	private HttpRequestBuilder getFullB2CBillOfDeliveryURL() {
		HttpRequestBuilder output = this.getDefaultDeliveryURL();
		output.setParam('TemplateId', this.order.Bill_Of_Delivery_B2C_Template_ID__c);
		output.setParam('TemplateId', this.order.Return_Information_Template__c);
		output.setParam('QueryId=[LineItems]a1n57000000vor4?pv0', get15CharsFormattedId());
		output.setParam('AC1', 'Bill+of+Delivery');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('MTOFN', this.order.TransmissionIdentification__c );
		output.setParam('Zippdfs', '1');
		if(!String.isBlank(this.order.Proforma_Template_ID__c)) {
			output.setParam('TemplateId', this.order.Proforma_Template_ID__c);
		}
		return output;
	}

	@testVisible
	private HttpRequestBuilder getFullB2BBillOfDeliveryURL() {
		HttpRequestBuilder output = this.getDefaultDeliveryURL();
		output.setParam('Templateid', this.order.Bill_of_Delivery__c);
		output.setParam('ReportID=[LineItems]00OD0000005smfv?pv0', get15CharsFormattedId());
		output.setParam('AC1', 'Bill+of+Delivery+Generated+By+On+AG');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('OFN', this.order.TransmissionIdentification__c );
		return output;
	}

	@testVisible
	private HttpRequestBuilder getPartialB2BBillOfDeliveryURL() {
		HttpRequestBuilder output = this.getDefaultDeliveryURL();
		output.setParam('TemplateId', this.order.Bill_of_Delivery_Partial_Conga_ID__c);
		output.setParam('ReportID=[AlreadyDelivered]00OD0000005tU5J?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[LineItems]00OD0000005tKe8?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[LineItemsLefttoShip]00OD0000005soAF?pv0', get15CharsFormattedId());
		output.setParam('ReportID=[ShippedTotals]00OD0000005tKe9?pv0', get15CharsFormattedId());
		output.setParam('QueryId', '[AlreadyDelTot]a1nD0000000snWF,[InthisShip]a1nD0000000snWU');
		output.setParam('AC1', 'Partial+Bill+of+Delivery');
		output.setParam('Culture', this.order.Culture__c);
		output.setParam('OFN', this.order.TransmissionIdentification__c );
		return output;
	}

	@testVisible
	private String get15CharsFormattedId() {
		return shortOrderId;
	}

	private string shortOrderId {
		get {
			if(shortOrderId == null) {
				shortOrderId = String.valueOf(this.order.Id).substring(0,15);
			}
			return shortOrderId;
		}
		private set;
	}
}