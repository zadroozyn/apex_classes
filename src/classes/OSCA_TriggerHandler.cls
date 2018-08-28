public class OSCA_TriggerHandler {

	private static OSCA_TriggerHandler singleton;

	public static OSCA_TriggerHandler Instance {
		get {
			if(singleton == null) {
				singleton = new OSCA_TriggerHandler();
			}
			return singleton;
		}
		private set;
	}

	private SObjectHandler sObjHanlder;
	
	public void insertListener(List<SObject> lSObjsNew) {
		OSCA_StagingService stagingService = new OSCA_StagingService();
		for(SObject sObj: lSObjsNew) {
            if(sObj.get(sObjHanlder.oscaFieldName) == true) {
                stagingService.updateStagingObject(sObj);
            }
        }
        stagingService.insertStagingObjects();
	}

	public void updateListener(Map<Id,SObject> mapObjsOld, Map<Id,SObject> mapObjsNew) {
		OSCA_StagingService stagingService = new OSCA_StagingService();
		for(Id key: mapObjsNew.keySet()) {
            if(mapObjsNew.get(key).get(sObjHanlder.oscaFieldName) == true 
                && (
                	mapObjsOld.get(key).get(sObjHanlder.oscaFieldName) == false 
                		|| OSCA_OutboundFields.oscaFieldChanged(sObjHanlder.fields, mapObjsOld.get(key), mapObjsNew.get(key))
                	)
            ) {
                 stagingService.updateStagingObject(mapObjsNew.get(key));
            }
        }
        stagingService.insertStagingObjects();
	}

	public void insertListenerOnChild(List<SObject> lSObjsNew, String parentRelationField) {
		OSCA_StagingService stagingService = new OSCA_StagingService();
		for(SObject sObj: lSObjsNew) {
			Object parentId = sObj.get(parentRelationField);
            if(sObj.get(sObjHanlder.oscaFieldName) == true && parentId != null) {
            	SObject parentSObj = ((Id)parentId).getSobjectType().newSObject();
            	parentSObj.Id = (Id) parentId;
                stagingService.updateStagingObject(parentSObj);
            }
        }
        stagingService.insertStagingObjects();
	}

	public void updateListenerOnChild(Map<Id,SObject> mapObjsOld, Map<Id,SObject> mapObjsNew, String parentRelationField) {
		OSCA_StagingService stagingService = new OSCA_StagingService();
		for(Id key: mapObjsNew.keySet()) {
			Object parentId = mapObjsNew.get(key).get(parentRelationField);
            if(mapObjsNew.get(key).get(sObjHanlder.oscaFieldName) == true 
                && (
                	mapObjsOld.get(key).get(sObjHanlder.oscaFieldName) == false 
                		|| OSCA_OutboundFields.oscaFieldChanged(sObjHanlder.fields, mapObjsOld.get(key), mapObjsNew.get(key))
                	)
                && parentId != null
            ) {
            	SObject parentSObj = ((Id)parentId).getSobjectType().newSObject();
            	parentSObj.Id = (Id) parentId;
                stagingService.updateStagingObject(parentSObj);
            }
        }
        stagingService.insertStagingObjects();
	}

	public OSCA_TriggerHandler account() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.ACCOUNT_TRIGGERS;
		return this;
	}

	public OSCA_TriggerHandler item() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.ITEM_TRIGGERS;
		return this;
	}

	public OSCA_TriggerHandler location() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.LOCATION_TRIGGERS;
		return this;
	}

	public OSCA_TriggerHandler po() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.PO_TRIGGERS;
		return this;
	}

	public OSCA_TriggerHandler poline() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.PO_LINE_TRIGGERS;
		return this;
	}

	public OSCA_TriggerHandler notifyParty() {
		sObjHanlder = new SObjectHandler();
		sObjHanlder.oscaFieldName = 'OSCA_Location_Integration__c';
		sObjHanlder.fields = OSCA_OutboundFields.NOTIFY_PARTIES_TRIGGERS;
		return this;
	}

	private class SObjectHandler {
		String oscaFieldName;
		List<String> fields; 
	}
}