public class OrderStageTriggerHandler extends TriggerHandler {

	private static OrderStageTriggerHandler singleton;
	public static OrderStageTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new OrderStageTriggerHandler();
            }
            return singleton;
        }
        private set;
    }


    protected override void handleBeforeInsert() {
    	copyCurrentTransmissionId(Trigger.new);
    }

    private static void copyCurrentTransmissionId(List<Order_Stage__c> lOrderStages) {
    	for(Order_Stage__c orderStage: lOrderStages) {
            if(String.isBlank(orderStage.Transmission_Id__c)) {
                orderStage.Transmission_Id__c = orderStage.Order_Current_Transmission_Id__c;
            }
    	}
    }
}