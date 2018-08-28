@isTest
private class OSCA_TriggerHandler_Test {

	@isTest static void account() {
		TestDataFactory tdf = TestDataFactory.Instance;
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', false);
		acc.OSCA_integration__c = true;
		tdf.accounts.insertAll();

		//should exist
		OSCA_staging__c stagingObjAcc = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :acc.Id];
		delete stagingObjAcc;

		acc.put(OSCA_OutboundFields.ACCOUNT_TRIGGERS[0], 'New Name');
		update acc;

		//should exist
		OSCA_staging__c stagingObjAccAfterUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :acc.Id];
	}
	
	@isTest static void item() {
		TestDataFactory tdf = TestDataFactory.Instance;
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.createSObject('Basic', 100, 150, 'sample desc', location.Id, itemGroup.Id, '123456789', false);
		item.OSCA_integration__c = true;
		insert item;

		//should exist
		OSCA_staging__c stagingObjItem = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :item.Id];
		delete stagingObjItem;

		item.put(OSCA_OutboundFields.ITEM_TRIGGERS[0], '223456789');
		update item;

		//should exist
		OSCA_staging__c stagingObjItemAfterUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :item.Id];
	}

	@isTest static void location() {
		TestDataFactory tdf = TestDataFactory.Instance;
		PBSI__PBSI_Location__c location = (PBSI__PBSI_Location__c) tdf.locations.createSObject('EU-Stock', false);
		location.OSCA_integration__c = true;
		insert location;

		//should exist
		OSCA_staging__c stagingObjLocation = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :location.Id];
		delete stagingObjLocation;

		location.put(OSCA_OutboundFields.LOCATION_TRIGGERS[0], 'Us-Stock');
		update location;

		//should exist
		OSCA_staging__c stagingObjLocationAfterUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :location.Id];
	}

	@isTest static void po() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		PBSI__PBSI_Location__c location = (PBSI__PBSI_Location__c) tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			OSCA_integration__c = true,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		//should exist
		OSCA_staging__c stagingObjPO = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :po.Id];
		delete stagingObjPO;

		po.put(OSCA_OutboundFields.PO_TRIGGERS[1], System.today().addDays(1));
		update po;

		//should exist
		OSCA_staging__c stagingObjPOAfterUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :po.Id];
	}

	@isTest static void polinePositive() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.createSObject('Basic', 100, 150, 'sample desc', location.Id, itemGroup.Id, '123456789', true);
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			OSCA_integration__c = true,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		PBSI__PBSI_Purchase_Order_Line__c poline = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = item.Id,
			PBSI__Quantity_Ordered__c = 10
		);
		insert poLine;

		//should exist
		OSCA_staging__c stagingObj = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :poLine.Id];
		delete stagingObj;

		poLine.put(OSCA_OutboundFields.PO_LINE_TRIGGERS[6], 11);
		update poLine;

		//should exist
		OSCA_staging__c stagingObjAfterUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :poLine.Id];
	}

	@isTest static void polineNegative() {
		TestDataFactory tdf = TestDataFactory.instance;
		Account acc = (Account) tdf.accounts.createSObject('Account 1', 'CHF', true);
		SObject itemGroup = tdf.itemGroups.createSObject('Cloud', 'XXX', 'CHF', 'on', null, true);
		SObject location = tdf.locations.createSObject('EU-Stock', true);
		PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.createSObject('Basic', 100, 150, 'sample desc', location.Id, itemGroup.Id, '123456789', true);
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id,
			OSCA_integration__c = false,
			PBSI__Order_Date__c = System.today()
		);
		insert po;

		PBSI__PBSI_Purchase_Order_Line__c poline = new PBSI__PBSI_Purchase_Order_Line__c(
			PBSI__Purchase_Order__c = po.Id,
			PBSI__Item__c = item.Id,
			PBSI__Quantity_Ordered__c = 10
		);
		insert poLine;

		//should NOT exist
		List<OSCA_staging__c> stagingObjs = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :poLine.Id];
		System.assertEquals(true, stagingObjs.isEmpty());
	}

	@isTest static void notifyParty() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Location__c location = (PBSI__PBSI_Location__c) tdf.locations.createSObject('EU-Stock', false);
		location.OSCA_integration__c = true;
		insert location;

		//should exist
		OSCA_staging__c stagingObj = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :location.Id];
		delete stagingObj;

		PO_Notify_Party__c party = new PO_Notify_Party__c(
			Location__c = location.Id,
			Name = 'Example'
		);
		insert party;

		//should exist
		OSCA_staging__c stagingObjAfterChildInsert = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :location.Id];
		delete stagingObjAfterChildInsert;

		party.Name = 'Example change';
		update party;

		//should exist
		OSCA_staging__c stagingObjAfterChildUpdate = [SELECT Id from OSCA_staging__c WHERE Object_Id__c = :location.Id];
		delete stagingObjAfterChildUpdate;
	}
	
}