public class B24PSGOrderCreator extends B24DefaultOrderCreator {
	private static final String PSG_WEB_DROP_PREFIX = 'O-';
	public override B24SObjectCreatorBase.ParentChildren createSObjectImpl(B24MessageWrapper.MessageModel message, String messageId) {
		B24SObjectCreatorBase.ParentChildren orderWithLines = super.createSObjectImpl(message, messageId);
		PBSI__PBSI_Sales_order__c order = (PBSI__PBSI_Sales_order__c) orderWithLines.parent;
		if(order.PBSI__Customer_Purchase_Order__c != null && order.PBSI__Customer_Purchase_Order__c.startsWithIgnoreCase(PSG_WEB_DROP_PREFIX)) {
			order.B2B_Return_Info__c = true;
		}
		return orderWithLines;
	}
}