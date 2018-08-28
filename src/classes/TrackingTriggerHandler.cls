public class TrackingTriggerHandler extends TriggerHandler {
	
	private static TrackingTriggerHandler singleton;
    
    public static TrackingTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new TrackingTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
    	TrackingService srvHelper = new TrackingService(
            filterTrackingsForSO(Trigger.new)
        );
    	srvHelper.fillContactIfEmpty();
    	srvHelper.fillServiceProviderIfEmpty();
    	srvHelper.fillTrackingLinks();
    }

    private static List<Tracking__c> filterTrackingsForSO(List<Tracking__c> lTrackings) {
        List<Tracking__c> lTrackingsFiltered = new List<Tracking__c>();
        for(Tracking__c t: lTrackings) {
            if(t.Is_Sales_Order__c) {
                lTrackingsFiltered.add(t);
            }
        }
        return lTrackingsFiltered;
    }

}