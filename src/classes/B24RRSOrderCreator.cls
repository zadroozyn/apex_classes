public class B24RRSOrderCreator extends B24DefaultOrderCreator {
	protected override PBSI__PBSI_Sales_Order__c createBaseOrder(Account accBuyer) {
		PBSI__PBSI_Sales_Order__c order = super.createBaseOrder(accBuyer);
		order.Packing_instructions__c = 'RRS DROP SHIP';
		List<Contact> lContacts = [SELECT Id,Email FROM Contact WHERE Name = 'RRS DROP SHIP' ORDER BY CreatedDate ASC LIMIT 1];
		if(!lContacts.isEmpty()) {
			order.PBSI__Contact__c = lContacts[0].Id;
			order.PBSI__Contact_Email__c = lContacts[0].Email;
		}
		return order;
	}
}