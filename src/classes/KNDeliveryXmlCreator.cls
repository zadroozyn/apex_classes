public without sharing class KNDeliveryXmlCreator {
	private KN_Order order;
	private List<KN_OrderLine> packedLines;

	public KNDeliveryXmlCreator(KN_Order order) {
		this.order = order;
		this.packedLines = order.getLines();
	}

	public Dom.Document buildXml() {
		Dom.Document doc = new Dom.Document();
		Dom.XmlNode deliveryOrderExt = doc.createRootElement('DeliveryOrderExt', null, null);
		deliveryOrderExt.setNamespace('xsd','http://www.w3.org/2001/XMLSchema');
		Dom.XmlNode envelope = deliveryOrderExt.addChildElement('Envelope', null, null);
		envelope.addChildElement('SenderIdentification', null, null).addTextNode('CHZRH62');
		envelope.addChildElement('ReceiverIdentification', null, null).addTextNode(this.normalize(order.getReceiverIdentification()));
		envelope.addChildElement('MessageType', null, null).addTextNode('WHSORDER');
		envelope.addChildElement('MessageVersion', null, null).addTextNode('03.20');
		envelope.addChildElement('EnvelopeIdentification', null, null).addTextNode(this.normalize(order.getEnvelopeIdentification()));
		Dom.XmlNode tdt = envelope.addChildElement('TransmissionDateTime', null, null);
		tdt.addChildElement('Date', null, null).addTextNode(DateTime.now().format('yyyy-MM-dd'));
		tdt.addChildElement('Time', null, null).addTextNode(DateTime.now().format('HH:mm:ssXXX'));
		Dom.XmlNode msg = deliveryOrderExt.addChildElement('Message', null, null);
		Dom.XmlNode header = msg.addChildElement('Header', null, null);
		this.buildOrderInformation(header.addChildElement('OrderInformation', null, null));
		this.writeInstructions(header);
		this.buildPartyInformation(header.addChildElement('PartyInformation', null, null));
		this.buildLines(msg);
		return doc;
	}

	private void buildOrderInformation(Dom.XmlNode orderInfo) {
		orderInfo.addChildElement('ClientNumber', null, null).addTextNode(this.normalize(order.getClientNumber()));
		orderInfo.addChildElement('ClientOrderReference', null, null).addTextNode(this.normalize(order.getClientOrderReference()));
		orderInfo.addChildElement('Depot', null, null).addTextNode(this.normalize(order.getDepot()));
		orderInfo.addChildElement('ConsigneeCustomerNumber', null, null).addTextNode(this.normalize(order.getConsigneeCustomerNumber()));
		orderInfo.addChildElement('ConsigneeOrderNumber', null, null).addTextNode(this.normalize(order.getConsigneeOrderNumber()));
		orderInfo.addChildElement('OrderType', null, null).addTextNode(order.getOrderType());
		orderInfo.addChildElement('ServiceLevel', null, null).addTextNode(order.getServiceLevel());
		orderInfo.addChildElement('ServiceType', null, null).addTextNode('1');
		Dom.XmlNode rsdt = orderInfo.addChildElement('RequestedStartDateTime', null, null);
		rsdt.addChildElement('Date', null, null).addTextNode(DateTime.now().format('yyyy-MM-dd'));
		rsdt.addChildElement('Time', null, null).addTextNode(DateTime.now().format('HH:mm:ssXXX'));
		Dom.XmlNode rcdt = orderInfo.addChildElement('RequestedCompletionDateTime', null, null);
		rcdt.addChildElement('Date', null, null).addTextNode(DateTime.now().format('yyyy-MM-dd'));
		rcdt.addChildElement('Time', null, null).addTextNode(DateTime.now().format('HH:mm:ssXXX'));
		orderInfo.addChildElement('TieInReference', null, null).addTextNode(order.getTieInReference());
		orderInfo.addChildElement('BondedOrder', null, null).addTextNode('0');
		orderInfo.addChildElement('TransitOrder', null, null).addTextNode('0');
		orderInfo.addChildElement('ModeOfTransport', null, null).addTextNode('1');
		orderInfo.addChildElement('CarrierID', null, null).addTextNode('');
		orderInfo.addChildElement('Taxed', null, null).addTextNode('0');
		orderInfo.addChildElement('DeliveryTerms', null, null).addTextNode('');
		orderInfo.addChildElement('PartShipmentsAllowed', null, null).addTextNode('0');
		orderInfo.addChildElement('ConsigneePreAdvice', null, null).addTextNode('0');
		orderInfo.addChildElement('DeliveryDateFixed', null, null).addTextNode('0');
		orderInfo.addChildElement('ClientContactDetails', null, null).addTextNode(this.normalize(order.getClientContactDetails()));
		orderInfo.addChildElement('RouteCode', null, null).addTextNode('');
		orderInfo.addChildElement('ShipCode', null, null).addTextNode(this.normalize(order.getShipCode()));
	}
		

	private void buildLines(Dom.XmlNode msg) {
		for(Integer i = 0; i < packedLines.size(); i++) {
			Dom.XmlNode lineInfo = msg.addChildElement('Line', null, null).addChildElement('LineInformation', null, null);
			lineInfo.addChildElement('LineItemID', null, null).addTextNode(String.valueOf(i+1));
			lineInfo.addChildElement('LineType', null, null).addTextNode('1');
			lineInfo.addChildElement('ArticleID', null, null).addTextNode(this.normalize(packedLines[i].getArticleID()).left(20));
			lineInfo.addChildElement('ArticleDescription1', null, null)
				.addTextNode(this.normalize(packedLines[i].getArticleDescription()).left(35));
			lineInfo.addChildElement('ArticleDescription2', null, null).addTextNode(this.normalize(packedLines[i].getArticleEAN()).left(35));
			lineInfo.addChildElement('ArticleReference1', null, null).addTextNode('');
			lineInfo.addChildElement('ArticleReference2', null, null).addTextNode('');
			lineInfo.addChildElement('ArticleReference3', null, null).addTextNode('');
			lineInfo.addChildElement('StockStatusCode', null, null).addTextNode('');
			Dom.XmlNode quantity = lineInfo.addChildElement('Quantity', null, null);
			quantity.addChildElement('QuantityValue', null, null).addTextNode(String.valueOf(Integer.valueOf(packedLines[i].getQuantity())));
			quantity.addChildElement('UOM', null, null).addTextNode(packedLines[i].getUOM());
			lineInfo.addChildElement('ConsignmentNumber', null, null).addTextNode('');
			lineInfo.addChildElement('CaptureSerialNumbersFlag', null, null).addTextNode('0');
			lineInfo.addChildElement('BondedFlag', null, null).addTextNode('0');
			lineInfo.addChildElement('TaxedFlag', null, null).addTextNode('0');
			lineInfo.addChildElement('VATCode', null, null).addTextNode('');
			lineInfo.addChildElement('ExternalCaseNumber', null, null).addTextNode('');
			lineInfo.addChildElement('CountryOfOrigin', null, null).addTextNode('CH');

		}
	}

	private void buildPartyInformation(Dom.XmlNode partyInfo) {
		partyInfo.addChildElement('AddressType', null, null).addTextNode('CN');
		partyInfo.addChildElement('PartyName', null, null).addTextNode(this.normalize(order.getDeliveryCompany()).left(35));
		partyInfo.addChildElement('PartyName_2', null, null).addTextNode(this.normalize(order.getDeliveryATTN()).left(35));
		String street = this.normalize(order.getStreetLine1());
		if(String.isNotBlank(order.getStreetLine2())) {
			street += ' ' + this.normalize(order.getStreetLine2());
		}
		String street2;
		if(street.length() > 35) {
			street2 = street.substring(35, street.length());
		}
		partyInfo.addChildElement('StreetPOBox', null, null).addTextNode(this.normalize(street).left(35));
		partyInfo.addChildElement('Street_2', null, null).addTextNode(this.normalize(street2).left(35));
		partyInfo.addChildElement('PostalArea', null, null).addTextNode(this.normalize(order.getDeliveryState()).left(35).toUpperCase());
		partyInfo.addChildElement('City', null, null).addTextNode(this.normalize(order.getDeliveryCity()).left(35));
		partyInfo.addChildElement('ZIPCode', null, null).addTextNode(this.normalize(order.getDeliveryZIPCode()).left(9).toUpperCase());
		partyInfo.addChildElement('State', null, null).addTextNode('');
		partyInfo.addChildElement('CountryCode', null, null).addTextNode(order.getDeliveryCountryCode());
		partyInfo.addChildElement('KNAddressID', null, null).addTextNode('');
		partyInfo.addChildElement('VATNumber', null, null).addTextNode('');
		partyInfo.addChildElement('TaxExemptNumber', null, null).addTextNode('');
		partyInfo.addChildElement('PhoneNumber', null, null).addTextNode(this.normalize(order.getDeliveryPhone()));
		partyInfo.addChildElement('AlternatePhoneNumber', null, null).addTextNode(this.normalize(order.getDeliveryPhoneAlternate()));
		partyInfo.addChildElement('FaxNumber', null, null).addTextNode('');
		partyInfo.addChildElement('EmailAddress', null, null).addTextNode(this.normalize(order.getDeliveryEmailAddress()));
	}

	private void writeInstructions(Dom.XmlNode header) {
		if(String.isNotBlank(order.getPackingInstructions())) {
			this.writeInstruction(header, '', this.splitString(this.normalize(order.getPackingInstructions()), 75));
		}
		if(String.isNotBlank(order.getDeliveryInstructions())) {
			this.writeInstruction(header, 'DELTXT', this.splitString(this.normalize(order.getDeliveryInstructions()), 75));
		}
	}

	private void writeInstruction(Dom.XmlNode header, String qualifier, List<String> msg) {
		Dom.XmlNode root = header.addChildElement('FreeTextInformation', null, null);
		if(msg.size() == 1) {
			root.addChildElement('TextQualifier', null, null).addTextNode(qualifier);
			root.addChildElement('FreeText', null, null).addTextNode(msg[0]);
		} else {
			for(Integer i = 0; i < msg.size(); i++) {
				root.addChildElement('InstructionLine', null, null).addTextNode(i + 1 + '0');
				root.addChildElement('TextQualifier', null, null).addTextNode(qualifier);
				root.addChildElement('FreeText', null, null).addTextNode(msg[i]);
			}
		}
	}

	private List<String> splitString(String text, Integer length) {
		List<String> output = new List<String>();
		for(Integer i = 0; i < text.length(); i+=length) {
			output.add(text.subString(i, text.length() > i+length ? i+length : text.length()));
		}
		return output;
	}

	private String normalize(String text) {
		if(String.isBlank(text)) {
			return '';
		}
		return text.replaceAll('(\n|\r)', ' ').normalizeSpace();
	}

}