public class KN_OrderFactory {
	private static Id notificationTOrt = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_TO');

    public KN_Order order(Order_Stage__c orderStage) {
    	if(orderStage.RecordTypeId == notificationTOrt) {
    		return new KN_OrderTOCreator.OrderStage(orderStage, orderStage.Transfer_Order__r, orderStage.Shipped_Transfer_Lines__r);
   		} else {
    		return new KN_OrderSOCreator.OrderStage(orderStage, orderStage.Sales_Order__r, orderStage.Shipped_Sales_Order_Lines__r);
   		}
    }

}