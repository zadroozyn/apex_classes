public class TrackingService {

	private List<Tracking__c> baseList;

	private Map<Id, PBSI__PBSI_Sales_Order__c> mapSalesOrders {
		get {
			if(mapSalesOrders == null) {
				mapSalesOrders = getSalesOrders();
			}
			return mapSalesOrders;
		}
		set;
	}
	
	public TrackingService(List<Tracking__c> lTrackings) {
		baseList = lTrackings;
	}

	public void fillContactIfEmpty() {
		List<Tracking__c> lTrackings = getTrackingWithoutContact();
		for(Tracking__c tracking: lTrackings) {
			tracking.Contact__c = mapSalesOrders.get(tracking.Sales_Order__c).PBSI__Contact__c;
		}
	}

	public void fillServiceProviderIfEmpty() {
		List<Tracking__c> lTrackings = getTrackingWithoutProvider();
		for(Tracking__c tracking: lTrackings) {
			PBSI__PBSI_Location__c loaction = mapSalesOrders.get(tracking.Sales_Order__c).PBSI__From_Location__r;
			if(loaction != null) {
				String serviceProvider = CCMapHelper.getCompanyId(
					loaction.Country_Company_Map__c,
                   	mapSalesOrders.get(tracking.Sales_Order__c).PBSI__Delivery_Country__c
                );
                //TODO: in future field loaction.Shipment_Provider__c should be removed
                //and all values should be moved to map (as default)
				tracking.Service_Provider__c = 
					!String.isBlank(serviceProvider) ? serviceProvider : loaction.Shipment_Provider__c;
			}
		}
	}

	public void fillTrackingLinks() {
		for(Tracking__c tracking: baseList) {
			tracking.Tracking_Link_Base__c = getLinkBase(tracking);
		}
	}

	private List<Tracking__c> getTrackingWithoutContact() {
		return filterEmptyField('Contact__c');
	}

	private List<Tracking__c> getTrackingWithoutProvider() {
		return filterEmptyField('Service_Provider__c');
	}

	private List<Tracking__c> filterEmptyField(String fieldName) {
		List<Tracking__c> lTrackingsFieldEmpty = new List<Tracking__c>();
		for(Tracking__c tracking: baseList) {
			if(tracking.get(fieldName) == null) {
				lTrackingsFieldEmpty.add(tracking);
			}
		}
		return lTrackingsFieldEmpty;
	}

	private Map<Id, PBSI__PBSI_Sales_Order__c> getSalesOrders() {
		Set<String> sSalesOrdersIds = getValuesSet('Sales_Order__c');
		return new Map<Id, PBSI__PBSI_Sales_Order__c>(
			[SELECT Id,PBSI__Contact__c,PBSI__From_Location__c,PBSI__Delivery_Country__c,
             	PBSI__From_Location__r.Shipment_Provider__c,
                PBSI__From_Location__r.Country_Company_Map__c 
				FROM PBSI__PBSI_Sales_Order__c 
				WHERE Id IN :sSalesOrdersIds]
		);
	}

	private Set<String> getValuesSet(String fieldName) {
		Set<String> sValues = new Set<String>();
		for(Tracking__c tracking: baseList) {
			Object oVal = tracking.get(fieldName);
			if(oVal != null) {
				String sVal = String.valueOf(oVal);
				if(!String.isBlank(sVal)) {
					sValues.add(sVal);
				}
			}
		}
		return sValues;
	}

	private String getLinkBase(Tracking__c tracking) {
		String linkUrl = '';
		if(!String.isBlank(tracking.Service_Provider__c)) {
			Tracking_Providers__c provider = Tracking_Providers__c.getInstance(tracking.Service_Provider__c);
			if(provider != null) {
				linkUrl = provider.Base_Url__c;
			} 
		}
		return linkUrl;
	}
}