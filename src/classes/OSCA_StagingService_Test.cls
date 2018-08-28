@isTest
private class OSCA_StagingService_Test {
	
	@isTest static void multipleTimesSameObject() {
		TestDataFactory tdf = TestDataFactory.instance;
		SObject sObj = tdf.accounts.getSObject('Account 1');
		
		OSCA_StagingService stagingService = new OSCA_StagingService();

		//before insert
		stagingService.updateStagingObject(sObj);
		stagingService.updateStagingObject(sObj);
		stagingService.insertStagingObjects();

		//after inserting same object
		stagingService.updateStagingObject(sObj);
		stagingService.updateStagingObject(sObj);
		stagingService.insertStagingObjects();

		List<OSCA_staging__c> stagings = [SELECT Id,Object_Id__c,Processing__c,RecordTypeId,Object_Type__c FROM OSCA_staging__c];
		System.assertEquals(1, stagings.size());
		System.assertEquals(false, stagings[0].Processing__c);
		System.assertEquals(sObj.Id, stagings[0].Object_Id__c);
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object'), stagings[0].RecordTypeId);
		System.assertEquals(sObj.Id.getSobjectType().getDescribe().getName(), stagings[0].Object_Type__c);
	}

	@isTest static void notConsiderAlreadyProcessing() {
		TestDataFactory tdf = TestDataFactory.instance;
		SObject sObj = tdf.accounts.getSObject('Account 1');
		OSCA_StagingService stagingService = new OSCA_StagingService();

		stagingService.updateStagingObject(sObj);
		stagingService.insertStagingObjects();

		OSCA_staging__c staging = [SELECT Id FROM OSCA_staging__c];
		staging.Processing__c = true;
		update staging;

		stagingService.updateStagingObject(sObj);
		stagingService.insertStagingObjects();

		List<OSCA_staging__c> stagings = [SELECT Id,Object_Id__c,Processing__c,RecordTypeId,Object_Type__c FROM OSCA_staging__c];
		System.assertEquals(2, stagings.size());
	}

	@isTest static void newPOStaging() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__PBSI_Purchase_Order__c po = new PBSI__PBSI_Purchase_Order__c(
			PBSI__Account__c = tdf.accounts.getSObject('Account 1').Id,
			PBSI__Delivery_Location__c = tdf.locations.getSObject('EU-Stock').Id
		);
		insert po;
		
		OSCA_StagingService stagingService = new OSCA_StagingService();

		stagingService.newPOStagingObject(po);
		stagingService.insertStagingObjects();

		List<OSCA_staging__c> stagings = [SELECT Id,Object_Id__c,Processing__c,RecordTypeId,Object_Type__c FROM OSCA_staging__c];
		System.assertEquals(1, stagings.size());
		System.assertEquals(false, stagings[0].Processing__c);
		System.assertEquals(po.Id, stagings[0].Object_Id__c);
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO'), stagings[0].RecordTypeId);
		System.assertEquals(po.Id.getSobjectType().getDescribe().getName(), stagings[0].Object_Type__c);
	}

	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;

		tdf.accounts.createSObject('Account 1', 'CHF', true);

		tdf.locations.createSObject('EU-Stock', true);

	}
	
}