public class SalesPlanningTriggerHandler extends TriggerHandler {
    private static SalesPlanningTriggerHandler singleton;
    
    public static SalesPlanningTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new SalesPlanningTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
        assignUniqueId(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
        assignUniqueId(Trigger.oldMap, Trigger.newMap);
    }

    private static void assignUniqueId(List<Sales_Planning__c> lSalesPlanning) {
        for(Sales_Planning__c sp: lSalesPlanning) {
            sp.UniqueId__c = (String)sp.Account__c + (String)sp.Item__c + (String) sp.Sales_Season__c + (String) sp.Sales_Channel__c+ (String) sp.RecordTypeId;
        }
    }

    private static void assignUniqueId(Map<Id,SObject> mapSObjOld, Map<Id,SObject> mapSObjNew) {
        Set<String> sFields = new Set<String> {'Account__c','Item__c','Sales_Season__c','Sales_Channel__c','UniqueId__c','RecordTypeId'};
        List<Sales_Planning__c> lSalesPlanning = filterFieldsChanged(mapSObjOld, mapSObjNew, sFields);
        assignUniqueId(lSalesPlanning);
    }

    private static List<SObject> filterFieldsChanged(Map<Id,SObject> mapSObjOld, Map<Id,SObject> mapSObjNew, Set<String> fNames) {
        List<SObject> lObjsChanged = new List<SObject>();
        for(String key: mapSObjOld.keySet()) {
            SObject objOld = mapSObjOld.get(key);
            SObject objNew = mapSObjNew.get(key);

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
}