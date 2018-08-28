@isTest
private class OSCA_Outbound_Test {

	private static final Integer OBJECTS_NUMBER = 50;
	
	@isTest static void empty() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.accounts.createSObject('Account '+i, 'CHF', false);
		}
		tdf.accounts.insertAll();
		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound();
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<Account> lAccs = [SELECT Id FROM Account WHERE OSCA_Integration__c = true];
		System.assert(lAccs.isEmpty());
	}

	@isTest static void account() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.accounts.createSObject('Account '+i, 'CHF', false);
		}
		tdf.accounts.insertAll();
		createStagings(tdf.accounts.getAllSObjects());

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound();
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<Account> lAccs = [SELECT Id FROM Account WHERE OSCA_Integration__c = true];
		System.assertEquals(OBJECTS_NUMBER, lAccs.size());
	}
	
	@isTest static void location() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.locations.createSObject('Stock-'+i, false);
		}
		tdf.locations.insertAll();
		createStagings(tdf.locations.getAllSObjects());

		OSCA_Outbound.ObjectInfo oi = new OSCA_Outbound.ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Location__c')
					.fields(OSCA_OutboundFields.LOCATION_SOQL)
					.urlEndpoint('location')
					.batchSize(50);
		OSCA_Outbound.Queue q = new OSCA_Outbound.Queue();
		q.enqueue(oi);

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound(JSON.serialize(q));
		oscaOut.restart(true);
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<PBSI__PBSI_Location__c> lLocs = [SELECT Id FROM PBSI__PBSI_Location__c WHERE OSCA_Integration__c = true];
		System.assertEquals(OBJECTS_NUMBER, lLocs.size());
	}

	@isTest static void item() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());

		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.items.createSObject('Basic'+i, 100, 150, 'sample desc'+i, location.Id, itemGroup.Id, '12345678'+i, false);
		}
		tdf.items.insertAll();
		createStagings(tdf.items.getAllSObjects());

		OSCA_Outbound.ObjectInfo oi = new OSCA_Outbound.ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Item__c')
					.fields(OSCA_OutboundFields.ITEM_SOQL)
					.urlEndpoint('item')
					.batchSize(50);
		OSCA_Outbound.Queue q = new OSCA_Outbound.Queue();
		q.enqueue(oi);

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound(JSON.serialize(q));
		oscaOut.restart(true);
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<PBSI__PBSI_Item__c> lItems = [SELECT Id FROM PBSI__PBSI_Item__c WHERE OSCA_Integration__c = true];
		System.assertEquals(OBJECTS_NUMBER, lItems.size());
	}

	@isTest static void po() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		PBSI__PBSI_Location__c location = (PBSI__PBSI_Location__c) tdf.locations.createSObject('EU-Stock', true);

		List<PBSI__PBSI_Purchase_Order__c> lPo = new List<PBSI__PBSI_Purchase_Order__c>();
		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
				PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
				PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
				OSCA_integration__c = true,
				PBSI__Order_Date__c = System.today()
			);
			lPo.add(po);		
		}
		insert lPo;
		createStagings(lPo);

		OSCA_Outbound.ObjectInfo oi = new OSCA_Outbound.ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Purchase_Order__c')
					.fields(OSCA_OutboundFields.PO_SOQL)
					.urlEndpoint('po')
					.batchSize(50);
		OSCA_Outbound.Queue q = new OSCA_Outbound.Queue();
		q.enqueue(oi);

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound(JSON.serialize(q));
		oscaOut.restart(true);
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<PBSI__PBSI_Purchase_Order__c> pos = [SELECT Id FROM PBSI__PBSI_Purchase_Order__c WHERE OSCA_Integration__c = true];
		System.assertEquals(OBJECTS_NUMBER, pos.size());
	}

	@isTest static void poline() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			OSCA_integration__c = true,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.items.createSObject('Basic'+i, 100, 150, 'sample desc'+i, location.Id, itemGroup.Id, '12345678'+i, false);
		}
		tdf.items.insertAll();

		List<PBSI__PBSI_Purchase_Order_Line__c> lPolines = new List<PBSI__PBSI_Purchase_Order_Line__c>();
		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			PBSI__PBSI_Purchase_Order_Line__c poline = new PBSI__PBSI_Purchase_Order_Line__c(
				PBSI__Purchase_Order__c = po.Id,
				PBSI__Item__c = tdf.items.getAllSObjects()[i].Id,
				PBSI__Quantity_Ordered__c = 10
			);
			lPolines.add(poline);
		}
		insert lPolines;

		createStagings(tdf.items.getAllSObjects());

		OSCA_Outbound.ObjectInfo oi = new OSCA_Outbound.ObjectInfo()
					.sObjTypeName('PBSI__PBSI_Purchase_Order_Line__c')
					.fields(OSCA_OutboundFields.PO_LINE_SOQL)
					.urlEndpoint('poline')
					.batchSize(50);
		OSCA_Outbound.Queue q = new OSCA_Outbound.Queue();
		q.enqueue(oi);

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound(JSON.serialize(q));
		oscaOut.restart(true);
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<PBSI__PBSI_Purchase_Order_Line__c> lines = [SELECT Id FROM PBSI__PBSI_Purchase_Order_Line__c WHERE OSCA_Integration__c = true];
		System.assertEquals(OBJECTS_NUMBER, lines.size());
	}

	@isTest static void unauthorized() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout('unauthorized'));

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound();
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Type__c = 'OSCA_Outbound_Login'];
		System.assertEquals(1, logs.size());
	}

	@isTest static void allFailureAccount() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout('failures'));

		for(Integer i=0; i<OBJECTS_NUMBER; i++) {
			tdf.accounts.createSObject('Account '+i, 'CHF', false);
		}
		tdf.accounts.insertAll();
		createStagings(tdf.accounts.getAllSObjects());

		Test.startTest();

		OSCA_Outbound oscaOut = new OSCA_Outbound();
		Database.executeBatch(oscaOut, oscaOut.getCurrentBatchSize());

		Test.stopTest();

		List<Account> lAccs = [SELECT Id FROM Account WHERE OSCA_Integration__c = true];
		System.assert(lAccs.isEmpty());
		
		List<Log__c> logs = [SELECT Id FROM Log__c WHERE Type__c = 'OSCA_Outbound_Result'];
		System.assertEquals(OBJECTS_NUMBER, logs.size());
	}

	private static void createStagings(List<SObject> lSObjs) {
		OSCA_StagingService stagingService = new OSCA_StagingService();
		for(SObject sObj: lSObjs) {
			stagingService.updateStagingObject(sObj);
		}
		stagingService.insertStagingObjects();
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();
	}
	
}