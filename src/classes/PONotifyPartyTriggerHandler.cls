public class PONotifyPartyTriggerHandler extends TriggerHandler {

	private static PONotifyPartyTriggerHandler singleton;
    
    public static PONotifyPartyTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new PONotifyPartyTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleAfterInsert() {
        OSCA_TriggerHandler.Instance.notifyParty().insertListenerOnChild(Trigger.new, 'Location__c');
    }

    protected override void handleAfterUpdate() {
        OSCA_TriggerHandler.Instance.notifyParty().updateListenerOnChild(Trigger.oldMap, Trigger.newMap, 'Location__c');
    }

}