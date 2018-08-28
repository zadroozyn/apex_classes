public class UserTriggerHandler extends TriggerHandler {

	private static UserTriggerHandler singleton;
	public static UserTriggerHandler instance {
		get {
			if(singleton == null) {
				singleton = new UserTriggerHandler();
			}
			return singleton;
		}
		private set;
	}

	protected override void handleAfterInsert() {
		List<User> backstageUsers = getBackstageUsers(Trigger.new);
		if(!backstageUsers.isEmpty()) {
			BackstageShareService srv = new BackstageShareService();
			List<PBSI__PBSI_Sales_Order__share> soShares = srv.createSharesForUsers(backstageUsers, Schema.PBSI__PBSI_Sales_Order__c.sObjectType);
			List<c2g__codaInvoice__share> sinShares = srv.createSharesForUsers(backstageUsers, Schema.c2g__codaInvoice__c.sObjectType);
			list<c2g__codaCreditNote__c> scrShares = srv.createSharesForUsers(backstageUsers, Schema.c2g__codaCreditNote__c.sObjectType);
			insert soShares;
			insert sinShares;
			insert scrShares;
		}
		UserMethods.grantAccountContactEditForPortalUsers(Trigger.newMap.keySet());
	}

	protected override void handleAfterUpdate() {
		PortalLanguageSync.instance.syncRelatedContacts(Trigger.new);
	}

	private List<User> getBackstageUsers(List<User> input) {
		List<User> output = new List<User>();
		for(User current : input) {
			if(current.UserType == 'PowerCustomerSuccess') {
				output.add(current);
			}
		}
		return output;
	}
}