@isTest
public with sharing class CongaMsgBuilderTest {

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

		tdf.orderStages.createSObject('Processing', so1.Id, false);
		tdf.orderStages.insertAll();
	}


	@isTest
	static void testGetConfirmationEmailURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getConfirmationEmailBuilder();

		String expectedVal = Conga_Composer_base_Url__c.getInstance().URL__c
			+ '?sessionId=' + UserInfo.getSessionId()
			+ '&id=' + order.id
			+ '&serverURL=' + System.URL.getSalesforceBaseURL().toExternalForm()
			+ '/services/Soap/u/40.0/' + OrganizationService.getInstance().organizationId
			+ '&EmailToId=' + order.PBSI__Contact__r.Id
			+ '&EmailFromId=0D2D0000000027T'
			+ '&EmailBCC=' + ONRLogisticsGateway.EMAIL_CC
			+ '&DS7=2'
			+ '&APIMode=12'
			+ '&CETID=' + order.Purchase_Confirmation__c
			+ '&QueryId=' + Conga_Query_Mapping__c.getInstance('fullBodLines').Conga_Query_Id__c + '?pv0=' + order.Id;
		System.debug(rBuilder.getRequest().getEndpoint());
		System.debug(expectedVal);

		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getShippingEmailURL() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getShippingEmailBuilder();

		String expectedVal = Conga_Composer_base_Url__c.getInstance().URL__c
			+ '?sessionId=' + UserInfo.getSessionId()
			+ '&id=' + order.id
			+ '&serverURL=' + System.URL.getSalesforceBaseURL().toExternalForm()
			+ '/services/Soap/u/40.0/' + OrganizationService.getInstance().organizationId
			+ '&EmailToId=' + order.PBSI__Contact__r.Id
			+ '&EmailFromId=0D2D0000000027T'
			+ '&EmailBCC=' + ONRLogisticsGateway.EMAIL_CC
			+ '&DS7=2'
			+ '&APIMode=12'
			+ '&CETID=' + order.Shipping_Confirmation_Invoice_Email_ID__c
			+ '&QueryId=' + Conga_Query_Mapping__c.getInstance('shippingConfirmationLines').Conga_Query_Id__c + '?pv0=' + order.Id;

		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getDefaultBuilderTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getDefaultBuilder();
		String expectedVal = Conga_Composer_base_Url__c.getInstance().URL__c
			+ '?sessionId=' + UserInfo.getSessionId()
			+ '&id=' + order.id
			+ '&serverURL=' + System.URL.getSalesforceBaseURL().toExternalForm()
			+ '/services/Soap/u/40.0/' + OrganizationService.getInstance().organizationId;
		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getDefaultBodBuilderTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getDefaultBodBuilder();
		String expectedVal = cBuilder.getDefaultBuilder().getRequest().getEndpoint()
			+ '&AC0=1'
			+ '&AC1=Bill+of+Delivery+Generated+By+On+AG'
			+ '&Culture=' + order.Culture__c
			+ '&FP0=1';
		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getFullBodBuilder() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getFullBodBuilder();
		String expectedVal = cBuilder.getDefaultBodBuilder().getRequest().getEndpoint()
			+ '&TemplateId=' + order.Bill_of_Delivery__c
			+ '&QueryId=[LineItems]' + Conga_Query_Mapping__c.getInstance('fullBodLines').Conga_Query_Id__c + '?pv0=' +order.Id;
		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getPartialBodBuilderTest() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		Id stageId = tdf.orderStages.getSObjectId('0');
		HttpRequestBuilder rBuilder = cBuilder.getPartialBodBuilder(stageId);
		String expectedVal = cBuilder.getDefaultBodBuilder().getRequest().getEndpoint()
			+ '&TemplateId=' +  order.Bill_of_Delivery_Partial_Conga_ID__c
			+ '&QueryId=[LineItems]' + Conga_Query_Mapping__c.getInstance('partialBodLines').Conga_Query_Id__c
			+ '?pv0=' + stageId
			+ ',[AlreadyDelTot]' + Conga_Query_Mapping__c.getInstance('partialBodAlreadyDeliveredTotals').Conga_Query_Id__c 
			+ '?pv0=' + stageId + '~pv1=' + order.Id
			+ ',[InThisShip]' +Conga_Query_Mapping__c.getInstance('partialBodInThisShipment').Conga_Query_Id__c
			+ '?pv0=' + stageId;
		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}

	@isTest
	static void getB2cBodBuilder() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Sales_Order__c order = (PBSI__PBSI_Sales_Order__c)tdf.salesOrders.getSObjectsByField('PBSI__From_Location__c', tdf.locations.getSObjectId('EU-Stock'))[0];
		CongaMsgBuilder cBuilder = new CongaMsgBuilder(order.Id, UserInfo.getSessionId());
		HttpRequestBuilder rBuilder = cBuilder.getB2CBodBuilder();
		String expectedVal = cBuilder.getDefaultBodBuilder().getRequest().getEndpoint()
			+ '&QueryId=[LineItems]' + Conga_Query_Mapping__c.getInstance('fullBodLines').Conga_Query_Id__c
			+ '?pv0=' + order.Id;
		System.assert(rBuilder.getRequest().getEndpoint() == expectedVal);
	}
}