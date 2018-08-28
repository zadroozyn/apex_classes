public class CommunityUserFactory {

	final private List<Contact> inputContacts;
	final private Map<Id, User> existingCommunityUsers;
	final private List<User> newUsers;
	final private Map<Id, boolean> uidToStatus;
	final private OrganizationService org;
	final private Map<Id, Account> accounts;

	private Id dealerProfileId;
	private Id distributorProfileId;


	public CommunityUserFactory (List<Contact> input) {
		inputContacts = input;
		accounts = selectAccounts(input);
		existingCommunityUsers = getExistingUsersMap(input);
		getProfileIds();
		newUsers = new List<User>();
		uidToStatus = new Map<Id, boolean>();
		org = OrganizationService.getInstance();
	}

	public void run () {
		processContacts();
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
		insert newUsers;
		updateUsersInFuture();
		insertUPLs();
	}

	public void processContacts () {
		for(Contact c : inputContacts) {
			if (!String.isBlank(c.Function__c) && c.Function__c.containsIgnoreCase('b2b-portal-user') && !existingCommunityUsers.containsKey(c.Id)) {
				newUsers.add(createUser(c));
			} else if (!String.isBlank(c.Function__c) && c.Function__c.containsIgnoreCase('b2b-portal-user') && existingCommunityUsers.containsKey(c.Id)) {
				processExistingUser(existingCommunityUsers.get(c.Id), true);
			} else if (existingCommunityUsers.containsKey(c.Id) && (String.isBlank(c.Function__c) || !c.Function__c.containsIgnoreCase('b2b-portal-user'))) {
				processExistingUser(existingCommunityUsers.get(c.Id), false);
			}
		}
	}

	public List<User> getNewUsers() {
		return newUsers;
	}

	public void insertUPLs() {
		if(!newUsers.isEmpty()) {
			final Set<Id> userIds = new Set<Id>();
			for(User u : newUsers) {
				userIds.add(u.Id);
			}
		}
	}

	public Set<Id> getUserIdsToUpdate() {
		return uidToStatus.keySet();
	}

	public void updateUsersInFuture () {
		if(!uidToStatus.isEmpty()){
			CommunityUserFactory.updateUsersInFuture(uidToStatus);
		}
	}

	private void processExistingUser (User u, boolean shouldBe) {
		if(u.isActive != shouldBe) {
			uidToStatus.put(u.Id, shouldBe);
		}
	}

	private User createUser (Contact c) {
		if(accounts.get(c.AccountId).IsDistributor__c) {
			return createUser(c, distributorProfileId);
		}
		return createUser(c, dealerProfileId);
	}

	private User createUser (Contact c, Id profileId) {
		User u = new User();
		u.Username = getUsername(c);
		u.ContactId = c.Id;
		u.FirstName = c.FirstName;
		u.LastName = c.LastName;
		u.Email = c.Email;
		u.ProfileId = profileId;
		u.EmailEncodingKey = 'UTF-8';
		u.Alias = getAlias(c);
		u.LanguageLocaleKey = String.isBlank(c.Portal_users_language__c) ? 'en_US' : c.Portal_users_language__c;
		u.LocalesIdKey = String.isBlank(c.Portal_user_locale__c) ? 'en_US' : c.Portal_user_locale__c;
		u.TimeZonesIdKey = 'Europe/Berlin';
		return u;
	}

	private String getUsername(Contact c) {
		String returnValue  = '';
		if(!String.isBlank(c.FirstName)){
			returnValue += c.FirstName +'.';
		}
		returnValue += c.LastName;
		returnValue = returnValue.deleteWhitespace();
		returnValue += Label.B2B_Portal_Username_Suffix;
		if(org.isSandbox) {
			returnValue += '.test';
		}
		return returnValue;
	}

	private String getAlias(Contact c) {
		String returnValue = '';
		if(!String.isBlank(c.FirstName)){
			returnValue += c.FirstName.left(4);
		}
		returnValue += c.LastName.left(4);
		return returnValue;
	}

	private Map<Id, Account> selectAccounts (List<Contact> input) {
		final Set<Id> accountIds = new Set<Id>();
		for(Contact current : input) {
			accountIds.add(current.AccountId);
		}
		return new Map<Id, Account>([SELECT Id, IsDistributor__c FROM Account WHERE Id IN : accountIds]);
	}

	private Map<Id, User> getExistingUsersMap (List<Contact> input) {
		final Map<Id, User> returnMap = new Map<Id,User> ();
		for(User u : [SELECT Id, isActive, ContactId FROM User WHERE ContactId IN : input]) {
			returnMap.put(u.ContactId, u);
		}
		return returnMap;
	}

	private void getProfileIds() {
		final List<Profile> profileIds = [SELECT Id, Name FROM Profile WHERE Name IN (:'Backstage Dealer', :'Backstage Distributor') ORDER BY Name];
		this.dealerProfileId = profileIds[0].Id;
		this.distributorProfileId = profileIds[1].Id;
	}

	@future
	private static void updateUsersInFuture(Map<Id, boolean> uidToStatus) {
		final List<User> users = new List<User>();
		for(User u : [SELECT Id, IsActive FROM User WHERE Id IN : uidToStatus.keySet()]) {
			u.isActive = uidToStatus.get(u.Id);
			users.add(u);
		}
		update users;
	}
}