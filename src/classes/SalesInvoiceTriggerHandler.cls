public without sharing class SalesInvoiceTriggerHandler extends TriggerHandler {

	private static SalesInvoiceTriggerHandler instance;

	private SalesInvoiceTriggerHandler () {}

	public  static SalesInvoiceTriggerHandler getInstance () {
		if(instance == null) {
			SalesInvoiceTriggerHandler.instance = new SalesInvoiceTriggerHandler();
		}
		return instance;
	}

	protected override void handleBeforeInsert () {
		SalesInvoiceMethods.setFirstDueDate(Trigger.new);
		SalesInvoiceMethods.copyCommentFromSO(Trigger.new);
	}

	protected override void handleAfterInsert () {
		BackstageShareService srv = new BackstageShareService();
		insert srv.createSharesForObjects(Trigger.new, Schema.c2g__codaInvoice__c.sObjectType);
	}

	protected override void handleAfterUpdate () {
		SalesInvoiceMethods.recalculateSharesForPortalUsers(Trigger.oldMap, Trigger.newMap);
	}

}