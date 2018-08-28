@isTest
private class B24MessageRouterTest {
	
	@isTest static void salesReport() {
		TestDataFactory tdf = TestDataFactory.instance;

		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.SLSRPT_MSG, B24MessageWrapper.class);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();
		Sales_Report__c sReport = [SELECT Id,Name,Account__c,Document_Date__c,Document_Reference__c,Period_Begin__c,Period_End__c,Status__c,
			(SELECT Id,Store_Account__c,Item__c FROM Sales_Report_Items__r)
			FROM Sales_Report__c
			WHERE Account__c = :tdf.accounts.getSObject('Parent_Account').Id];
		System.assertNOTEquals(null, sReport.Document_Date__c);
		System.assertNOTEquals(null, sReport.Document_Reference__c);
		System.assertNOTEquals(null, sReport.Period_Begin__c);
		System.assertNOTEquals(null, sReport.Period_End__c);
		System.assertEquals('Not Processed', sReport.Status__c);
		System.assertEquals(2, sReport.Sales_Report_Items__r.size());
		for(Sales_Report_Item__c item: sReport.Sales_Report_Items__r) {
			System.assertNOTEquals(null, item.Item__c);
			System.assertNOTEquals(null, item.Store_Account__c);
		}
	}
	
	@isTest static void inventoryReport() {
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.INVRPT_MSG, B24MessageWrapper.class);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();
		Inventory_Report__c invReport = [SELECT Id,Name,Account__c,Document_Date__c,Document_Reference__c,Status__c,
			(SELECT Id,Store_Account__c,Item__c FROM Inventory_Report_Items__r)
			FROM Inventory_Report__c
			WHERE Account__c = :tdf.accounts.getSObject('Parent_Account').Id];
		System.assertNOTEquals(null, invReport.Document_Date__c);
		System.assertNOTEquals(null, invReport.Document_Reference__c);
		System.assertEquals('Not Processed', invReport.Status__c);
		System.assertEquals(2, invReport.Inventory_Report_Items__r.size());
		for(Inventory_Report_Item__c item: invReport.Inventory_Report_Items__r) {
			System.assertNOTEquals(null, item.Item__c);
			System.assertNOTEquals(null, item.Store_Account__c);
		}
	}

	@isTest static void orderPSG_no_gln() {
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.ORDER_PSG_NO_GLN_MSG, B24MessageWrapper.class);
		msgWrap.b24Message[0].messageId = '15546';
		System.debug(msgWrap);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();

		B24MessageWrapper.OrderModel receivedOrder = msgWrap.b24Message[0].order;

		PBSI__PBSI_Sales_Order__c so = [SELECT Id,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_Address_line_3__c,PBSI__Delivery_ATTN_to_Phone__c,
			PBSI__Delivery_City__c,PBSI__Delivery_Company__c,PBSI__Delivery_Country__c,PBSI__Delivery_Postal_Code__c,PBSI__Delivery_State__c,PBSI__Customer_Purchase_Order__c,
			PBSI__Comments__c,Delivery_instructions__c,PBSI__Stage__c,PBSI__Status__c,OwnerId,PBSI__Customer__c,Sales_Order_Type__c,CurrencyISOCode,PBSI__Contact__c,
			PBSI__BillingCity__c,PBSI__BillingCompany__c,PBSI__BillingCountry__c,Billing_Name__c,PBSI__BillingState__c,PBSI__BillingStreet__c,PBSI__BillingZip__c,
			(SELECT Id,PBSI__Quantity_Needed__c,PBSI__Item__c FROM PBSI__Sales_Order_Lines__r)
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c = :tdf.accounts.getSObject('PSG').Id];
		Account acc = [SELECT Id, Name, OwnerId, Agent__c, Billing_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone,
			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
			c2g__CODAAccountTradingCurrency__c, c2g__CODAFinanceContact__c
			FROM Account WHERE GLN__c = :receivedOrder.buyer.gln];
		PBSI__PBSI_Item__c item = [SELECT Id, EAN_Number__c from PBSI__PBSI_Item__c WHERE EAN_Number__c = :receivedOrder.item[0].itemReference[0].text];

		//check shipping address - no gln so package should be sent to custorem home address, pointed in order
		System.assertEquals(receivedOrder.deliveryParty.location.address.left(35), so.PBSI__Delivery_Streetnew__c.left(35));
		System.assertEquals(receivedOrder.deliveryParty.location.telephoneNumber, so.PBSI__Delivery_ATTN_to_Phone__c);
		System.assertEquals(receivedOrder.deliveryParty.location.city.text, so.PBSI__Delivery_City__c);
		System.assertEquals(receivedOrder.deliveryParty.name, so.PBSI__Delivery_Company__c);
		System.assertEquals(receivedOrder.deliveryParty.location.country.text, so.PBSI__Delivery_Country__c);
		System.assertEquals(receivedOrder.deliveryParty.location.city.code, so.PBSI__Delivery_Postal_Code__c);
		//check default settings
		System.assertNotEquals(null, so.PBSI__Customer_Purchase_Order__c);
		System.assertNotEquals(null, so.PBSI__Comments__c);
		System.assertEquals('Drop ship', so.Sales_Order_Type__c);
		System.assertEquals('open', so.PBSI__Stage__c);
		System.assertEquals('open', so.PBSI__Status__c);
		System.assertEquals(acc.OwnerId, so.OwnerId);
		System.assertEquals(acc.Id, so.PBSI__Customer__c);
		System.assertEquals(acc.c2g__CODAAccountTradingCurrency__c, so.CurrencyISOCode);
		System.assertEquals(acc.c2g__CODAFinanceContact__c, so.PBSI__Contact__c);
		//check if buyer is to be billed
		System.assertEquals(acc.BillingCity, so.PBSI__BillingCity__c);
		System.assertEquals(acc.Name, so.PBSI__BillingCompany__c);
		System.assertEquals(acc.BillingCountry, so.PBSI__BillingCountry__c);
		System.assertEquals(acc.Billing_Name__c, so.Billing_Name__c);
		System.assertEquals(acc.BillingState, so.PBSI__BillingState__c);
		System.assertEquals(acc.BillingStreet, so.PBSI__BillingStreet__c);
		System.assertEquals(acc.BillingPostalCode, so.PBSI__BillingZip__c);

		System.assertEquals(1, so.PBSI__Sales_Order_Lines__r.size());
		for(PBSI__PBSI_Sales_Order_Line__c line: so.PBSI__Sales_Order_Lines__r) {
			System.assertEquals(item.Id, line.PBSI__Item__c);
			System.assertEquals(1, line.PBSI__Quantity_Needed__c);
		}
	}

	@isTest static void orderPSG_With_gln() {
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.ORDER_PSG_WITH_GLN_MSG, B24MessageWrapper.class);
		msgWrap.b24Message[0].messageId = '15546';
		System.debug(msgWrap);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();

		B24MessageWrapper.OrderModel receivedOrder = msgWrap.b24Message[0].order;

		PBSI__PBSI_Sales_Order__c so = [SELECT Id,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_Address_line_3__c,PBSI__Delivery_ATTN_to_Phone__c,
			PBSI__Delivery_City__c,PBSI__Delivery_Company__c,PBSI__Delivery_Country__c,PBSI__Delivery_Postal_Code__c,PBSI__Delivery_State__c,PBSI__Customer_Purchase_Order__c,
			PBSI__Comments__c,Delivery_instructions__c,PBSI__Stage__c,PBSI__Status__c,OwnerId,PBSI__Customer__c,Sales_Order_Type__c,CurrencyISOCode,PBSI__Contact__c,
			PBSI__BillingCity__c,PBSI__BillingCompany__c,PBSI__BillingCountry__c,Billing_Name__c,PBSI__BillingState__c,PBSI__BillingStreet__c,PBSI__BillingZip__c,
			B2B_Return_Info__c,
			(SELECT Id,PBSI__Quantity_Needed__c,PBSI__Item__c FROM PBSI__Sales_Order_Lines__r)
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c = :tdf.accounts.getSObject('PSG').Id];
		Account acc = [SELECT Id, Name, OwnerId, Agent__c, Billing_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone,
			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
			c2g__CODAAccountTradingCurrency__c, c2g__CODAFinanceContact__c
			FROM Account WHERE GLN__c = :receivedOrder.buyer.gln];
		PBSI__PBSI_Item__c item = [SELECT Id, EAN_Number__c from PBSI__PBSI_Item__c WHERE EAN_Number__c = :receivedOrder.item[0].itemReference[0].text];

		//check shipping address - with gln so package should be sent to shop
		System.assertEquals(acc.ShippingStreet.left(35), so.PBSI__Delivery_Streetnew__c.left(35));
		System.assertEquals(acc.Phone, so.PBSI__Delivery_ATTN_to_Phone__c);
		System.assertEquals(acc.ShippingCity, so.PBSI__Delivery_City__c);
		System.assertEquals(acc.Name, so.PBSI__Delivery_Company__c);
		System.assertEquals(acc.ShippingCountry, so.PBSI__Delivery_Country__c);
		System.assertEquals(acc.ShippingPostalCode, so.PBSI__Delivery_Postal_Code__c);
		//check default settings
		System.assertNotEquals(null, so.PBSI__Customer_Purchase_Order__c);
		System.assertNotEquals(null, so.PBSI__Comments__c);
		System.assertEquals('Drop ship', so.Sales_Order_Type__c);
		System.assertEquals('open', so.PBSI__Stage__c);
		System.assertEquals('open', so.PBSI__Status__c);
		System.assertEquals(acc.OwnerId, so.OwnerId);
		System.assertEquals(acc.Id, so.PBSI__Customer__c);
		System.assertEquals(acc.c2g__CODAAccountTradingCurrency__c, so.CurrencyISOCode);
		System.assertEquals(acc.c2g__CODAFinanceContact__c, so.PBSI__Contact__c);
		//check if buyer is to be billed
		System.assertEquals(acc.BillingCity, so.PBSI__BillingCity__c);
		System.assertEquals(acc.Name, so.PBSI__BillingCompany__c);
		System.assertEquals(acc.BillingCountry, so.PBSI__BillingCountry__c);
		System.assertEquals(acc.Billing_Name__c, so.Billing_Name__c);
		System.assertEquals(acc.BillingState, so.PBSI__BillingState__c);
		System.assertEquals(acc.BillingStreet, so.PBSI__BillingStreet__c);
		System.assertEquals(acc.BillingPostalCode, so.PBSI__BillingZip__c);
		System.assert(so.B2B_Return_Info__c);

		System.assertEquals(1, so.PBSI__Sales_Order_Lines__r.size());
		for(PBSI__PBSI_Sales_Order_Line__c line: so.PBSI__Sales_Order_Lines__r) {
			System.assertEquals(item.Id, line.PBSI__Item__c);
			System.assertEquals(1, line.PBSI__Quantity_Needed__c);
		}
	}

	@isTest static void orderPSG_line_error_gln() {
		TestDataFactory tdf = TestDataFactory.instance;
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.ORDER_PSG_GLN_LINE_ERROR_MSG, B24MessageWrapper.class);
		msgWrap.b24Message[0].messageId = '15546';
		System.debug(msgWrap);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();

		B24MessageWrapper.OrderModel receivedOrder = msgWrap.b24Message[0].order;

		List<PBSI__PBSI_Sales_Order__c> so = [SELECT Id
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c = :tdf.accounts.getSObject('PSG').Id];
		System.assert(so.isEmpty());
		
	}

	@isTest static void orderISGPreOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.ISG_PRE_ORDER, B24MessageWrapper.class);
		msgWrap.b24Message[0].messageId = '15546';
		System.debug(msgWrap);
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();

		B24MessageWrapper.OrderModel receivedOrder = msgWrap.b24Message[0].order;

		PBSI__PBSI_Sales_Order__c so = [SELECT Id,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_Address_line_3__c,PBSI__Delivery_ATTN_to_Phone__c,
			PBSI__Delivery_City__c,PBSI__Delivery_Company__c,PBSI__Delivery_Country__c,PBSI__Delivery_Postal_Code__c,PBSI__Delivery_State__c,PBSI__Customer_Purchase_Order__c,
			PBSI__Comments__c,Delivery_instructions__c,PBSI__Stage__c,PBSI__Status__c,OwnerId,PBSI__Customer__c,Sales_Order_Type__c,CurrencyISOCode,PBSI__Contact__c,
			PBSI__BillingCity__c,PBSI__BillingCompany__c,PBSI__BillingCountry__c,Billing_Name__c,PBSI__BillingState__c,PBSI__BillingStreet__c,PBSI__BillingZip__c,PBSI__Due_Date__c,
			(SELECT Id,PBSI__Quantity_Needed__c,PBSI__Item__c FROM PBSI__Sales_Order_Lines__r)
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c = :tdf.accounts.getSObject('ISG').Id];
		Account acc = [SELECT Id, Name, OwnerId, Agent__c, Billing_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone,
			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
			c2g__CODAAccountTradingCurrency__c, c2g__CODAFinanceContact__c
			FROM Account WHERE GLN__c = :receivedOrder.buyer.gln];
		PBSI__PBSI_Item__c item = [SELECT Id, EAN_Number__c from PBSI__PBSI_Item__c WHERE EAN_Number__c = :receivedOrder.item[0].itemReference[0].text];

		//check default settings
		System.assertNotEquals(null, so.PBSI__Customer_Purchase_Order__c);
		System.assertNotEquals(null, so.PBSI__Comments__c);
		System.assertEquals('Pre-Order', so.Sales_Order_Type__c);
		System.assertEquals('open', so.PBSI__Stage__c);
		System.assertEquals('open', so.PBSI__Status__c);
		System.assertEquals(acc.OwnerId, so.OwnerId);
		System.assertEquals(acc.Id, so.PBSI__Customer__c);
		System.assertEquals(Date.newInstance(2018, 9, 3) , so.PBSI__Due_Date__c);
		//check if buyer is to be billed
		System.assertEquals(acc.BillingCity, so.PBSI__BillingCity__c);
		System.assertEquals(acc.Name, so.PBSI__BillingCompany__c);
		System.assertEquals(acc.BillingCountry, so.PBSI__BillingCountry__c);
		System.assertEquals(acc.Billing_Name__c, so.Billing_Name__c);
		System.assertEquals(acc.BillingState, so.PBSI__BillingState__c);
		System.assertEquals(acc.BillingStreet, so.PBSI__BillingStreet__c);
		System.assertEquals(acc.BillingPostalCode, so.PBSI__BillingZip__c);

		System.assertEquals(2, so.PBSI__Sales_Order_Lines__r.size());
		for(PBSI__PBSI_Sales_Order_Line__c line: so.PBSI__Sales_Order_Lines__r) {
			System.assertEquals(1, line.PBSI__Quantity_Needed__c);
		}
	}

	@isTest static void emptyMessage() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = new B24MessageWrapper();
		msgWrap.b24Message.add( new B24MessageWrapper.B24MessageModel() );
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();
	}

	@isTest static void orderRRS() {
		TestDataFactory tdf = TestDataFactory.instance;
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(B24MockCallout.ORDER_RRS_MSG, B24MessageWrapper.class);
		msgWrap.b24Message[0].messageId = '15546';
		System.debug(msgWrap);
		Contact dropshipContact = new Contact(
			FirstName = 'RRS',
			LastName = 'DROP SHIP',
			Email = 'rrs@dropship.com'
		);
		insert dropshipContact;
		Test.startTest();
  		new B24MessageRouter(msgWrap.b24Message[0],null).execute(null);
		Test.stopTest();

		B24MessageWrapper.OrderModel receivedOrder = msgWrap.b24Message[0].order;

		PBSI__PBSI_Sales_Order__c so = [SELECT Id,PBSI__Delivery_Streetnew__c,PBSI__Delivery_Address_line2__c,PBSI__Delivery_Address_line_3__c,PBSI__Delivery_ATTN_to_Phone__c,
			PBSI__Delivery_City__c,PBSI__Delivery_Company__c,PBSI__Delivery_Country__c,PBSI__Delivery_Postal_Code__c,PBSI__Delivery_State__c,PBSI__Customer_Purchase_Order__c,
			PBSI__Comments__c,Delivery_instructions__c,PBSI__Stage__c,PBSI__Status__c,OwnerId,PBSI__Customer__c,Sales_Order_Type__c,CurrencyISOCode,PBSI__Contact__c,
			PBSI__BillingCity__c,PBSI__BillingCompany__c,PBSI__BillingCountry__c,Billing_Name__c,PBSI__BillingState__c,PBSI__BillingStreet__c,PBSI__BillingZip__c,
			Packing_instructions__c,
			(SELECT Id,PBSI__Quantity_Needed__c,PBSI__Item__c FROM PBSI__Sales_Order_Lines__r)
			FROM PBSI__PBSI_Sales_Order__c
			WHERE PBSI__Customer__c = :tdf.accounts.getSObject('RRS').Id];
		Account acc = [SELECT Id, Name, OwnerId, Agent__c, Billing_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone,
			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
			c2g__CODAAccountTradingCurrency__c, c2g__CODAFinanceContact__c
			FROM Account WHERE GLN__c = :receivedOrder.buyer.gln];

		//check shipping address - with gln so package should be sent to shop
		System.assertEquals(receivedOrder.deliveryParty.location.address.left(35), so.PBSI__Delivery_Streetnew__c.left(35));
		System.assertEquals(receivedOrder.deliveryParty.location.telephoneNumber, so.PBSI__Delivery_ATTN_to_Phone__c);
		System.assertEquals(receivedOrder.deliveryParty.location.city.text, so.PBSI__Delivery_City__c);
		System.assertEquals(receivedOrder.deliveryParty.name, so.PBSI__Delivery_Company__c);
		System.assertEquals('United States', so.PBSI__Delivery_Country__c);
		System.assertEquals(receivedOrder.deliveryParty.location.city.code, so.PBSI__Delivery_Postal_Code__c);
		//check default settings
		System.assertNotEquals(null, so.PBSI__Customer_Purchase_Order__c);
		System.assertNotEquals(null, so.PBSI__Comments__c);
		System.assertEquals('Drop ship', so.Sales_Order_Type__c);
		System.assertEquals('open', so.PBSI__Stage__c);
		System.assertEquals('open', so.PBSI__Status__c);
		System.assertEquals(acc.OwnerId, so.OwnerId);
		System.assertEquals(acc.Id, so.PBSI__Customer__c);
		System.assertEquals(acc.c2g__CODAAccountTradingCurrency__c, so.CurrencyISOCode);
		System.assertEquals(dropshipContact.Id, so.PBSI__Contact__c);
		System.assertEquals('RRS DROP SHIP', so.Packing_instructions__c);
		//check if buyer is to be billed
		System.assertEquals(acc.BillingCity, so.PBSI__BillingCity__c);
		System.assertEquals(acc.Name, so.PBSI__BillingCompany__c);
		System.assertEquals(acc.BillingCountry, so.PBSI__BillingCountry__c);
		System.assertEquals(acc.Billing_Name__c, so.Billing_Name__c);
		System.assertEquals(acc.BillingState, so.PBSI__BillingState__c);
		System.assertEquals(acc.BillingStreet, so.PBSI__BillingStreet__c);
		System.assertEquals(acc.BillingPostalCode, so.PBSI__BillingZip__c);

		System.assertEquals(2, so.PBSI__Sales_Order_Lines__r.size());
		for(PBSI__PBSI_Sales_Order_Line__c line: so.PBSI__Sales_Order_Lines__r) {
			System.assertNOTEquals(null, line.PBSI__Item__c);
			System.assertEquals(1, line.PBSI__Quantity_Needed__c);
		}
	}
	
	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		B24_Integration_Model__c isg = new B24_Integration_Model__c(
			Name = 'Intersport Germany',
			Order_inbound__c = 'B24ISGOrderCreator'
		);
		B24_Integration_Model__c rrs = new B24_Integration_Model__c(
			Name = 'RRS',
			Order_inbound__c = 'B24RRSOrderCreator'
		);
		B24_Integration_Model__c psg = new B24_Integration_Model__c(
			Name = 'PSG',
			Order_inbound__c = 'B24PSGOrderCreator'
		);
		insert new List<B24_Integration_Model__c> {isg, rrs, psg};

		tdf.accounts.createSObject('Parent_Account', 'CHF', false);
		tdf.accounts.getSObject('Parent_Account').put('GLN__c', '4038925000016');

		tdf.accounts.createSObject('Store_1', 'CHF', false);
		tdf.accounts.getSObject('Store_1').put('GLN__c', '4260373430019');

		tdf.accounts.createSObject('Store_2', 'CHF', false);
		tdf.accounts.getSObject('Store_2').put('GLN__c', '4038925000191');

		tdf.accounts.createSObject('PSG', 'CHF', false);
		tdf.accounts.getSObject('PSG').put('GLN__c', '4399902216555');
		tdf.accounts.getSObject('PSG').put('ShippingStreet', 'Neverland 1');
		tdf.accounts.getSObject('PSG').put('ShippingCountry', 'Germany');
		tdf.accounts.getSObject('PSG').put('ShippingCity', 'NoName');
		tdf.accounts.getSObject('PSG').put('ShippingPostalCode', 'NoName');
		tdf.accounts.getSObject('PSG').put('ShippingState', 'NY');
		tdf.accounts.getSObject('PSG').put('GLN__c', '4399902216555');
		tdf.accounts.getSObject('PSG').put('BillingStreet', 'Neverland 1');
		tdf.accounts.getSObject('PSG').put('BillingCountry', 'Germany');
		tdf.accounts.getSObject('PSG').put('BillingCity', 'NoName');
		tdf.accounts.getSObject('PSG').put('BillingPostalCode', 'NoName');
		tdf.accounts.getSObject('PSG').put('BillingState', 'NY');
		tdf.accounts.getSObject('PSG').put('B24_Integration_Model__c', psg.Id);


		tdf.accounts.createSObject('RRS', 'USD', false);
		tdf.accounts.getSObject('RRS').put('GLN__c', '7340117820218');
		tdf.accounts.getSObject('RRS').put('B24_Integration_Model__c', rrs.Id);
		tdf.accounts.createSObject('ISG', 'EUR', false);
		tdf.accounts.getSObject('ISG').put('GLN__c', '4399901765108');
		tdf.accounts.getSObject('ISG').put('B24_Integration_Model__c', isg.Id);

		tdf.accounts.insertAll();

		tdf.contacts.createSObject('Smith', 'smith@exemple.com',tdf.accounts.getSObject('PSG').Id, true);
		tdf.accounts.getSObject('PSG').put('c2g__CODAFinanceContact__c', tdf.contacts.getSObject('Smith').Id);
		tdf.accounts.updateAll();

		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('US-Stock', false);
		tdf.locations.insertAll();

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165317761', false);
		tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7630040505581', false);
		tdf.items.createSObject('4.4103 W 8', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319192', false);

		tdf.items.createSObject('4.4102 W 8.5', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319338', false);
		tdf.items.createSObject('4.4103 W 9', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319345', false);

		tdf.items.insertAll();
	}
}