public class ItemTriggerHandler extends TriggerHandler {

	private static ItemTriggerHandler singleton;
    
    public static ItemTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new ItemTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleAfterInsert() {
        OSCA_TriggerHandler.Instance.item().insertListener(Trigger.new);
    }

    protected override void handleAfterUpdate() {
        OSCA_TriggerHandler.Instance.item().updateListener(Trigger.oldMap, Trigger.newMap);
    }
}