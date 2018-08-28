public class MasterOrderTriggerHandler extends TriggerHandler {

    private static MasterOrderTriggerHandler singleton;
    
    public static MasterOrderTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new MasterOrderTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

	protected override void handleBeforeInsert() {
		populateFieldsFromAccount(Trigger.new);
	}

	protected override void handleAfterUpdate() {
		propagateDataToRelatedSOs(Trigger.newMap);
		handleRTChange(Trigger.oldMap, Trigger.newMap);
	}

	private void propagateDataToRelatedSOs(Map<Id, sObject> mapNew) {
		Map<Id, Master_order__c> mos = (Map<Id, Master_order__c>) mapNew;
		List<PBSI__PBSI_Sales_Order__c> rOrders = [SELECT Id, Master_order__c FROM PBSI__PBSI_Sales_Order__c WHERE Master_order__c IN : mapNew.keySet() FOR UPDATE];
		for(PBSI__PBSI_Sales_Order__c current : rOrders) {
			current.PBSI__Customer__c = mos.get(current.Master_order__c).Customer__c;
			current.PBSI__Contact__c = mos.get(current.Master_order__c).Customer_contact__c;
			current.PBSI__From_Location__c = mos.get(current.Master_order__c).From_Location__c;
			current.Pre_Order_Discount_override__c = mos.get(current.Master_order__c).Pre_order_discount__c;
			current.Early_bird_discount__c = mos.get(current.Master_order__c).Early_bird_discount__c;
			current.Visibility_discount__c = mos.get(current.Master_order__c).Visibility_discount__c;
			current.PBSI__Status__c = mos.get(current.Master_order__c).Status__c;
		}
		update rOrders;
	}

	private void handleRTChange(Map<Id, sObject> oldMap, Map<Id,sObject> newMap) {
		Map<Id, Master_order__c> oldOrders = (Map<Id, Master_order__c>) oldMap;
		Map<Id, Master_order__c> newOrders = (Map<Id, Master_order__c>) newMap;
		Set<Id> mOrders = new Set<Id>();
		for(Id current : newOrders.keySet()) {
			if(oldOrders.get(current).RecordTypeId != newOrders.get(current).RecordTypeId) {
				mOrders.add(current);
			}
		}
		List<PBSI__PBSI_Sales_order__c> orders;
		if(!mOrders.isEmpty()) {
			orders = [SELECT Id, Master_order__c, RecordTypeId FROM PBSI__PBSI_Sales_order__c WHERE Master_order__c IN : mOrders FOR UPDATE];
			for(PBSI__PBSI_Sales_order__c current : orders) {
				if(newOrders.get(current.Master_order__c).RecordTypeId == RecordTypeService.getRecordTypeIdByDeveloperName('Master_order__c', 'Proposal')) {
					current.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'Proposal');
				} else {
					current.RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_portal');
				}
			}
			update orders;
		}
	}

	private void populateFieldsFromAccount(List<Master_order__c> lNew) {
		List<Master_order__c> orders = (List<Master_order__c>) lNew;
		final Set<Id> accIds = new Set<Id>();
		for(Master_order__c current : orders) {
			accIds.add(current.Customer__c);
		}
		Map<Id, Account> mAccounts;
		if(!accIds.isEmpty()) {
			mAccounts = new Map<Id, Account>([SELECT Id, Pre_Order_Discount__c, On_Payment_Terms_Pre_Order__c, Automatic_location_id__c FROM Account WHERE Id IN: accIds]);
			for(Master_order__c current : orders) {
				Account t = mAccounts.get(current.Customer__c);
				current.Pre_order_discount__c = t.Pre_Order_Discount__c;
				current.On_Payment_Term__c = t.On_Payment_Terms_Pre_Order__c;
				current.From_location__c = t.Automatic_location_id__c;
			}
		}
	}
}