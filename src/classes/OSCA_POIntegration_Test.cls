@isTest
private class OSCA_POIntegration_Test {
	
	@isTest static void restMultipleIds() {
		List<String> ids = new List<String>{'a0a5700000b23f3','a0a5700000b20dV'};
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();
		RestContext.request.params.put(OSCA_POIntegration.PARAM_ID_NAME,String.join(ids, OSCA_POIntegration.PARAM_ID_SEPARATOR));
		
		Test.startTest();
			OSCA_POIntegration.initIntegration();
		Test.stopTest();

		System.assertEquals(200, RestContext.response.statusCode);
		List<OSCA_staging__c> lStagigins = [SELECT Id,RecordTypeId FROM OSCA_staging__c];
		System.assertEquals(ids.size(), lStagigins.size());
		for(OSCA_staging__c stagingObj: lStagigins) {
			System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO'), stagingObj.RecordTypeId);
		}
	}

	@isTest static void restMissingId() {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();
		
		Test.startTest();
			OSCA_POIntegration.Response res = (OSCA_POIntegration.Response) JSON.deserialize(OSCA_POIntegration.initIntegration(), OSCA_POIntegration.Response.class);
		Test.stopTest();

		System.assertEquals(400, RestContext.response.statusCode);
		System.assertEquals(OSCA_POIntegration.PARAM_ID_MISSING, res.message);
		List<OSCA_staging__c> lStagigins = [SELECT Id FROM OSCA_staging__c];
		System.assert(lStagigins.isEmpty());
	}
	
	@isTest static void webSrvSingleId() {
		Test.startTest();
			OSCA_POIntegration.Response res = (OSCA_POIntegration.Response) JSON.deserialize(OSCA_POIntegration.initIntegrationSingle((Id)'a0a5700000b23f3'), OSCA_POIntegration.Response.class);
		Test.stopTest();

		System.assertEquals(200, res.code);
		List<OSCA_staging__c> lStagigins = [SELECT Id,RecordTypeId FROM OSCA_staging__c];
		System.assertEquals(1, lStagigins.size());
		System.assertEquals(RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO'), lStagigins[0].RecordTypeId);
	}

	@isTest static void webSrvMissingId() {
		Test.startTest();
			OSCA_POIntegration.Response res = (OSCA_POIntegration.Response) JSON.deserialize(OSCA_POIntegration.initIntegrationMultiple(new List<Id>()), OSCA_POIntegration.Response.class);
		Test.stopTest();

		System.assertEquals(400, res.code);
		System.assertEquals(OSCA_POIntegration.PARAM_ID_MISSING, res.message);
		List<OSCA_staging__c> lStagigins = [SELECT Id FROM OSCA_staging__c];
		System.assert(lStagigins.isEmpty());
	}
	
}