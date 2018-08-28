public class TransferOrderTriggerHandler extends TriggerHandler {
	private static TransferOrderTriggerHandler singleton;
    
    public static TransferOrderTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new TransferOrderTriggerHandler();
                singleton.mapAccId2ShippingAddress = new Map<Id, AddressWrapper>();
            }
            return singleton;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
    	copyDeliveryAddress(Trigger.new);
    	copyUltimateCosigneeAddress(Trigger.new);
    }

    protected override void handleBeforeUpdate() {
    	copyDeliveryAddress(Trigger.oldMap, Trigger.newMap);
    	copyUltimateCosigneeAddress(Trigger.oldMap, Trigger.newMap);
    }

    private void copyDeliveryAddress(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    	List<PBSI__Transfer_Order__c> lTransferOrdersChanged = new List<PBSI__Transfer_Order__c>();
    	for(Id key: oldMap.keySet()) {
    		PBSI__Transfer_Order__c toOld = (PBSI__Transfer_Order__c) oldMap.get(key);
    		PBSI__Transfer_Order__c toNew = (PBSI__Transfer_Order__c) newMap.get(key);
    		if(toOld.Delivery_Party_Account__c != toNew.Delivery_Party_Account__c) {
    			lTransferOrdersChanged.add(toNew);
    		}
    	}
    	copyDeliveryAddress(lTransferOrdersChanged);
    }

    private void copyUltimateCosigneeAddress(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
    	List<PBSI__Transfer_Order__c> lTransferOrdersChanged = new List<PBSI__Transfer_Order__c>();
    	for(Id key: oldMap.keySet()) {
    		PBSI__Transfer_Order__c toOld = (PBSI__Transfer_Order__c) oldMap.get(key);
    		PBSI__Transfer_Order__c toNew = (PBSI__Transfer_Order__c) newMap.get(key);
    		if(toOld.Ultimate_Cosignee_Account__c != toNew.Ultimate_Cosignee_Account__c) {
    			lTransferOrdersChanged.add(toNew);
    		}
    	}
    	copyUltimateCosigneeAddress(lTransferOrdersChanged);
    }

    private void copyDeliveryAddress(List<PBSI__Transfer_Order__c> lTransferOrders) {
    	Set<Id> accIds = new Set<Id>();
    	for(PBSI__Transfer_Order__c to: lTransferOrders) {
    		accIds.add(to.Delivery_Party_Account__c);
    	}
    	addAccountsToAddressMap(accIds);
    	for(PBSI__Transfer_Order__c to: lTransferOrders) {
    		if(to.Delivery_Party_Account__c != null) {
    			AddressWrapper addrWrap = mapAccId2ShippingAddress.get(to.Delivery_Party_Account__c);
    			to.Address_Line_1__c = addrWrap.getLine1();
    			to.Address_Line_2__c = addrWrap.getLine2();
    			to.City__c = addrWrap.getCity();
    			to.Country__c = addrWrap.getCountry();
    			to.Postal_Code__c = addrWrap.getPostalCode();
    			to.State__c = addrWrap.getState();
    		}
    	}
    }

    private void copyUltimateCosigneeAddress(List<PBSI__Transfer_Order__c> lTransferOrders) {
    	Set<Id> accIds = new Set<Id>();
    	for(PBSI__Transfer_Order__c to: lTransferOrders) {
    		accIds.add(to.Ultimate_Cosignee_Account__c);
    	}
    	addAccountsToAddressMap(accIds);
    	for(PBSI__Transfer_Order__c to: lTransferOrders) {
    		if(to.Ultimate_Cosignee_Account__c != null) {
	    		AddressWrapper addrWrap = mapAccId2ShippingAddress.get(to.Ultimate_Cosignee_Account__c);
    			to.UC_Address_Line_1__c = addrWrap.getLine1();
    			to.UC_Address_Line_2__c = addrWrap.getLine2();
    			to.UC_City__c = addrWrap.getCity();
    			to.UC_Country__c = addrWrap.getCountry();
    			to.UC_Postal_Code__c = addrWrap.getPostalCode();
    			to.UC_State__c = addrWrap.getState();
    		}
    	}
    }

    private void addAccountsToAddressMap(Set<Id> accIds) {
    	Set<Id> relevantAccIds = accIds.clone();
    	relevantAccIds.removeAll(mapAccId2ShippingAddress.keySet());
    	if(!relevantAccIds.isEmpty()) {
    		List<Account> lAccs = [SELECT Id,ShippingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState
    			FROM Account WHERE Id IN :relevantAccIds];
    		for(Account acc: lAccs) {
    			mapAccId2ShippingAddress.put(acc.Id, new AddressWrapper(acc));
    		}
    	}
    }

    public class AddressWrapper {

    	private Account acc;
    	private String line1;
    	private String line2;

    	public String getLine1() {
    		return line1;
    	}

    	public String getLine2() {
    		return line2;
    	}

    	public String getCity() {
    		return acc.ShippingCity;
    	}

    	public String getCountry() {
    		return acc.ShippingCountry;
    	}

    	public String getPostalCode() {
    		return acc.ShippingPostalCode;
    	}

    	public String getState() {
    		return acc.ShippingState;
    	}

    	public AddressWrapper(Account acc) {
    		this.acc = acc;
    		if(!String.isBlank(acc.ShippingStreet)) {
    			List<String> streetParts = acc.ShippingStreet.split('\n');
    			line1 = streetParts[0];
    			line2 = '';
    			for(Integer i=1; i<streetParts.size(); i++) {
    				line2 += ' ' + streetParts[i];
    			}
    			line2.trim();
			} else {
				line1 = '';
				line2 = '';
			}
    	}
    }

    private Map<Id, AddressWrapper> mapAccId2ShippingAddress;
}