//test 4
public class OSCA_StagingService {

	private static Id updateStagingId;
	private static Id newPOStagingId;

	private Map<Id, OSCA_staging__c> stagingsToInsert;

	public OSCA_StagingService() {
		stagingsToInsert = new Map<Id, OSCA_staging__c>();
		if(updateStagingId == null || newPOStagingId == null) {
			updateStagingId = RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'Update_Object');
			newPOStagingId = RecordTypeService.getRecordTypeIdByDeveloperName('OSCA_staging__c', 'New_PO');
		}
	}

	public void insertStagingObjects() {
		Database.insert(stagingsToInsert.values(), false);
		stagingsToInsert = new Map<Id, OSCA_staging__c>();
	}

	public void updateStagingObject(SObject sObj) {
		stagingObject(sObj, updateStagingId);
	}

	public void updateStagingObject(List<SObject> sObjs) {
		for(SObject sObj: sObjs) {
			stagingObject(sObj, updateStagingId);
		}
	}

	public void newPOStagingObject(SObject sObj) {
		stagingObject(sObj, newPOStagingId);
	}

	private void stagingObject(SObject sObj, Id rtId) {
		stagingsToInsert.put(
			sObj.Id,
			new OSCA_staging__c(
				Object_Type__c = sObj.Id.getSobjectType().getDescribe().getName(),
				Object_Id__c = sObj.Id,
				RecordTypeId = rtId
			)
		);
	}
}
