public class PurchaseOrderLineTriggerHandler extends TriggerHandler {

	private static PurchaseOrderLineTriggerHandler singleton;
    
    public static PurchaseOrderLineTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new PurchaseOrderLineTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
        copyOSCAIntegrationFromPO(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
        copyOSCAIntegrationFromPO(Trigger.new);
    }

    protected override void handleAfterInsert() {
        OSCA_TriggerHandler.Instance.poline().insertListener(Trigger.new);
    }

    protected override void handleAfterUpdate() {
        OSCA_TriggerHandler.Instance.poline().updateListener(Trigger.oldMap, Trigger.newMap);
    }

    private void copyOSCAIntegrationFromPO(List<PBSI__PBSI_Purchase_Order_Line__c> lPOLines) {
        for(PBSI__PBSI_Purchase_Order_Line__c poline: lPOLines) {
            poline.OSCA_integration__c = poline.OSCA_PO_Integration__c;
        }
    }
	
}