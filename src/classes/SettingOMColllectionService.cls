public class SettingOMColllectionService {

	private Map<String, Map<String, OM_Collection_Settings__c>> orderTypesToCollections;

	public SettingOMColllectionService () {
		this.setupCollectionMap(OM_collection_settings__c.getAll().values());
	}

	private void setupCollectionMap(List<OM_Collection_Settings__c> allSettings) {
		for(OM_Collection_Settings__c current : allSettings) {
			if(String.isBlank(current.Sales_orders_types__c)) {
					this.putValueInMainMap('default', current.Collection_type__c.toLowerCase(), current);
			} else {
				for(String currentString : current.Sales_orders_types__c.split(';')) {
					this.putValueInMainMap(currentString.toLowerCase(), current.Collection_type__c.toLowerCase(), current);
				}
			}
		}
	}

	private void putValueInMainMap (String orderKey, String collectionKey, OM_Collection_Settings__c collection) {
		if(this.orderTypesToCollections == null) {
			this.orderTypesToCollections = new Map<String, Map<String, OM_Collection_Settings__c>>();
		}
		if(!this.orderTypesToCollections.containsKey(orderKey)) {
			this.orderTypesToCollections.put(orderKey, new Map<String, OM_Collection_Settings__c>());
		}
		this.orderTypesToCollections.get(orderKey).put(collectionKey, collection);
	}


	public Set<String> getCollectionsForOrderType(String orderType) {
		if(String.isBlank(orderType)) {
			return orderTypesToCollections.get('default').keySet();
		}
		return orderTypesToCollections.get(orderType.toLowerCase()).keySet();
	}

	public Map<String, String> getColorsForCollectionAndOrder (String collectionType, String orderType) {
		if(!orderTypesToCollections.containsKey(orderType.toLowerCase()) || !orderTypesToCollections.get(orderType.toLowerCase()).containsKey(collectionType.toLowerCase())) {
			return null;
		}
		OM_Collection_Settings__c current = orderTypesToCollections.get(orderType.toLowerCase()).get(collectionType.toLowerCase());
		Map<String, String> output = new Map<String, String>();
		output.put('quantity0', current.Less_than_5__c);
		output.put('quantity1', current.Between_5_and_10__c);
		output.put('quantity2', current.More_than_10__c);
		return output;
	}

	public boolean shouldCollectionBeChecked(String collectionType, String orderType) {
		if(!orderTypesToCollections.containsKey(orderType.toLowerCase()) || !orderTypesToCollections.get(orderType.toLowerCase()).containsKey(collectionType.toLowerCase())) {
			return false;
		}
		if(orderTypesToCollections.get(orderType.toLowerCase()).get(collectionType.toLowerCase()).Primary__c) {
			return true;
		} else if (orderTypesToCollections.get(orderType.toLowerCase()).get(collectionType.toLowerCase()).Secondary__c) {
			for(OM_Collection_Settings__c current : orderTypesToCollections.get(orderType.toLowerCase()).values()) {
				if(current.Primary__c) {
					return false;
				}
			}
			return true;
		}
		return false;
	}
}