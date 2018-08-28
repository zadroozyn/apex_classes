@isTest
private class ONRWebServiceTestTransferOrder {
	
	@isTest
    static void toDispatch_KN_NO_LINES() {
    	Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;

		String response;
		Test.startTest();
	        response = ONRWebService.notifyFulfillerTransferOrder(tdf.transferOrders.getAllSobjects()[0].Id);
	    Test.stopTest();
	    ONRWebService.ResponseObject resObj = (ONRWebService.ResponseObject) JSON.deserialize(response, ONRWebService.ResponseObject.class);
	    System.assertEquals(false, resObj.isSuccess);
	    tdf.transferOrders.refresh();
	    System.assertEquals(false, (Boolean) tdf.transferOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assertEquals(0, (Decimal) tdf.transferOrders.getSObject('0').get('Transmission_Count__c'));
    }

    @isTest
    static void toDispatch_KN_WITH_LINES() {
    	Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;

		PBSI__Transfer_Order__c to1 = (PBSI__Transfer_Order__c) tdf.transferOrders.getAllSobjects()[0];

		String instructions = 'Very long instructions.';
		for(Integer i=0; i<4; i++) {
			instructions += instructions;
		}

		to1.Special_Instructions__c = instructions;
		update to1;

		PBSI__Transfer_Order_Line__c line1 = new PBSI__Transfer_Order_Line__c(
			PBSI__Item__c = tdf.items.getAllSobjects()[0].Id,
			PBSI__Transfer_Order__c = tdf.transferOrders.getAllSobjects()[0].Id,
			PBSI__Quantity_Needed__c = 5
		);
		insert line1;

		PBSI__Shipped_Tranfer_Line__c tLine1 = new PBSI__Shipped_Tranfer_Line__c(
			PBSI__Transfer_Order_Line__c = line1.Id,
			PBSI__Transfer_Order__c = tdf.transferOrders.getAllSobjects()[0].Id,
			PBSI__Quantity__c = 5,
			PBSI__Item__c = tdf.items.getAllSobjects()[0].Id,
			Sent_to_Fulfiller__c = false
		);
		insert tLine1;


		String response;
		Test.startTest();
	        response = ONRWebService.notifyFulfillerTransferOrder(tdf.transferOrders.getAllSobjects()[0].Id);
	    Test.stopTest();
	    ONRWebService.ResponseObject resObj = (ONRWebService.ResponseObject) JSON.deserialize(response, ONRWebService.ResponseObject.class);
	    System.debug('!!!### resObj '+ resObj);
	    System.assertEquals(true, resObj.isSuccess);
	    tdf.transferOrders.refresh();
	    System.assertEquals(true, (Boolean) tdf.transferOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assertEquals(1, (Decimal) tdf.transferOrders.getSObject('0').get('Transmission_Count__c'));
    }

   @isTest
    static void testTransferOrderDispatch_NO_KN() {
    	Test.setMock(HttpCalloutMock.class, new ResponseMock());
		TestDataFactory tdf = TestDataFactory.instance;

		String response;
		Test.startTest();
	        response = ONRWebService.notifyFulfillerTransferOrder(tdf.transferOrders.getAllSobjects()[1].Id);
	    Test.stopTest();
	    ONRWebService.ResponseObject resObj = (ONRWebService.ResponseObject) JSON.deserialize(response, ONRWebService.ResponseObject.class);
	    System.assertEquals(false, resObj.isSuccess);
	    System.assertEquals(false, String.isEmpty(resObj.message));
	    tdf.transferOrders.refresh();
	    System.assertEquals(false, (Boolean) tdf.transferOrders.getSObject('0').get('Notified_Fulfiller__c'));
		System.assertEquals(0, (Decimal) tdf.transferOrders.getSObject('0').get('Transmission_Count__c'));
    }

    @testSetup static void setup() {
		new TestCustomSettingsFactory();

		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Location__c euStock = tdf.locations.createSObject('EU-Stock', false);
		euStock.KN_Client_Id__c = 'OAG';
		euStock.KN_Email_Template_Id__c = '00XD00000025LHO';
		euStock.KN_Logical_Address__c = 'LUCTN04';
		euStock.KN_Order_Type_Code__c = 'OAO';
		euStock.KN_Unit_of_measurement__c = 'EA';
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

		tdf.items.createSObject('Cloud', 100, 120, 'test desc', tdf.locations.getAllSobjects()[0].Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '590986309', true);

		PBSI__Transfer_Order__c to1 = tdf.transferOrders.createSObject(
			tdf.locations.getAllSobjects()[0].Id,
			tdf.locations.getAllSobjects()[1].Id,
			tdf.locations.getAllSobjects()[2].Id,
			false
		);
		to1.Country__c = 'Germany';
		insert to1;

		PBSI__Transfer_Order__c to2 = tdf.transferOrders.createSObject(
			tdf.locations.getAllSobjects()[3].Id,
			tdf.locations.getAllSobjects()[4].Id,
			tdf.locations.getAllSobjects()[2].Id,
			true
		);

		insert new pw_ccpro__CountryObject__c(
			Name = 'Germany',
			pw_ccpro__IsoCode_2__c = 'DE',
			pw_ccpro__IsoCode_3__c = 'DEM'
		);

		insert new Conga_Query_Mapping__c(
			Name = 'knPackingSlip',
			Conga_Query_Id__c = 'a1n6E000000Ofpq'
		);


	}

	private class ResponseMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setBody('xxx');
			return res;
		}
	}

	
}