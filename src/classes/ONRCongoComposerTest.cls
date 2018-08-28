@isTest
private class ONRCongoComposerTest {

	@testSetup
	static void setup() {
		new TestCustomSettingsFactory();

		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('CH-Stock', false);
		tdf.locations.createSObject('EU-Stock Web', false);
		tdf.locations.createSObject('US-Stock', false);
		tdf.locations.createSObject('CA-Stock', false);
		tdf.locations.createSObject('JP-Stock', false);
		tdf.locations.insertAll();
		tdf.paymentTerms.createSObject('Test', 7, false);
		tdf.paymentTerms.insertAll();
		tdf.accounts.createSObject('Test_account', 'CHF', false);

		tdf.accounts.getSObject('Test_account').put('On_Payment_Term__c', tdf.paymentTerms.getSObjectId('Test'));
		tdf.accounts.insertAll();

		PBSI__PBSI_Sales_Order__c so1 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('EU-Stock'), false);
		PBSI__PBSI_Sales_Order__c so2 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('EU-Stock Web'), false);
		PBSI__PBSI_Sales_Order__c so3 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('US-Stock'), false);
		PBSI__PBSI_Sales_Order__c so4 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('CA-Stock'), false);
		PBSI__PBSI_Sales_Order__c so5 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('JP-Stock'), false);
		PBSI__PBSI_Sales_Order__c so6 = tdf.salesOrders
			.createSObject(tdf.accounts.getSObjectId('Test_account'), 'Re-order', tdf.locations.getSObjectId('CH-Stock'), false);

		so1.PBSI__BillingCountry__c = 'BC';
		so1.PBSI__Delivery_Country__c = 'Norway';
		so2.PBSI__BillingCountry__c = 'BC';
		so2.PBSI__Delivery_Country__c = 'Germany';
		so3.PBSI__BillingCountry__c = 'BC';
		so3.PBSI__Delivery_Country__c = 'Canada';
		so4.PBSI__BillingCountry__c = 'BC';
		so4.PBSI__Delivery_Country__c = 'United States';
		so5.PBSI__BillingCountry__c = 'BC';
		so5.PBSI__Delivery_Country__c = 'Japan';

		tdf.salesOrders.insertAll();

		tdf.itemGroups.createSObject('Cloud','9', 'CHF', 'Cloud', null, true);

		tdf.items.createSObject('Cloud 9.0000', 20, 200, 'Cloud', tdf.locations.getSObjectId('EU-Stock'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.createSObject('Cloudsurfer 10.0000', 20, 200, 'Cloud', tdf.locations.getSObjectId('EU-Stock'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.createSObject('Cloud 9.0001', 20, 200, 'Cloud', tdf.locations.getSObjectId('EU-Stock Web'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.createSObject('Cloud 9.0002', 20, 200, 'Cloud', tdf.locations.getSObjectId('US-Stock'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.createSObject('Cloud 9.0003', 20, 200, 'Cloud', tdf.locations.getSObjectId('CA-Stock'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.createSObject('Cloud 9.0004', 20, 200, 'Cloud', tdf.locations.getSObjectId('JP-Stock'), tdf.itemGroups.getSObjectId('Cloud'), '123', false);
		tdf.items.insertAll();

		tdf.salesOrderLines.createSObject(so1.Id, tdf.items.getSObjectId('Cloud 9.0000'), 10, 0, false);
		tdf.salesOrderLines.createSObject(so1.Id, tdf.items.getSObjectId('Cloudsurfer 10.0000'), 10, 10, false);

		tdf.salesOrderLines.createSObject(so1.Id, tdf.items.getSObjectId('Cloud 9.0001'), 10, 0, false);
		tdf.salesOrderLines.insertAll();
	}

	@isTest
	static void testFullb2cBodUrlCC() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('CH-Stock'))[0];
		order.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order');
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getBodBuilder();
		String expectedValue = cc.getDefaultUrl().getRequest().getEndpoint() +
			+ '&Templateid=' + order.Bill_Of_Delivery_B2C_Template_ID__c
			+ '&QueryId=[LineItems]a1n57000000vor4?pv0=' + cc.get15CharsFormattedId()
			+ '&AC0=' + '1'
			+ '&AC1=' + 'Bill+of+Delivery+Generated+By+On+AG'
			+ '&Culture=' + order.Culture__c
			+ '&OFN=' + 'Bill+of+Delivery'
			+ '&FP0=' + '1'
			+ '&DS7=' + '13'
			+ '&APIMode=' + '1'
			+ '&UF0=' + '1'
			+ '&MFTS1=' + 'BoD_Generated__c'
			+ '&MFTSValue1=' + 'true';
		System.assertEquals(expectedValue, builder.getRequest().getEndpoint());
	}

	@isTest
	static void testReturnInformationUrlCC() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('CH-Stock'))[0];
		order.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order');
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getReturnInformationUrlCC();
		String expectedValue = cc.getDefaultUrl().getRequest().getEndpoint() +
		+ '&TemplateID=' + order.Return_Information_Template__c
		+ '&QueryId=[LineItems]a1nD0000000bCGA?pv0=' + cc.get15CharsFormattedId()
		+ '&FP0=1'
		+ '&AC0=1'
		+ '&APIMode=1'
		+ '&DefaultPDF=1'
		+ '&UF0=1'
		+ '&MFTS1=Return_information_generated__c'
		+ '&MFTSValue1=true'
		+ '&OFN=Return+information';
		System.assertEquals(expectedValue, builder.getRequest().getEndpoint());
	}

	@isTest
	static void getFullB2BBillOfDeliveryURLCC() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('CH-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getBodBuilder();
		String expectedValue = cc.getDefaultUrl().getRequest().getEndpoint() +
			+ '&TemplateId=' + order.Bill_of_Delivery__c
			+ '&ReportID=[LineItems]00OD0000005smfv?pv0=' + cc.get15CharsFormattedId()
			+ '&AC0=1'
			+ '&AC1=Bill+of+Delivery+Generated+By+On+AG'
			+ '&Culture=' + order.Culture__c
			+ '&OFN=Bill+of+Delivery'
			+ '&FP0=1'
			+ '&DS7=13'
			+ '&APIMode=1'
			+ '&UF0=1'
			+ '&MFTS1=BoD_Generated__c'
			+ '&MFTSValue1=true';
		builder = cc.getBodBuilder();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void getPartialBillOfDeliveryURLCC() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('CH-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, true, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getBodBuilder();
		String expectedValue = cc.getDefaultUrl().getRequest().getEndpoint() +
			+ '&TemplateId=' + order.Bill_of_Delivery_Partial_Conga_ID__c
			+ '&ReportID=[AlreadyDelivered]00OD0000005tU5J?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[LineItems]00OD0000005tKe8?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[LineItemsLefttoShip]00OD0000005soAF?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[ShippedTotals]00OD0000005tKe9?pv0=' + cc.get15CharsFormattedId()
			+ '&QueryId=[AlreadyDelTot]a1nD0000000snWF,[InthisShip]a1nD0000000snWU'
			+ '&AC0=1'
			+ '&AC1=Partial+Bill+of+Delivery'
			+ '&Culture=' + order.Culture__c
			+ '&OFN=Bill+of+Delivery' 
			+ '&SC0=1'
			+ '&FP0=1'
			+ '&DS7=13'
			+ '&APIMode=1'
			+ '&UF0=1'
			+ '&MFTS1=BoD_Generated__c'
			+ '&MFTSValue1=true';
		builder = cc.getBodBuilder();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void testGetDefaultURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('JP-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultURL();
		String expectedValue = 'https://composer.congamerge.com/composer8/index.html?sessionId='
			+ UserInfo.getSessionId() + '&id=' + cc.get15CharsFormattedId() + '&serverURL=https://'
			+ System.URL.getSalesforceBaseURL().getHost()+'/services/Soap/u/8.0/00DM0000001XgkY';
		System.assertEquals(expectedValue, builder.getRequest().getEndpoint());
	}

	@isTest
	static void testGetDefaultDeliveryURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('JP-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultDeliveryURL();
		String expectedValue = 'https://composer.congamerge.com/composer8/index.html'
			+ '?sessionId=' + UserInfo.getSessionId()
			+ '&id=' + cc.get15CharsFormattedId()
			+ '&serverURL=https://' + System.URL.getSalesforceBaseURL().getHost() + '/services/Soap/u/8.0/00DM0000001XgkY'
			+ '&DefaultPDF=1'
			+ '&AC0=1'
			+ '&FP0=1'
			+ '&DS7=2'
			+ '&APIMode=12'
			+ '&EmailToId=' + ONRLogisticsGateway.EMAIL_TO_ID
			+ '&EmailCC=' + ONRLogisticsGateway.EMAIL_CC
			+ '&EmailTemplateId=' + order.PBSI__From_Location__r.KN_Email_Template_Id__c;
		System.assertEquals(expectedValue, builder.getRequest().getEndpoint());
	}

	@isTest
	static void testDeterminePDFTypeFull() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('JP-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		System.assertEquals(ONRCongoComposer.Full, cc.pdfType);
	}

	@isTest
	static void testDeterminePDFTypePartial() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		List<PBSI__Shipped_Sales_Order_Line__c> shippedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		ONRCongoComposer cc = new ONRCongoComposer(order, true, UserInfo.getSessionId());
		System.assertEquals(ONRCongoComposer.Partial, cc.pdfType);
	}

	@isTest
	static void getFullB2CBillOfDeliveryURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		order.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order');
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultDeliveryURL();
		String expectedValue = builder.getRequest().getEndpoint()
			+ '&TemplateId=' + order.Bill_Of_Delivery_B2C_Template_ID__c
			+ '&TemplateId=' + order.Return_Information_Template__c
			+ '&QueryId=[LineItems]a1n57000000vor4?pv0=' + cc.get15CharsFormattedId()
			+ '&AC1=Bill+of+Delivery'
			+ '&Culture=' + order.Culture__c
			+ '&MTOFN=' + order.TransmissionIdentification__c
			+ '&Zippdfs=1';
		builder = cc.getBodBuilder();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void getFullB2BBillOfDeliveryURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultDeliveryURL();
		String expectedValue = builder.getRequest().getEndpoint()
			+ '&TemplateId=' + order.Bill_of_Delivery__c
			+ '&ReportID=[LineItems]00OD0000005smfv?pv0=' + cc.get15CharsFormattedId()
			+ '&AC1=Bill+of+Delivery+Generated+By+On+AG'
			+ '&Culture=' + order.Culture__c
			+ '&OFN=' + order.TransmissionIdentification__c;
		builder = cc.getBodBuilder();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void getPartialBillOfDeliveryURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, true, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultDeliveryURL();
		String expectedValue = builder.getRequest().getEndpoint()
			+ '&TemplateId=' + order.Bill_of_Delivery_Partial_Conga_ID__c
			+ '&ReportID=[AlreadyDelivered]00OD0000005tU5J?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[LineItems]00OD0000005tKe8?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[LineItemsLefttoShip]00OD0000005soAF?pv0=' + cc.get15CharsFormattedId()
			+ '&ReportID=[ShippedTotals]00OD0000005tKe9?pv0=' + cc.get15CharsFormattedId()
			+ '&QueryId=[AlreadyDelTot]a1nD0000000snWF,[InthisShip]a1nD0000000snWU'
			+ '&AC1=Partial+Bill+of+Delivery'
			+ '&Culture=' + order.Culture__c
			+ '&OFN=' + order.TransmissionIdentification__c;
		builder = cc.getBodBuilder();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void testGetConfirmationEmailURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultURL();
		String expectedValue = builder.getRequest().getEndpoint()
			+ '&CETID=' + order.Purchase_Confirmation__c
			+ '&QueryId=a1n57000000vor4?pv0=' + cc.get15CharsFormattedId()
			+ '&EmailToId=' + order.PBSI__Contact__r.Id
			+ '&EmailFromId=0D2D0000000027T'
			+ '&EmailBCC=' + ONRLogisticsGateway.EMAIL_CC
			+ '&DS7=2'
			+ '&APIMode=12';
		builder = cc.getConfirmationEmailURL();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void getShippingEmailURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, UserInfo.getSessionId());
		HttpRequestBuilder builder = cc.getDefaultURL();
		String expectedValue = builder.getRequest().getEndpoint()
			+ '&CETID=' + order.Shipping_Confirmation_Invoice_Email_ID__c
			+ '&QueryId=a1nD0000000bCGA?pv0=' + cc.get15CharsFormattedId()
			+ '&EmailToId=' + order.PBSI__Contact__r.Id
			+ '&EmailFromId=0D2D0000000027T'
			+ '&EmailBCC=' + ONRLogisticsGateway.EMAIL_CC
			+ '&DS7=2'
			+ '&APIMode=12';
		builder = cc.getShippingEmailURL();
		System.assert(builder.getRequest().getEndpoint() == expectedValue);
	}

	@isTest
	static void testGetBillOfDeliveryURLByType() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		ONRCongoComposer cc = new ONRCongoComposer(order, false, UserInfo.getSessionId());
		System.assert(cc.getFullB2BBillOfDeliveryURL().getRequest().getEndpoint() == cc.getBillOfDeliveryURLByType(ONRCongoComposer.FULL).getRequest().getEndpoint());
		System.assert(cc.getFullB2CBillOfDeliveryURL().getRequest().getEndpoint() == cc.getBillOfDeliveryURLByType(ONRCongoComposer.FULL_B2C).getRequest().getEndpoint());
		System.assert(cc.getPartialB2BBillOfDeliveryURL().getRequest().getEndpoint() == cc.getBillOfDeliveryURLByType(ONRCongoComposer.PARTIAL).getRequest().getEndpoint());
	}
}