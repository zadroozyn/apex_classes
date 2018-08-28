@isTest
private class OSCA_CreateStagingsNewPOs_Test {
	
	@isTest static void onePoWith2Lines() {
		Test.startTest();
		new OSCA_OutboundScheduler().execute(null);
		Test.stopTest();
		List<OSCA_staging__c> lStagingsNewPO = [SELECT Id FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO')];
		System.assert(lStagingsNewPO.isEmpty());
		List<OSCA_staging__c> lStagingsUpdate = [SELECT Id,Object_Type__c FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object')];
		System.assertEquals(7, lStagingsUpdate.size());
	}
	
	@isTest static void twoPoWith2LinesSerialized() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		PBSI__PBSI_Purchase_Order_Line__c poline1 = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = tdf.items.getSObject('Basic').Id,
			PBSI__Quantity_Ordered__c = 8,
			PBSI__Location__c = tdf.locations.getSObject('EU-Stock').Id
		);

		PBSI__PBSI_Purchase_Order_Line__c poline2 = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = tdf.items.getSObject('Other').Id,
			PBSI__Quantity_Ordered__c = 46,
			PBSI__Location__c = tdf.locations.getSObject('EU-Stock').Id
		);
		insert new List<PBSI__PBSI_Purchase_Order_Line__c> {poline1, poline2};
		OSCA_StagingService stagingService = new OSCA_StagingService();
		stagingService.newPOStagingObject(po);
		stagingService.insertStagingObjects();

		Queue.SObj q = OSCA_CreateStagingsNewPOs.getFullQueue(2);

		Test.startTest();
		OSCA_CreateStagingsNewPOs b = new OSCA_CreateStagingsNewPOs(JSON.serialize(q));
		b.executeOSCAOutbound(true);
		Database.executeBatch(b, OSCA_CreateStagingsNewPOs.DEFAULT_BATCH_SIZE);
		Test.stopTest();
		List<OSCA_staging__c> lStagingsNewPO = [SELECT Id FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO')];
		System.assertEquals(1, lStagingsNewPO.size());
		List<OSCA_staging__c> lStagingsUpdate = [SELECT Id,Object_Type__c FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object')];
		System.debug(lStagingsUpdate);
		System.assertEquals(7, lStagingsUpdate.size());
	}

	@isTest static void noPOStaged() {
		delete [SELECT Id FROM OSCA_staging__c];
		Test.startTest();
		new OSCA_OutboundScheduler().execute(null);
		Test.stopTest();
		List<OSCA_staging__c> lStagingsNewPO = [SELECT Id FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO')];
		System.assert(lStagingsNewPO.isEmpty());
		List<OSCA_staging__c> lStagingsUpdate = [SELECT Id,Object_Type__c FROM OSCA_staging__c 
			WHERE RecordTypeId = :RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object')];
		System.assert(lStagingsUpdate.isEmpty());
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
		OSCA_StagingService stagingService = new OSCA_StagingService();
		stagingService.newPOStagingObject(po);
		stagingService.insertStagingObjects();
	}
}