public class LocationTriggerHandler extends TriggerHandler {

	private static LocationTriggerHandler singleton;
    
    public static LocationTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new LocationTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

	protected override void handleAfterInsert() {
        OSCA_TriggerHandler.Instance.location().insertListener(Trigger.new);
    }

    protected override void handleAfterUpdate() {
        OSCA_TriggerHandler.Instance.location().updateListener(Trigger.oldMap, Trigger.newMap);
    }

}