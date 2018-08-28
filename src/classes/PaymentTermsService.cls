public class PaymentTermsService {

	@TestVisible
	private List<PBSI__PBSI_Sales_Order__c> lSalesOrders;
	@TestVisible
	private static Set<String> salesOrdersTypesDefaultPreOrderTerms = new Set<String>{
		'Pre-Order',
		'Blockorder',
		'Forecast'
	};

	@TestVisible private Static Map<Id, Master_Order__c> mOrderHelper;
	
	public PaymentTermsService(List<PBSI__PBSI_Sales_Order__c> lSalesOrders) {
		this.lSalesOrders = lSalesOrders;
		if(mOrderHelper == null) {
			mOrderHelper = getMOrderHelper(lSalesOrders);
		}
	}

	public void assignPaymentTerms() {
		for(PBSI__PBSI_Sales_Order__c so: lSalesOrders) {
			System.debug(mOrderHelper);
			if(mOrderHelper.get(so.Master_Order__c) != null) {
				so.On_Payment_Term__c = mOrderHelper.get(so.Master_Order__c).On_Payment_Term__c;
			} else if(salesOrdersTypesDefaultPreOrderTerms.contains(so.Sales_Order_Type__c) && so.Account_PreOrder_Payment_Terms__c != null) {
				so.On_Payment_Term__c = so.Account_PreOrder_Payment_Terms__c;
			} else {
				so.On_Payment_Term__c = so.Account_Default_Payment_Terms__c;
			}
		}
	}

	public static List<PBSI__PBSI_Sales_Order__c> filterRevelantChanges(Map<Id,SObject> mapSalesOrdersOld, Map<Id,SObject> mapSalesOrdersNew) {
		List<PBSI__PBSI_Sales_Order__c> lSalesOrdersFiltered = new List<PBSI__PBSI_Sales_Order__c>();
		if(mOrderHelper == null) {
			mOrderHelper= getMOrderHelper(mapSalesOrdersNew.values());
		}
        for(Id key: mapSalesOrdersNew.keySet()) {
            PBSI__PBSI_Sales_Order__c soOld = (PBSI__PBSI_Sales_Order__c) mapSalesOrdersOld.get(key);
            PBSI__PBSI_Sales_Order__c soNew = (PBSI__PBSI_Sales_Order__c) mapSalesOrdersNew.get(key);

            if(soOld.Sales_Order_Type__c != soNew.Sales_Order_Type__c 
            	&& (salesOrdersTypesDefaultPreOrderTerms.contains(soOld.Sales_Order_Type__c) || salesOrdersTypesDefaultPreOrderTerms.contains(soNew.Sales_Order_Type__c)) 
            	|| soNew.On_Payment_Term__c == null
				|| (String.isNotBlank(soNew.Master_Order__c) && soNew.On_Payment_Term__c != mOrderHelper.get(soNew.Master_Order__c).On_Payment_Term__c)) {
                lSalesOrdersFiltered.add(soNew);
            }
        }
        return lSalesOrdersFiltered;	
	}

	private static Map<Id, Master_Order__c> getMOrderHelper(List<PBSI__PBSI_Sales_Order__c> orders) {
		System.debug(orders);
		Map<Id, Master_Order__c> output = new Map<Id, Master_Order__c>();
		Set<Id> mOrderIds = new Set<Id>();
		for(PBSI__PBSI_Sales_Order__c current : orders) {
			mOrderIds.add(current.Master_order__c);
		}
		mOrderIds.remove(null);
		final Map<Id, Master_order__c> mOrders = new Map<Id, Master_Order__c>();
		if(!mOrderIds.isEmpty()) {
			output.putAll([SELECT Id, On_Payment_Term__c FROM Master_Order__c WHERE Id IN: mOrderIds]);
		}
		return output;
	}
}