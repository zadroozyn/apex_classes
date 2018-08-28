public class PurchaseOrderTriggerHandler extends TriggerHandler {

	private static PurchaseOrderTriggerHandler singleton;
    
    public static PurchaseOrderTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new PurchaseOrderTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleAfterInsert() {
        OSCA_TriggerHandler.Instance.po().insertListener(Trigger.new);
    }

    protected override void handleAfterUpdate() {
        OSCA_TriggerHandler.Instance.po().updateListener(Trigger.oldMap, Trigger.newMap);
    }
    
    protected override void handleBeforeInsert() {
        copyCurrencyIsoFromAccount(Trigger.new);
    }

    public static void copyCurrencyIsoFromAccount(list<PBSI__PBSI_Purchase_Order__c> lstPurchaseOrd){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, CurrencyIsoCode FROM Account WHERE ID IN : sObjectMethods.getValuesFromTextField(lstPurchaseOrd, 'PBSI__Account__c')]);
        for(PBSI__PBSI_Purchase_Order__c purchaseOrder : lstPurchaseOrd) {
            if(mAccounts.containsKey(purchaseOrder.PBSI__Account__c)) {
                purchaseOrder.CurrencyIsoCode = mAccounts.get(purchaseOrder.PBSI__Account__c).CurrencyIsoCode;
            }
        }
    }
}