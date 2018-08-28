public class SalesInvoiceLineItemTriggerHandler extends TriggerHandler {
    
    public static SalesInvoiceLineItemTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new SalesInvoiceLineItemTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    private static SalesInvoiceLineItemTriggerHandler singleton;

	protected override void handleBeforeInsert() {
		new SalesInvoiceLineItemService().setInitialFieldValues((List<c2g__codaInvoiceLineItem__c>)Trigger.new);
	}
}