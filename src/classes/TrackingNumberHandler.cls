public class TrackingNumberHandler extends TriggerHandler {
	private static TrackingNumberHandler singleton;
    
    public static TrackingNumberHandler Instance {
        get {
            if(singleton == null) {
                singleton = new TrackingNumberHandler();
            }
            return singleton;
        }
        private set;
    }   
    @TestVisible
    private static final List<String> trackingExceptionsAnyPlace = 
        new List<String> {'LKW','ABGEHOLT','Overland','Truck','To collect','Collected','Pallet'};
    @TestVisible
    private static final List<String> trackingExceptionsStartsWith = 
        new List<String> {'00'};

    protected override void handleBeforeInsert() {
    	markNotToSend(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
    	markNotToSend(filterChangedNumber(Trigger.oldMap,Trigger.newMap));
    }

    private void markNotToSend(List<Sobject> lTrackingNumbersNew) {
    	for(SObject sTrackingNo: lTrackingNumbersNew) {
    		Tracking_Number__c tNumber = (Tracking_Number__c) sTrackingNo;
    		tNumber.Do_Not_Send__c = isNotToSend(tNumber);
    	}
    }

    private List<Tracking_Number__c> filterChangedNumber(Map<Id,Sobject> mapTrackingsOld, Map<Id,Sobject> mapTrackingsNew) {
    	List<Tracking_Number__c> lChangedNumber = new List<Tracking_Number__c>();
    	for(Id key: mapTrackingsNew.keySet()) {
    		Tracking_Number__c tnOld = (Tracking_Number__c) mapTrackingsOld.get(key);
    		Tracking_Number__c tnNew = (Tracking_Number__c) mapTrackingsNew.get(key);
    		if(tnOld.Number__c != tnNew.Number__c) {
    			lChangedNumber.add(tnNew);
    		}
    	}
    	return lChangedNumber;
    }

    private Boolean isNotToSend(Tracking_Number__c tNumber) {
        for(String s: trackingExceptionsStartsWith) {
            if(tNumber.Number__c.startsWithIgnoreCase(s)) {
                return true;
            }
        }

        for(String s: trackingExceptionsAnyPlace) {
            if(tNumber.Number__c.containsIgnoreCase(s)) {
                return true;
            }
        }        
    	return false;
    }
}