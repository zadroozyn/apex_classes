/**
 * Class contains methods that are using to test AttachmentTriggerHandler methods.<br/>
 * Class's methods use methods from TestUtility to create test data.
 * 
 * 
 * @version 1.0  2015.09.30  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see AttachmentTriggerHandler APEX class.
 * @see TestUtility APEX class.
 */

@isTest
public class AttachmentTriggerHandlerTests {
    
    /**
     * Method used to test methods from AttachmentTriggerHandler APEX class.
     */
    public static testMethod void handleAttachmentEvents() {
    	User tester = TestUtility.createUser('tester', null, true); // method creates an user that has System Administrator profile

    	System.runAs(tester) {

    		c2g__codaCompany__c company = TestUtility.createCompany(tester, 'CHF', 'CH');

			c2g__codaAccountingCurrency__c accountring_currency = [SELECT ID FROM c2g__codaAccountingCurrency__c WHERE c2g__OwnerCompany__c = :company.ID AND Name = 'CHF']; // It was created in TestUtility.createCompany(User, String, String) method.
			
            c2g__codaGeneralLedgerAccount__c general_ledger_account = TestUtility.createGeneralLedgerAccount('1100', false, 'Balance Sheet', 1, true);
			
            c2g__codaPeriod__c period = [SELECT ID FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c = :company.ID LIMIT 1]; // It was created in TestUtility.createCompany(User, String, String) method.
            
            Account account = TestUtility.createSupplierAccount(general_ledger_account.ID, 'CHF', 'Switzerland', true);
            
    		// Prepare test data like Payable Invoices and Attachments.
    		List<c2g__codaPurchaseInvoice__c> lPayableInvoices = new List<c2g__codaPurchaseInvoice__c>();
    		List<Attachment> lAttachments = new List<Attachment>(); 

    		c2g__codaPurchaseInvoice__c record;

    		for (Integer index = 0; index < 20; index++) {
    			lPayableInvoices.add(TestUtility.createPayableInvoice('Test_Invoice_No_' + index, company.OwnerId, account.ID, accountring_currency.ID, period.ID, false));
    		}

    		insert lPayableInvoices; // here I am getting error "The credit terms for the selected account on this document are not correctly defined."

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			lAttachments.add(TestUtility.createAttachment(invoice.ID, 'Invoice: ' + invoice.Name, 'Body of invoice', false));
    		}

    		Test.startTest();

    		insert lAttachments;
            
            for (Attachment document : lAttachments) {
                document.Name = document.Name + ' v1';
            }
            
            update lAttachments;
            
            delete lAttachments;
            
            undelete lAttachments;

    		Test.stopTest();
    	}	
    }
}