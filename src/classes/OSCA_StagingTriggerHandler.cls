public class OSCA_StagingTriggerHandler extends TriggerHandler {
	private static OSCA_StagingTriggerHandler singleton;
    
    public static OSCA_StagingTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new OSCA_StagingTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
    	generateUniqueId(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
    	generateUniqueId(Trigger.new);
    }

    private void generateUniqueId(List<OSCA_Staging__c> lStagings) {
    	for(OSCA_Staging__c staging: lStagings) {
    		staging.UniqueId__c = staging.RecordTypeId + staging.Object_Id__c + String.valueOf(staging.Processing__c);
    	}
    }
}