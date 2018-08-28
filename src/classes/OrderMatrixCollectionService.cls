public class OrderMatrixCollectionService {

	public Set<String> getCollectionTypes(String orderType) {
		boolean isBlank = String.isBlank(orderType);
		Set<String> othersCollections = new Set<String>();
		Set<String> typeCollections = new Set<String>();
		for(OM_collection_settings__c current : OM_collection_settings__c.getAll().values()) {
			if(String.isBlank(current.Sales_Orders_Types__c)) {
				othersCollections.add(current.Collection_type__c);
			} else {
				for(String cString : current.Sales_Orders_Types__c.split(';')) {
					if(cString == orderType) {
						typeCollections.add(current.Collection_type__c);
					}
				}
			}
		}
		if(typeCollections.isEmpty()) {
			typeCollections = othersCollections;
		}
		return typeCollections;
	}	
}