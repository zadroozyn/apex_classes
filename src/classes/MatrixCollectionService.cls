public class MatrixCollectionService {

	public List<OM_collection_settings__c> getCollectionSettings(String orderType) {
		boolean isBlank = String.isBlank(orderType);
		List<OM_collection_settings__c> othersCollections = new List<OM_collection_settings__c>();
		List<OM_collection_settings__c> typeCollections = new List<OM_collection_settings__c>();
		for(OM_collection_settings__c current : OM_collection_settings__c.getAll().values()) {
			if(String.isBlank(current.Sales_Orders_Types__c)) {
				othersCollections.add(current);
			} else {
				for(String cString : current.Sales_Orders_Types__c.split(';')) {
					if(cString == orderType) {
						typeCollections.add(current);
					}
				}
			}
		}
		if(typeCollections.isEmpty()) {
			typeCollections = othersCollections;
		}
		return typeCollections;
	}

	public Set<String> getCollectionTypes(String orderType) {
		Set<String> types = new Set<String>();
		for(OM_collection_settings__c current : this.getCollectionSettings(orderType)) {
			types.add(current.Collection_type__c);
		}
		return types;
	}	

	private Map<Id, String> getItemIdsPerCollectionType  (List<Collection_item__c> citems, Map<Id, MatrixDataBuilder.Item> items) {
		Map<Id, String> item2ctype = new Map<Id, String>();
		Map<String, String> groupandfabrictoctype = new Map<String, String>();
		Map<String, Collections_order__c> cOrder = Collections_order__c.getAll();
		for(Collection_item__c current : citems) {
			if(!groupandfabrictoctype.containsKey('' + current.Item_Group__c + current.Fabric_code__c)
				|| cOrder.get(groupandfabrictoctype.get('' + current.Item_Group__c + current.Fabric_code__c)).Collection_number__c < cOrder.get(current.Collection__r.Collection_type__c).Collection_number__c) {
				groupandfabrictoctype.put('' + current.Item_Group__c + current.Fabric_code__c, current.Collection__r.Collection_type__c);
			} 
		}
		for(MatrixDataBuilder.Item current : items.values()) {
			item2ctype.put(current.itemId, groupandfabrictoctype.get('' + current.groupId + current.fabricId));
		}
		return item2ctype;
	}

	public Map<Id, MatrixDataBuilder.Item> getIndicatorForItem(Map<Id, MatrixDataBuilder.Item> items, List<Collection_item__c> citems, String orderType) {
		Map<Id, String> item2ctype = this.getItemIdsPerCollectionType(citems, items);
		Map<String, OM_collection_settings__c> settings = new Map<String, OM_collection_settings__c>();
		Map<String, OM_collection_settings__c> oSettings = new Map<String, OM_collection_settings__c>();
		for(OM_collection_settings__c current : OM_collection_settings__c.getAll().values()) {
			if(String.isBlank(current.Sales_Orders_Types__c)) {
				oSettings.put(current.Collection_type__c, current);
			} else {
				for(String cString : current.Sales_Orders_Types__c.split(';')) {
					if(cString == orderType) {
						settings.put(current.Collection_type__c, current);
					}
				}
			}
		}
		if(settings.isEmpty()) {
			settings = oSettings;
		}
		for(MatrixDataBuilder.Item current : items.values()) {
			if(settings.containsKey(item2ctype.get(current.itemId))) {
				OM_collection_settings__c cSetting= settings.get(item2ctype.get(current.itemId));
				if(current.atp > 10) {
					current.color = cSetting.More_than_10__c.toLowerCase();
				} else if( current.atp > 0) {
					current.color = cSetting.Between_5_and_10__c.toLowerCase();
				} else {
					current.color = cSetting.Less_than_5__c.toLowerCase();
				}
			} else {
				current.color = 'Gray';
			}
			current.atp = null;
		}
		return items;
	}
}