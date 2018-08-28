public class PortalLanguageSync {

	private static PortalLanguageSync singleton;
	public static PortalLanguageSync instance {
		get {
			if(singleton == null) {
				singleton = new PortalLanguageSync();
			}
			return singleton;
		}
		private set;
	}

	public Set<Id> syncedContacts;
	public Set<Id> syncedUsers;

	private PortalLanguageSync() {
		syncedContacts = new Set<Id>();
		syncedUsers = new Set<Id>();
	}

	public void syncRelatedContacts(List<User> users) {
		List<Contact> relatedContacts = new List<Contact>();
		Set<Id> uIds = new Set<Id>();
		Set<Id> cIds = new Set<Id>();
		for(User current : users) {
			if(current.ContactId != null && (!syncedUsers.contains(current.Id) && !syncedContacts.contains(current.ContactId))) {
				uIds.add(current.Id);
				cIds.add(current.ContactId);
				relatedContacts.add(new Contact(Id = current.ContactId, Portal_users_language__c = current.LanguageLocaleKey));
			}
		}
		save(relatedContacts, uIds, cIds);
	}

	public void syncRelatedContacts(Set<Id> users) {
		this.syncRelatedContacts([SELECT Id, ContactId, LanguageLocaleKey FROM User WHERE Id IN : users]);
	}

	public void syncRelatedUsers(List<Contact> contacts) {
		Map<Id, Contact> mContacts = new Map<Id, Contact>(contacts);
		List<User> users = [SELECT Id, ContactId, LanguageLocaleKey FROM User WHERE ContactID IN : mContacts.keySet()];
		List<User> relatedUsers = new List<User>();
		Set<Id> uIds = new Set<Id>();
		Set<Id> cIds = new Set<Id>();
		for(User current : users) {
			if(mContacts.containsKey(current.ContactId)
				&& mContacts.get(current.ContactId).Portal_users_Language__c != current.LanguageLocaleKey
				&& (!syncedUsers.contains(current.Id) && !syncedContacts.contains(current.ContactId))) {
				uIds.add(current.Id);
				cIds.add(current.ContactId);
				relatedUsers.add(new User(Id = current.Id, LanguageLocaleKey = mContacts.get(current.ContactId).Portal_users_language__c));
			}
		}
		save(relatedUsers, uIds, cIds);
	}

	private void save(List<sObject> relatedObjects, Set<Id> processedUIds, Set<Id> processedCIds) {
		//LogService log = LogService.getLogService();
		syncedUsers.addAll(processedUIds);
		syncedContacts.addAll(processedCIds);
		try {
			update relatedObjects;
			system.debug('saving');
			system.debug(relatedObjects);
		} catch (Exception e) {
			//log.addError().exception(e);
			syncedContacts.removeAll(processedCIds);
			syncedUsers.removeAll(processedUIds);
		} finally {
			//log.save();
		}
	}

	public void syncRelatedUsers(Set<Id> contacts) {
		this.syncRelatedUsers([SELECT Id, Portal_Users_language__c FROM Contact WHERE Id IN : contacts]);
	}
}