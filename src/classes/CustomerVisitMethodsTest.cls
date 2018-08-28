/**
 * Class contains methods that are using to test CustomerVisitMethods methods.<br>
 * Class's methods use methods from TestUtility to create test data.
 *
 * @version 1.0  2015.07.09  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see CustomerVisitMethods APEX class.
 * @see TestUtility APEX class.
 */

@isTest
public class CustomerVisitMethodsTest {

	public static testMethod void fillContactFieldsTest() {
		System.runAs(TestUtility.createUser('tester', null, true)) {
			List<Account> lDealers = new List<Account>();
			List<Account> lVisitors = new List<Account>();
			List<Contact> lContacts = new List<Contact>();

			List<Customer_Visit__c> lCustomerVisit = new List<Customer_Visit__c>();

			ID dealerRecordTypeID = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Business_Customer'].ID;
			ID personalAccountRecordTypeID = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount'].ID;

			Account dealer, visitor;
			Contact contact;

			for (Integer i = 0; i < 10; i++) {
				dealer = TestUtility.createAccount('Dealer#' + i, 'EUR', false);
				dealer.RecordTypeID = dealerRecordTypeID;
				
				visitor = new Account();
				visitor.RecordTypeID = personalAccountRecordTypeID;
				visitor.LastName = 'Visitor' + i;
				visitor.FirstName = 'Name' + i;

				lDealers.add(dealer);
				lVisitors.add(visitor);
			}

			insert lDealers;
			insert lVisitors;

			for (Integer i = 0; i < 10; i++) {
				contact = TestUtility.createContact('Contact#' + i, lDealers[i], false);
				contact.Book_Appointment_Contact__c = true;
				lContacts.add(contact);
			}

			insert lContacts;

			for (Integer i = 0; i < 10; i++) {
				lCustomerVisit.add(TestUtility.createCustomerVisit(lDealers[i].ID, lVisitors[i].ID, false));
			}

			Test.startTest();
			insert lCustomerVisit;

			Test.stopTest();

			for (Customer_Visit__c customerVisit : [SELECT ID, Dealer_Contact__c, Visitor_Contact__c FROM Customer_Visit__c]) {
				System.assert(!String.isBlank(customerVisit.Dealer_Contact__c));
				System.assert(!String.isBlank(customerVisit.Visitor_Contact__c));
			}
		}
	}
}