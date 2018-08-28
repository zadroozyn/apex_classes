@isTest
class KNDeliveryXmlCreatorTest {

	@istest
	static void testSOGermany() {
		TestDataFactory tdf = TestDataFactory.instance;


		Account dealer = tdf.accounts.createSObject('Test account', 'EUR', RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Business_Customer'), false);
		Account webAccount = tdf.accounts.createSObject('User', 'Tester', 'EUR', false);

		PBSI__PBSI_Location__c euStock = tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('no-stock', false);
		euStock.KN_Client_Id__c = 'OAG';
		euStock.KN_Email_Template_Id__c = '00XD00000025LHO';
		euStock.KN_Logical_Address__c = 'LUCTN04';
		euStock.KN_Order_Type_Code__c = 'ORB';
		euStock.KN_Order_Type_Code_B2C__c = 'ORC';
		euStock.KN_Unit_of_measurement__c = 'EA';

		pw_ccpro__CountryObject__c germany = tdf.countries.createSObject('Germany', 'DE', 'DEU', true);
		germany.Dealer_location__r = euStock;
		germany.Webshop_location__r = euStock;

		dealer.BillingCountry = dealer.ShippingCountry = 'Germany';
		dealer.pw_ccpro__BillingCountryLookup__r = germany;
		dealer.pw_ccpro__ShippingCountryLookup__r = germany;

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		SObject item1 = tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165317761', false);
		SObject item2 = tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7630040505581', false);
		tdf.items.createSObject('4.4103 W 8', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
				tdf.itemGroups.getAllSobjects()[0].Id, '7640165319192', false);

		PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(tdf.accounts.getSObject('Test account').Id, 'Re-order', tdf.locations.getSObject('EU-Stock').Id, false);
		so.PBSI__Delivery_Country__c = 'Germany';
		so.PBSI__From_Location__r = euStock;
		so.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('pbsi__pbsi_sales_order__c', 'web_order');
		List<PBSI__PBSI_Sales_Order_Line__c> lSoLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		lSoLines.add(
				new PBSI__PBSI_Sales_Order_Line__c(
					PBSI__Sales_Order__r = so,
					PBSI__Item__r = (PBSI__PBSI_Item__c)tdf.items.getSObject('4.4102 W 6.5'),
					PBSI__Quantity_Needed__c = 5,
					PBSI__Quantity_Picked__c = 0
					)
				);
		lSoLines.add(
				new PBSI__PBSI_Sales_Order_Line__c(
					PBSI__Sales_Order__r = so,
					PBSI__Item__r = (PBSI__PBSI_Item__c)tdf.items.getSObject('4.4102 W 7'),
					PBSI__Quantity_Needed__c = 10,
					PBSI__Quantity_Picked__c = 0
					)
				);
		List<PBSI__Shipped_Sales_Order_Line__c> lSOPackedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		for(Integer i = 0; i < lSoLines.size(); i++) {
			PBSI__PBSI_Sales_Order_Line__c line = lSoLines[i];
			PBSI__Shipped_Sales_Order_Line__c packedLine = new PBSI__Shipped_Sales_Order_Line__c(
					PBSI__Quantity_Shipped__c = line.PBSI__Quantity_Needed__c,
					PBSI__Item__c = line.PBSI__Item__c,
					Shipment_status__c = 'Processing'
					);
			packedLine.PBSI__Sales_Order__r = so;
			packedLine.PBSI__Sales_Order_Line__r = line;
			lSOPackedLines.add(packedLine);

		}

		Order_Stage__c orderStage = new Order_Stage__c(
			RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_SO'),
			Sales_Order__r = so,
			Transmission_Id__c = 'SO-1111-99'
		);

		Test.startTest();
	
		Dom.Document result = new KNDeliveryXmlCreator( new KN_OrderSOCreator.OrderStage(orderStage, orderStage.Sales_Order__r, lSOPackedLines)).buildXml(); 
		Test.stopTest();
		System.assertEquals('DeliveryOrderExt', result.getRootElement().getName());
		System.assertEquals('http://www.w3.org/2001/XMLSchema', result.getRootElement().getNamespaceFor('xsd'));
		System.assertNotEquals(null, result.getRootElement().getChildElement('Envelope', null));
		System.assertNotEquals(null, result.getRootElement().getChildElement('Message', null));
		System.assertEquals(
			'SO-1111-99', result.getRootElement().getChildElement('Message', null)
				.getChildElement('Header', null)
				.getChildElement('OrderInformation', null)
				.getChildElement('ClientOrderReference', null).getText()
		);
	}

}