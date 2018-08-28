public without sharing class UserMethods {
	public static void grantAccountContactEditForPortalUsers(Set<Id> sUserIds) {
		List<SObject> newShares = new List<SObject>();
		List<User> users = [SELECT Id, Contact.AccountId, isActive FROM User WHERE Id IN : sUserIds AND Contact.AccountId != NULL];

		for(User currentUser : users) {
			if(currentUser.isActive){
				SObject newShare = ShareHandler.createShare(currentUser.Id, currentUser.Contact.AccountId, ShareHandler.EDITACCESSLEVEL, 'Account', 'Manual');
				newShare.put('CaseAccessLevel', ShareHandler.NONEACCESSLEVEL);
				newShare.put('OpportunityAccessLevel', ShareHandler.NONEACCESSLEVEL);
				newShares.add(newShare);
			}
		}
		if(newShares.size() > 0) {
			insert newShares;
		}
	}
}