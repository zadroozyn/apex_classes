@isTest
private class OscaPOLineREST_Test {
	
	@isTest static void createLine() {
		TestDataFactory tdf = TestDataFactory.Instance;
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();

		PBSI__PBSI_Purchase_Order__c po = [SELECT Id FROM PBSI__PBSI_Purchase_Order__c];
		po.OSCA_integration__c = true;
		update po;
		delete [SELECT Id from Osca_staging__c];

		List<Osca_staging__c> lStagingsSanityCheck = [SELECT Id FROM Osca_staging__c];
		System.assert(lStagingsSanityCheck.isEmpty());

		Map<Id, PBSI__PBSI_Purchase_Order_Line__c> allPoLines = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>([SELECT Id FROM PBSI__PBSI_Purchase_Order_Line__c]);

		RestContext.request.requestBody = Blob.valueOf( OSCA_MockInbound.getCreateRequestBody(new List<Id>(allPoLines.keySet())) );
		Test.startTest();
		OscaPOLineREST.createLine();
		Test.stopTest();

		List<Osca_staging__c> lStagingsPO = [SELECT Id FROM Osca_staging__c WHERE Object_Type__c = 'PBSI__PBSI_Purchase_Order__c'];
		System.assertEquals(1, lStagingsPO.size());
		List<Osca_staging__c> lStagingsLines = [SELECT Id FROM Osca_staging__c WHERE Object_Type__c = 'PBSI__PBSI_Purchase_Order_Line__c'];
		System.assertEquals(allPoLines.size(), lStagingsLines.size());

		List<PBSI__PBSI_Purchase_Order_Line__c> newPoLinesAfter = [SELECT Id,PBSI__Quantity_Ordered__c,PBSI__Status__c,Requested_in_house_date__c,
			PBSI__Due_Date__c,Osca_OrderId__c,Osca_ScheduleId__c,OSCA_integration__c FROM PBSI__PBSI_Purchase_Order_Line__c 
				WHERE PBSI__Purchase_Order__c = :po.Id AND Id NOT IN :allPoLines.keySet()];
		System.assertEquals(allPoLines.size(), newPoLinesAfter.size());

		for(PBSI__PBSI_Purchase_Order_Line__c line: newPoLinesAfter) {
			System.assert(line.PBSI__Quantity_Ordered__c == 11);
			System.assert(line.Osca_OrderId__c != null);
			System.assert(line.Osca_ScheduleId__c != null);
		}
	}
	
	@isTest static void updateLine() {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();
		Map<Id, PBSI__PBSI_Purchase_Order_Line__c> allPoLines = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>([SELECT Id FROM PBSI__PBSI_Purchase_Order_Line__c]);
		for(PBSI__PBSI_Purchase_Order_Line__c line: allPoLines.values()) {
			line.OSCA_integration__c = true;
		}
		update allPoLines.values();

		PBSI__PBSI_Purchase_Order__c po = [SELECT Id FROM PBSI__PBSI_Purchase_Order__c];
		po.OSCA_integration__c = true;
		update po;

		delete [SELECT Id from Osca_staging__c];
		List<Osca_staging__c> lStagingsSanityCheck = [SELECT Id FROM Osca_staging__c];
		System.assert(lStagingsSanityCheck.isEmpty());
		RestContext.request.requestBody = Blob.valueOf( OSCA_MockInbound.getUpdateRequestBody(new List<Id>(allPoLines.keySet())) );
		Test.startTest();
		OscaPOLineREST.updateLine();
		Test.stopTest();

		List<Osca_staging__c> lStagingsPO = [SELECT Id FROM Osca_staging__c WHERE Object_Type__c = 'PBSI__PBSI_Purchase_Order__c'];
		System.assertEquals(1, lStagingsPO.size());
		List<Osca_staging__c> lStagingsLines = [SELECT Id FROM Osca_staging__c WHERE Object_Type__c = 'PBSI__PBSI_Purchase_Order_Line__c'];
		System.assertEquals(allPoLines.values().size(), lStagingsLines.size());

		List<PBSI__PBSI_Purchase_Order_Line__c> allPoLinesAfter = [SELECT Id,PBSI__Quantity_Ordered__c,PBSI__Status__c,Requested_in_house_date__c,
			PBSI__Due_Date__c,Osca_OrderId__c,Osca_ScheduleId__c FROM PBSI__PBSI_Purchase_Order_Line__c];

		for(PBSI__PBSI_Purchase_Order_Line__c line: allPoLinesAfter) {
			System.assert(line.PBSI__Quantity_Ordered__c > 0);
			System.assertEquals(OSCA_MockInbound.status, line.PBSI__Status__c);
			System.assertEquals(OSCA_MockInbound.requestedDate, line.Requested_in_house_date__c);
			System.assertEquals(OSCA_MockInbound.dueDate, line.PBSI__Due_Date__c);
			System.assert(line.Osca_OrderId__c != null);
			System.assert(line.Osca_ScheduleId__c != null);
		}
	}

	@isTest static void cancelLinePositive() {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();

		Map<Id, PBSI__PBSI_Purchase_Order_Line__c> allPoLines = new Map<Id, PBSI__PBSI_Purchase_Order_Line__c>([SELECT Id FROM PBSI__PBSI_Purchase_Order_Line__c]);

		RestContext.request.params.put('id',String.join(new List<Id>(allPoLines.keySet()), ','));

		Test.startTest();
		OscaPOLineREST.Response res = (OscaPOLineREST.Response) JSON.deserialize(OscaPOLineREST.cancelLine(), OscaPOLineREST.Response.class);
		Test.stopTest();

		System.assertEquals(200, res.code);
		System.assertEquals('OK', res.status);

		List<PBSI__PBSI_Purchase_Order_Line__c> allPoLinesAfter = [SELECT Id,PBSI__Quantity_Ordered__c,Cancelled_Quantity__c,PBSI__Status__c FROM PBSI__PBSI_Purchase_Order_Line__c];

		for(PBSI__PBSI_Purchase_Order_Line__c line: allPoLinesAfter) {
			System.assert(line.Cancelled_Quantity__c > 0);
			System.assertEquals(0, line.PBSI__Quantity_Ordered__c);
			System.assertEquals('Cancelled', line.PBSI__Status__c);
		}
	}

	@isTest static void cancelLineEmptyId() {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();

		RestContext.request.params.put('id','');

		Test.startTest();
		OscaPOLineREST.Response res = (OscaPOLineREST.Response) JSON.deserialize(OscaPOLineREST.cancelLine(), OscaPOLineREST.Response.class);
		Test.stopTest();

		System.assertEquals(400, res.code);
		System.assertEquals('BAD_REQUEST', res.status);
		System.assertEquals('PO Line Id(s) missing', res.message);

		List<PBSI__PBSI_Purchase_Order_Line__c> allPoLinesAfter = [SELECT Id,PBSI__Quantity_Ordered__c,Cancelled_Quantity__c,PBSI__Status__c FROM PBSI__PBSI_Purchase_Order_Line__c];

		for(PBSI__PBSI_Purchase_Order_Line__c line: allPoLinesAfter) {
			System.assert(line.Cancelled_Quantity__c == 0 || line.Cancelled_Quantity__c == null);
			System.assert(line.PBSI__Quantity_Ordered__c > 0);
			System.assertNotEquals('Cancelled', line.PBSI__Status__c);
		}
	}

	@isTest static void cancelLineInvalidId() {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();

		String invalidId = 'a0Z5700000RZXXXXXX';

		RestContext.request.params.put('id', invalidId);

		Test.startTest();
		OscaPOLineREST.Response res = (OscaPOLineREST.Response) JSON.deserialize(OscaPOLineREST.cancelLine(), OscaPOLineREST.Response.class);
		Test.stopTest();

		System.assertEquals(400, res.code);
		System.assertEquals('BAD_REQUEST', res.status);
		System.assertEquals('Invalid id: {' + invalidId + '}', res.message);

		List<PBSI__PBSI_Purchase_Order_Line__c> allPoLinesAfter = [SELECT Id,PBSI__Quantity_Ordered__c,Cancelled_Quantity__c,PBSI__Status__c FROM PBSI__PBSI_Purchase_Order_Line__c];

		for(PBSI__PBSI_Purchase_Order_Line__c line: allPoLinesAfter) {
			System.assert(line.Cancelled_Quantity__c == 0 || line.Cancelled_Quantity__c == null);
			System.assert(line.PBSI__Quantity_Ordered__c > 0);
			System.assertNotEquals('Cancelled', line.PBSI__Status__c);
		}
	}

	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Item__c item1 = (PBSI__PBSI_Item__c) tdf.items.createSObject('Basic', 100, 150, 'sample desc', location.Id, itemGroup.Id, '123456789', false);
		PBSI__PBSI_Item__c item2 = (PBSI__PBSI_Item__c) tdf.items.createSObject('Other', 90, 140, 'sample desc', location.Id, itemGroup.Id, '123456788', false);
		tdf.items.insertAll();

		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		PBSI__PBSI_Purchase_Order_Line__c poline1 = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = item1.Id,
			PBSI__Quantity_Ordered__c = 10,
			PBSI__Location__c = location.Id
		);

		PBSI__PBSI_Purchase_Order_Line__c poline2 = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = item2.Id,
			PBSI__Quantity_Ordered__c = 45,
			PBSI__Location__c = location.Id
		);

		insert new List<PBSI__PBSI_Purchase_Order_Line__c> {poline1, poline2};
	}
	
}