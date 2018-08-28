public class ContactTriggerHandler extends TriggerHandler {

	private static ContactTriggerHandler singleton;
	public static ContactTriggerHandler instance {
		get {
			if(singleton == null) {
				singleton = new ContactTriggerHandler();
			}
			return singleton;
		}
		private set;
	}

	protected override void handleAfterInsert() {
		CommunityUserFactory factory = new CommunityUserFactory(Trigger.new);
		factory.run();
	}

	protected override void handleAfterUpdate() {
		CommunityUserFactory factory = new CommunityUserFactory(Trigger.new);
		factory.run();
		PortalLanguageSync.instance.syncRelatedUsers(Trigger.new);
		new AccountInvoiceService()
			.assignNewInvoiceEmail((Map<Id,Contact>)Trigger.oldMap, (Map<Id,Contact>)Trigger.newMap);
	}
}