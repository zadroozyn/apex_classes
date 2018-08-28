public class JournalLineItemTriggerHandler extends TriggerHandler {

    private static JournalLineItemTriggerHandler singleton;
    
    public static JournalLineItemTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new JournalLineItemTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

	protected override void handleBeforeInsert() {
		new JournalLineItemService().setInitialFieldValues((List<c2g__codaJournalLineItem__c>)Trigger.new);
	}
}