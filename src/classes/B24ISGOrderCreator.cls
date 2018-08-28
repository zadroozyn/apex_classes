public class B24ISGOrderCreator extends B24DefaultOrderCreator {
    protected override PBSI__PBSI_Sales_Order__c createBaseOrder(Account accBuyer) {
		PBSI__PBSI_Sales_Order__c order = super.createBaseOrder(accBuyer);
        for(B24MessageWrapper.PropertyModel prop: messageOrder.properties) {
			if(prop.name == 'deliveryDate') {
                if(!String.isEmpty(prop.text)) {
                    String sDate = prop.text.split('T')[0];
                    order.PBSI__Due_Date__c = Date.valueOf(sDate);
                }
				
                break;
			} 
		}
        order.Sales_Order_Type__c = ORDER_TYPE_MAPPING.get(messageOrder.orderType);
		return order;
	}

    private static Map<String, String> ORDER_TYPE_MAPPING = new Map<String, String>{
        'PRE_ORDER' => 'Pre-order',
        'RE_ORDER' => 'Re-order',
        'BLOCK_ORDER' => 'Blockorder'
    };
}