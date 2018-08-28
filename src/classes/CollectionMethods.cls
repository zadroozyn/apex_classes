public class CollectionMethods {

	public static void ensureUniquenessOfCollectionType(Map<Id, Collection__c> mCollectionNew){
		Set<Id> locations = new Set<Id>();
		for(Collection__c current : mCollectionNew.values()) {
			if(current.Collection_type__c == 'active') {
				locations.add(current.Location__c);
			}
		}
		Map<Id, Set<String>> locations2Types = new Map<Id, Set<String>>();
		for(Collection__c current : [SELECT Id, Location__c, Collection_Type__c FROM Collection__c WHERE Status__c =: 'Active' AND Id NOT IN: mCollectionNew.keySet()]) {
			if(!locations2Types.containsKey(current.Location__c)) {
				locations2Types.put(current.Location__c, new Set<String>());
			}
			locations2Types.get(current.Location__c).add(current.Collection_Type__c);
		}

		for(Collection__c current : mCollectionNew.values()) {
			if(locations2Types.containsKey(current.Location__c) && locations2Types.get(current.Location__c).contains(current.Collection_type__c)) {
				current.addError(System.label.Collection_type_duplicate_error_msg);
			}
		}
	}

	/**
	 * Method process all active collections, changes collection type according to values in Adapt_Collections_Mapping__c custom settings
	 * Additionally, active collections with collection same as specified in custom label Collection_Type_To_Archive will be archived.
	 */
	public static void adaptCollectionsForNewSeason(){
		Map<String, Adapt_Collections_Mapping__C> mapping = Adapt_Collections_Mapping__c.getAll();

		List<Collection__c> collectionsToProcess = [SELECT Id, Collection_type__c, Status__c 
													FROM Collection__c 
													WHERE Status__c = : System.Label.Collection_status_active];

		if(!(collectionsToProcess.size()>0)){
			return;
		}
		for(Collection__C currentCollection : collectionsToProcess){
			if(currentCollection.Collection_type__c.equalsIgnoreCase(System.Label.Collection_Type_To_Archive)){
				currentCollection.Status__C = System.Label.Collection_status_archived;
			} else if(!(mapping.get(currentCollection.Collection_type__c) == NULL)){
				currentCollection.Collection_type__c = mapping.get(currentCollection.Collection_type__c).Map_to__c;
			}
		}

		update collectionsToProcess;
	}
}