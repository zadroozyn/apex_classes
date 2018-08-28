public class CollectionTriggerHandler extends TriggerHandler {
	private static CollectionTriggerHandler singleton;

	public static CollectionTriggerHandler Instance {
		get {
			if(singleton == null) {
				singleton = new CollectionTriggerHandler();
			}
			return singleton;
		}
		private set;
	}

	protected override void handleAfterInsert() {
		CollectionMethods.ensureUniquenessOfCollectionType((Map<Id, Collection__c>)Trigger.newMap);
	}

	protected override void handleAfterUpdate() {
		CollectionMethods.ensureUniquenessOfCollectionType((Map<Id, Collection__c>)Trigger.newMap);
	}
}