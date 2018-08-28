public class SalesSeasonTriggerHandler extends TriggerHandler {
	private static SalesSeasonTriggerHandler singleton;
    
    public static SalesSeasonTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new SalesSeasonTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    public override void handleBeforeInsert() {
    	setName(Trigger.new);
    }

    public override void handleBeforeUpdate() {
    	setName(Trigger.new);
    }

    private void setName(List<Sales_Season__c> lSeasons) {
    	for(Sales_Season__c season: lSeasons) {
    		season.Name = season.Season__c + season.Year__c;
    	}
    }
}