/**
 * Class contains methods that operates on Customer Visit records.<br>
 * 
 * @version 1.0  2015.07.09  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see CustomerVisitTriggerHandler APEX trigger.
 * @see Customer Visit (API: Customer_Visit__c) sObject.
 */

public with sharing class CustomerVisitMethods {

	/**
	 * Method used to fill Dealer Contact (API: Dealer_Contact__c) and 
	 * Visitor Contact (API: Visitor_Contact__c) fields.<br/>
	 * It is called from CustomerVisitTrigger on before insert event.
	 * 
	 * @param lCustomerVisits list of Customer Visit new records.
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
	 */
	public static void fillContactFields(List<Customer_Visit__c> lCustomerVisits) {
		Map<ID, ID> mDealerAccountIDToDealerContactID = new Map<ID, ID>();
		Map<ID, ID> mVisitorAccountIDToVisitorContactID = new Map<ID, ID>();

		// prepare maps
		for (Customer_Visit__c record : lCustomerVisits) {
			mDealerAccountIDToDealerContactID.put(record.Account__c, null);
			mVisitorAccountIDToVisitorContactID.put(record.Visitor_Account__c, null);
		}

		// retrieve dealer contacts
		for (Contact dealerContact : [SELECT ID, AccountID FROM Contact WHERE AccountID IN :mDealerAccountIDToDealerContactID.keySet() AND Book_Appointment_Contact__c = true]) {
			mDealerAccountIDToDealerContactID.put(dealerContact.AccountId, dealerContact.ID);
		}

		// retrieve visitor contacts
		for (Account visitor : [SELECT ID, PersonContactId FROM Account WHERE ID IN :mVisitorAccountIDToVisitorContactID.keySet()]) {
			mVisitorAccountIDToVisitorContactID.put(visitor.ID, visitor.PersonContactId);
		}

		// fill Visitor Contact fields
		for (Customer_Visit__c record : lCustomerVisits) {
			record.Dealer_Contact__c = mDealerAccountIDToDealerContactID.get(record.Account__c);
			record.Visitor_Contact__c = mVisitorAccountIDToVisitorContactID.get(record.Visitor_Account__c);
		}
	}
}