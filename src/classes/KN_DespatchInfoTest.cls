@isTest
private class KN_DespatchInfoTest {

	private static String ORDER_NUMBER_PLACEHOLDER = '[ORDER_NUMBER_PLACEHOLDER]';
	private static String ORDER_REFERENCE_PLACEHOLDER = '[ORDER_REFERENCE_PLACEHOLDER]';
	
	@isTest static void salesOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c so = 
			[SELECT Id,Name FROM PBSI__PBSI_Sales_Order__c where Id = :tdf.salesOrders.getAllSobjects()[0].Id];
		String requestXML = templateXML;
		requestXML = requestXML.replace(ORDER_NUMBER_PLACEHOLDER,so.Name);
		requestXML = requestXML.replace(ORDER_REFERENCE_PLACEHOLDER,so.Name+'-0');
		System.debug(requestXML);
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.httpMethod = 'POST';
		req.requestBody = 
			Blob.valueOf(requestXML);
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
			KN_DespatchInfo.create();
		Test.stopTest();
		System.assertEquals(2, [SELECT count() FROM Tracking_Number__c]);
		System.assertEquals(1, [SELECT count() FROM Tracking__c]);
		System.assertEquals(1, [SELECT count() FROM Attachment]);
		System.assertEquals(3, [SELECT count() FROM Tracking_Number_Item__c]);
		for(Tracking_Number_Item__c trackingItem: [SELECT Id,Quantity__c,Item__c,Description__c 
			FROM Tracking_Number_Item__c]) {
			System.assertNotEquals(null, trackingItem.Quantity__c);
			System.assertNotEquals(0, trackingItem.Quantity__c);
			System.assertNotEquals(null, trackingItem.Item__c);
			System.assertNotEquals(null, trackingItem.Description__c);
		}
	}
	
	@isTest static void transferOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__Transfer_Order__c to = 
			[SELECT Id,Name FROM PBSI__Transfer_Order__c where Id = :tdf.transferOrders.getAllSobjects()[0].Id];
		String requestXML = templateXML;
		requestXML = requestXML.replace(ORDER_NUMBER_PLACEHOLDER,to.Name);
		requestXML = requestXML.replace(ORDER_REFERENCE_PLACEHOLDER,to.Name+'-0');
		System.debug(requestXML);
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.httpMethod = 'POST';
		req.requestBody = 
			Blob.valueOf(requestXML);
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
			KN_DespatchInfo.create();
		Test.stopTest();
		System.assertEquals(2, [SELECT count() FROM Tracking_Number__c]);
		System.assertEquals(1, [SELECT count() FROM Tracking__c]);
		System.assertEquals(1, [SELECT count() FROM Attachment]);
		System.assertEquals(3, [SELECT count() FROM Tracking_Number_Item__c]);
		for(Tracking_Number_Item__c trackingItem: [SELECT Id,Quantity__c,Item__c,Description__c 
			FROM Tracking_Number_Item__c]) {
			System.assertNotEquals(null, trackingItem.Quantity__c);
			System.assertNotEquals(0, trackingItem.Quantity__c);
			System.assertNotEquals(null, trackingItem.Item__c);
			System.assertNotEquals(null, trackingItem.Description__c);
		}
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();

		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('EU-Stock Web', false);
		tdf.locations.getAllSobjects()[1].put('PBSI__Country__c','Germany');
		tdf.locations.createSObject('Transit location', true, false);
		tdf.locations.createSObject('CH-Stock', true, false);
		tdf.locations.createSObject('CH-Stock Web', true, false);
		tdf.locations.insertAll();
		tdf.paymentTerms.createSObject('Test', 7, false);
		tdf.paymentTerms.insertAll();
		tdf.accounts.createSObject('Test_account', 'CHF', false);

		tdf.accounts.getSObject('Test_account').put('On_Payment_Term__c', tdf.paymentTerms.getSObjectId('Test'));
		tdf.accounts.insertAll();

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		PBSI__Transfer_Order__c to1 = tdf.transferOrders.createSObject(
			tdf.locations.getAllSobjects()[0].Id,
			tdf.locations.getAllSobjects()[1].Id,
			tdf.locations.getAllSobjects()[2].Id,
			false
		);
		to1.Country__c = 'Germany';
		insert to1;
		Order_Stage__c osTO = new Order_Stage__c(
			Transfer_Order__c = to1.Id,
			RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c','Notification_TO')
		);
		insert osTO;

		SObject so = tdf.salesOrders.createSObject(
			tdf.accounts.getSObject('Test_account').Id,
			'Re-Order',
			tdf.locations.getAllSobjects()[0].Id,
			true

		);
		Order_Stage__c osSO = new Order_Stage__c(
			Sales_Order__c = so.Id,
			RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c','Notification_SO')
		);
		insert osSO;		

		insert new pw_ccpro__CountryObject__c(
			Name = 'Germany',
			pw_ccpro__IsoCode_2__c = 'DE',
			pw_ccpro__IsoCode_3__c = 'DEM'
		);

		tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getAllSobjects()[0].Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7630040505864', true);
		tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', tdf.locations.getAllSobjects()[0].Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7630040500937', true);
		tdf.items.createSObject('4.4102 W 7.5', 100, 120, 'test desc', tdf.locations.getAllSobjects()[0].Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7630040500715', true);
	}
	

	private static String templateXML ='<?xml version="1.0" encoding="UTF-8"?>'+
'<DespatchConfirmationExt xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
'<Envelope>'+
'<SenderIdentification>LUCTN04</SenderIdentification>'+
'<ReceiverIdentification>CHZRH62</ReceiverIdentification>'+
'<MessageType>SHIPCONF</MessageType>'+
'<MessageVersion>03.20</MessageVersion>'+
'<EnvelopeIdentification>XXXXXXXXXXXXX</EnvelopeIdentification>'+
'<TransmissionDateTime>'+
'<Date>2018-05-24</Date>'+
'<Time>1:00:24Z</Time>'+
'</TransmissionDateTime>'+
'</Envelope>'+
'<Message>'+
'<Header>'+
'<OrderInformation>'+
'<ClientNumber>OAG</ClientNumber>'+
'<ClientOrderReference>[ORDER_REFERENCE_PLACEHOLDER]</ClientOrderReference>'+
'<MovementOrderNumber>2682787</MovementOrderNumber>'+
'<Depot>LDC</Depot>'+
'<ConsigneeCustomerNumber>217338</ConsigneeCustomerNumber>'+
'<ConsigneeOrderNumber>[ORDER_NUMBER_PLACEHOLDER]</ConsigneeOrderNumber>'+
'<OrderType>OAO</OrderType>'+
'<ServiceLevel>01</ServiceLevel>'+
'<ServiceType>1</ServiceType>'+
'<RequestedStartDateTime>'+
'<Date>2018-05-22</Date>'+
'<Time>2:26:00Z</Time>'+
'</RequestedStartDateTime>'+
'<RequestedCompletionDateTime>'+
'<Date>2018-05-22</Date>'+
'<Time>2:26:00Z</Time>'+
'</RequestedCompletionDateTime>'+
'<TieInReference>B2B</TieInReference>'+
'<ModeOfTransport>1</ModeOfTransport>'+
'<CarrierID>UPS</CarrierID>'+
'<OrderedBy/>'+
'<CarrierReference/>'+
'<DeliveryTerms>DDP</DeliveryTerms>'+
'<DeliveryTermsLocation/>'+
'<LastUpdate>'+
'<Date>2018-05-24</Date>'+
'<Time>1:00:13Z</Time>'+
'</LastUpdate>'+
'</OrderInformation>'+
'<ShippingUnitInformation>'+
'<ShippingUnitID>40349844023392970</ShippingUnitID>'+
'<CaseWeightActual>'+
'<Value>7.1000</Value>'+
'<UOM>KGS</UOM>'+
'</CaseWeightActual>'+
'<CaseVolumeActual>'+
'<Value>0.09000</Value>'+
'<UOM>MTQ</UOM>'+
'</CaseVolumeActual>'+
'<CaseDimensions>'+
'<Length>0.350</Length>'+
'<Width>0.350</Width>'+
'<Height>0.350</Height>'+
'<UOM>MTR</UOM>'+
'</CaseDimensions>'+
'<PackageType>CART</PackageType>'+
'<AdditionalID>1Z3XR0946860000085</AdditionalID>'+
'</ShippingUnitInformation>'+
'<ShippingUnitInformation>'+
'<ShippingUnitID>40349844023392963</ShippingUnitID>'+
'<CaseWeightActual>'+
'<Value>38.0000</Value>'+
'<UOM>KGS</UOM>'+
'</CaseWeightActual>'+
'<CaseVolumeActual>'+
'<Value>0.36100</Value>'+
'<UOM>MTQ</UOM>'+
'</CaseVolumeActual>'+
'<CaseDimensions>'+
'<Length>0.350</Length>'+
'<Width>0.350</Width>'+
'<Height>0.350</Height>'+
'<UOM>MTR</UOM>'+
'</CaseDimensions>'+
'<PackageType>CART</PackageType>'+
'<AdditionalID>1Z3XR0946860000094</AdditionalID>'+
'</ShippingUnitInformation>'+
'<PartyInformation>'+
'<AddressType>WH</AddressType>'+
'<PartyName>Kuehne + Nagel S.ar.l</PartyName>'+
'<StreetPOBox>1, rue Edmond Reuter</StreetPOBox>'+
'<City>Contern</City>'+
'<ZIPCode>5326</ZIPCode>'+
'<PostalArea>TST</PostalArea>'+
'<CountryCode>LU</CountryCode>'+
'</PartyInformation>'+
'<PartyInformation>'+
'<AddressType>CN</AddressType>'+
'<PartyName>Trakks Gent</PartyName>'+
'<StreetPOBox>Poortakkerstraat 15</StreetPOBox>'+
'<City>Sint-Denijs-Westrem</City>'+
'<ZIPCode>B-9501</ZIPCode>'+
'<CountryCode>BE</CountryCode>'+
'<EmailAddress>issa@on-running.com</EmailAddress>'+
'</PartyInformation>'+
'<TransportInformation/>'+
'<InvoiceInformation>'+
'<CountryOfShipment/>'+
'<InvoiceNumber/>'+
'</InvoiceInformation>'+
'<StatusInformation>'+
'<StatusCode>2369</StatusCode>'+
'<StatusDateTime>'+
'<Date>2018-05-24</Date>'+
'<Time>1:02:28Z</Time>'+
'</StatusDateTime>'+
'<StatusCreationBy>LUXFWMW</StatusCreationBy>'+
'</StatusInformation>'+
'</Header>'+
'<Line>'+
'<LineInformation>'+
'<LineItemID>1</LineItemID>'+
'<LineType>1</LineType>'+
'<ItemType>SHO</ItemType>'+
'<ArticleClient>OAG</ArticleClient>'+
'<ArticleID>4.4102 W 6.5</ArticleID>'+
'<ArticleDescription1>Cloudflow Black / White W 8</ArticleDescription1>'+
'<ArticleDescription2>7630040505864</ArticleDescription2>'+
'<StockStatusCode>GOO</StockStatusCode>'+
'<Quantity>'+
'<QuantityValue>33</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<QuantityDelivered>'+
'<QuantityValue>33</QuantityValue>'+
'<UOM>EA</UOM>'+
'</QuantityDelivered>'+
'<ConsignmentNumber/>'+
'<CaptureSerialNumbersFlag>0</CaptureSerialNumbersFlag>'+
'<BondedFlag>0</BondedFlag>'+
'<TaxedFlag>0</TaxedFlag>'+
'<VATCode>Z</VATCode>'+
'<OrderPricePerQuantity>00000</OrderPricePerQuantity>'+
'<VATRate>0.00</VATRate>'+
'</LineInformation>'+
'<SubtotalsInformation>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>33</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<Goods_Item_Description/>'+
'<GoodsItemInformation>'+
'<GoodsItemNumber> 111977677</GoodsItemNumber>'+
'<CaseNumber>LDC268278600010</CaseNumber>'+
'<CaseWeightActual>'+
'<Value>60.0000</Value>'+
'<UOM>KGS</UOM>'+
'</CaseWeightActual>'+
'<CaseVolumeActual>'+
'<Value>0.35500</Value>'+
'<UOM>MTQ</UOM>'+
'</CaseVolumeActual>'+
'<BondedFlag>0</BondedFlag>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>33</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<TaxedFlag>0</TaxedFlag>'+
'<MasterCaseNumber>40349844023392963</MasterCaseNumber>'+
'</GoodsItemInformation>'+
'</SubtotalsInformation>'+
'</Line>'+
'<Line>'+
'<LineInformation>'+
'<LineItemID>2</LineItemID>'+
'<LineType>1</LineType>'+
'<ItemType>APP</ItemType>'+
'<ArticleClient>OAG</ArticleClient>'+
'<ArticleID>4.4102 W 7</ArticleID>'+
'<ArticleDescription1>Weather-Shirt W Storm Navy W M</ArticleDescription1>'+
'<ArticleDescription2>7630040500937</ArticleDescription2>'+
'<StockStatusCode>GOO</StockStatusCode>'+
'<Quantity>'+
'<QuantityValue>6</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<QuantityDelivered>'+
'<QuantityValue>6</QuantityValue>'+
'<UOM>EA</UOM>'+
'</QuantityDelivered>'+
'<ConsignmentNumber/>'+
'<CaptureSerialNumbersFlag>0</CaptureSerialNumbersFlag>'+
'<BondedFlag>0</BondedFlag>'+
'<TaxedFlag>0</TaxedFlag>'+
'<VATCode>Z</VATCode>'+
'<OrderPricePerQuantity>00000</OrderPricePerQuantity>'+
'<VATRate>0.00</VATRate>'+
'</LineInformation>'+
'<SubtotalsInformation>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>6</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<Goods_Item_Description/>'+
'<GoodsItemInformation>'+
'<GoodsItemNumber> 111977678</GoodsItemNumber>'+
'<CaseNumber>LDC268278600020</CaseNumber>'+
'<CaseWeightActual>'+
'<Value>6.4400</Value>'+
'<UOM>KGS</UOM>'+
'</CaseWeightActual>'+
'<CaseVolumeActual>'+
'<Value>0.04500</Value>'+
'<UOM>MTQ</UOM>'+
'</CaseVolumeActual>'+
'<BondedFlag>0</BondedFlag>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>6</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<TaxedFlag>0</TaxedFlag>'+
'<MasterCaseNumber>40349844023392970</MasterCaseNumber>'+
'</GoodsItemInformation>'+
'</SubtotalsInformation>'+
'</Line>'+
'<Line>'+
'<LineInformation>'+
'<LineItemID>3</LineItemID>'+
'<LineType>1</LineType>'+
'<ItemType>APP</ItemType>'+
'<ArticleClient>OAG</ArticleClient>'+
'<ArticleID>4.4102 W 7.5</ArticleID>'+
'<ArticleDescription1>Comfort-T W Grey W XS</ArticleDescription1>'+
'<ArticleDescription2>7630040500715</ArticleDescription2>'+
'<StockStatusCode>GOO</StockStatusCode>'+
'<Quantity>'+
'<QuantityValue>12</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<QuantityDelivered>'+
'<QuantityValue>12</QuantityValue>'+
'<UOM>EA</UOM>'+
'</QuantityDelivered>'+
'<ConsignmentNumber/>'+
'<CaptureSerialNumbersFlag>0</CaptureSerialNumbersFlag>'+
'<BondedFlag>0</BondedFlag>'+
'<TaxedFlag>0</TaxedFlag>'+
'<VATCode>Z</VATCode>'+
'<OrderPricePerQuantity>00000</OrderPricePerQuantity>'+
'<VATRate>0.00</VATRate>'+
'</LineInformation>'+
'<SubtotalsInformation>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>12</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<Goods_Item_Description/>'+
'<GoodsItemInformation>'+
'<GoodsItemNumber> 111977679</GoodsItemNumber>'+
'<CaseNumber>LDC268278600030</CaseNumber>'+
'<CaseWeightActual>'+
'<Value>6.5600</Value>'+
'<UOM>KGS</UOM>'+
'</CaseWeightActual>'+
'<CaseVolumeActual>'+
'<Value>0.04500</Value>'+
'<UOM>MTQ</UOM>'+
'</CaseVolumeActual>'+
'<BondedFlag>0</BondedFlag>'+
'<ConditionStatus>GOO</ConditionStatus>'+
'<Quantity>'+
'<QuantityValue>12</QuantityValue>'+
'<UOM>EA</UOM>'+
'</Quantity>'+
'<TaxedFlag>0</TaxedFlag>'+
'<MasterCaseNumber>40349844023392970</MasterCaseNumber>'+
'</GoodsItemInformation>'+
'</SubtotalsInformation>'+
'</Line>'+
'</Message>'+
'</DespatchConfirmationExt>';

	
}