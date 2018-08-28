public with sharing class BackstageService {

	final public User contextUser { get; private set; }
	final public BackstageCaseService bcs { get; private set; }

	public Id selectedObjectId {get; set;}

	public BackstageService () {
		this.contextUser = selectCurrentUser();
		this.bcs = new BackstageCaseService(this);
	}

	public BackstageService (Id userId) {
		if(!isStandardUser()) {
			throw new BackstageServiceException ('Only standard users can access this page.');
		}
		this.contextUser = selectUser(userId);
		this.bcs = new BackstageCaseService(this);
	}

	private User selectCurrentUser () {
		return selectUser(UserInfo.getUserId());
	}

	private User selectUser (Id userId) {
		return [SELECT Id, ContactId, AccountId FROM User WHERE Id =: userId LIMIT 1];
	}

	private boolean isStandardUser () {
		return Userinfo.getUserType() == 'Standard';
	}

	public class BackstageServiceException extends Exception {}
}