public class PaymentTermsTriggerHandler extends TriggerHandler {
    private static PaymentTermsTriggerHandler singleton;

    public static PaymentTermsTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new PaymentTermsTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
    	recalcDays(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
    	recalcDays( filterFieldsChanged(Trigger.oldMap, Trigger.newMap, new Set<String> {'End_Next_Month__c','X90_Days_Month_End__c'}) );
    }

    private static List<SObject> filterFieldsChanged(Map<Id,SObject> mapObjsOld, Map<Id,SObject> mapObjsNew, Set<String> fNames) {
        List<SObject> lObjsChanged = new List<On_Payment_Terms__c>();
        for(String key: mapObjsOld.keySet()) {
            SObject objOld = mapObjsOld.get(key);
            SObject objNew = mapObjsNew.get(key);

            Boolean change = false;
            for(String fName: fNames) {
                if(objOld.get(fName) != objNew.get(fName)) {
                    change = true;
                    break;
                }
            }
            if(change) {
                lObjsChanged.add(objNew);
            }
        }
        return lObjsChanged;
    }

    private static void recalcDays(List<On_Payment_Terms__c> lPaymentTerms) {
    	List<On_Payment_Terms__c> lPaymentTermsEndNextMonth = new List<On_Payment_Terms__c>();
    	for(On_Payment_Terms__c pt: lPaymentTerms) {
    		if(pt.End_Next_Month__c || pt.X90_Days_Month_End__c) {
    			lPaymentTermsEndNextMonth.add(pt);
    		}
    	}
    	PaymentTermsDaysCalc calcHelper = new PaymentTermsDaysCalc();
    	calcHelper.recalculateDaysToEndTerm(lPaymentTermsEndNextMonth);
    }
}