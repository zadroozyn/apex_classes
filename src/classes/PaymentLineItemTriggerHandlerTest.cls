/**
 * Class contains methods that are using to test PaymentLineItemTriggerHandler methods.<br/>
 * Class's methods use methods from TestUtility to create test data.
 *
 * @version 1.0  2015.11.18  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 *
 * @see PaymentLineItemTriggerHandler APEX class.
 * @see PaymentLineItemTriggers APEX trigger.
 * @see TestUtility APEX class.
 */

@isTest(SeeAllData=true)
public class PaymentLineItemTriggerHandlerTest {

	/**
	 * Method used to test PaymentLineItemTriggers events.
	 * It uses existing data, because there is no possibility to create them via Apex.
	 * FF didn't provode API.
	 */
	public static testMethod void unitTest() {
		System.runAs(TestUtility.createUser('tester', null, true)) {
			 c2g__codaPaymentLineItem__c paymentLineItem = [SELECT ID FROM c2g__codaPaymentLineItem__c LIMIT 1];
			 update paymentLineItem;
		}
	}
}