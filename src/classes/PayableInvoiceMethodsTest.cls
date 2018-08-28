/**
 * Class contains methods that are using to test PayableInvoiceMethods methods.<br/>
 * Class's methods use methods from TestUtility to create test data.
 * 
 * 
 * @version 1.0  2015.09.17  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see PayableInvoiceMethods APEX class.
 * @see TestUtility APEX class.
 */

@isTest
public class PayableInvoiceMethodsTest {

	@testSetup public static void testSetup() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
		System.runAs(dc.testAdmin) {
			System.debug(dc.testAccount);
			System.debug(dc.testContact);
			System.debug(dc.testAdmin);
			System.debug(dc.testCompany);
			System.debug(dc.testCurrency);
			System.debug(dc.testPeriod);
		}
	}

	/**
     * Method used to test filling Invoice Document ID field of Payable Invoice with ID of given attachment.<br/>
     * Here is also tested AttachmentTrigger and AttachmentTriggerHandler that call 
     * PayableInvoiceMethods.fillNewInvoiceDocumentID(List<Attachment>) method when new Attachment record
     * is inserted to the data base and PayableInvoiceMethods.changeInvoiceDocumentID(List<Attachment>) method when
     * Attachment record is deleted.
     */
    public static testMethod void fillNewInvoiceDocumentIDTest() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();

    	System.runAs(dc.testAdmin) {
    		// Prepare test data like Payable Invoices and Attachments.
    		List<c2g__codaPurchaseInvoice__c> lPayableInvoices = new List<c2g__codaPurchaseInvoice__c>();
    		List<Attachment> lAttachments_1 = new List<Attachment>(); // initial Invoice documents.
    		List<Attachment> lAttachments_2 = new List<Attachment>(); // documents that will replace initial documents.
    		Set<ID> sPayableInvoiceIDs = new Set<ID>(); // technical set used to retrieve invoices from database.
    		List<Attachment> lAttachments_to_delete; // technical list used to select Attachment records to delete.

    		c2g__codaPurchaseInvoice__c record;

    		for (Integer index = 0; index < 20; index++) {
    			lPayableInvoices.add(TestUtility.createPayableInvoice('Test_Invoice_No_' + index, dc.testCompany.OwnerId, dc.testAccount.ID, dc.testCurrency.ID, dc.testPeriod.ID, false));
    		}

    		insert lPayableInvoices; // here I am getting error "The credit terms for the selected account on this document are not correctly defined."

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			lAttachments_1.add(TestUtility.createAttachment(invoice.ID, 'First invoice of ' + invoice.Name, 'Body of invoice', false));
    			lAttachments_2.add(TestUtility.createAttachment(invoice.ID, 'Second invoice of ' + invoice.Name, 'Body of invoice', false));
    			sPayableInvoiceIDs.add(invoice.ID);
    		}

    		Test.startTest();

    		// Case #1
    		// Input: Payable Invoice without any attachment. Invoice Document ID is empty.
    		// Description: New attachment is attached to the Payable Invoice.
    		// Expected Result: Invoice Document ID is filled with ID of new Attachment.
    		
    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		insert lAttachments_1;

    		lPayableInvoices = [SELECT ID, Invoice_Document_ID__c FROM c2g__codaPurchaseInvoice__c WHERE ID IN :sPayableInvoiceIDs];

    		for (Integer index = 0; index < lPayableInvoices.size(); index++) {
				System.assertEquals(lAttachments_1[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}

    		// Case #2
    		// Input: Payable Invoice with attachment. Invoice Document ID is filled.
    		// Description: New attachment is attached to the Payable Invoice.
    		// Expected Result: Invoice Document ID is replaced by ID of new Attachment.

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertNotEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		insert lAttachments_2;

    		lPayableInvoices = [SELECT ID, Invoice_Document_ID__c FROM c2g__codaPurchaseInvoice__c WHERE ID IN :sPayableInvoiceIDs];

    		for (Integer index = 0; index < lPayableInvoices.size(); index++) {
				System.assertEquals(lAttachments_2[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}

    		// Case #3
    		// Input: Payable Invoice with more than two attachments. Invoice Document ID is filled.
    		// Description: Later attachment is deleted.
    		// Expected Result: Invoice Document ID is filled with ID of Attachment that is still in related list.

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertNotEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		lAttachments_to_delete = new List<Attachment>();

    		// delete Attachment from 10 first records only.
    		for (Integer index = 0; index < 10; index++) {
    			lAttachments_to_delete.add(lAttachments_2.get(index));
    		}

    		delete lAttachments_to_delete;

    		lPayableInvoices = [SELECT ID, Invoice_Document_ID__c FROM c2g__codaPurchaseInvoice__c WHERE ID IN :sPayableInvoiceIDs];

    		for (Integer index = 0; index < 10; index++) {
				System.assertEquals(lAttachments_1[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}
            
            for (Integer index = 10; index < 20; index++) {
				System.assertEquals(lAttachments_2[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}

    		// Case #4
    		// Input: Payable Invoice with more than two attachments. Invoice Document ID is filled.
    		// Description: First attachment is deleted.
    		// Expected Result: Invoice Document ID is not changed.

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertNotEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		lAttachments_to_delete = new List<Attachment>();

    		// delete Attachment from 10 last records only.
    		for (Integer index = 10; index < 20; index++) {
    			lAttachments_to_delete.add(lAttachments_1.get(index));
    		}

    		delete lAttachments_to_delete;

    		lPayableInvoices = [SELECT ID, Invoice_Document_ID__c FROM c2g__codaPurchaseInvoice__c WHERE ID IN :sPayableInvoiceIDs];

    		for (Integer index = 0; index < 10; index++) {
				System.assertEquals(lAttachments_1[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}
            
            for (Integer index = 10; index < 20; index++) {
				System.assertEquals(lAttachments_2[index].ID, lPayableInvoices[index].Invoice_Document_ID__c);
    		}

    		// Case #5
    		// Input: Payable Invoice with one attachment. Invoice Document ID is filled.
    		// Description: Attachment is deleted.
    		// Expected Result: Invoice Document ID is empty.

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertNotEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		lAttachments_to_delete = [SELECT ID FROM Attachment WHERE ParentID IN : sPayableInvoiceIDs];

    		delete lAttachments_to_delete;

    		lPayableInvoices = [SELECT ID, Invoice_Document_ID__c FROM c2g__codaPurchaseInvoice__c WHERE ID IN :sPayableInvoiceIDs];

    		for (c2g__codaPurchaseInvoice__c invoice : lPayableInvoices) {
    			System.assertEquals(null, invoice.Invoice_Document_ID__c);
    		}

    		Test.stopTest();
    	}	
    }

	@isTest private static void testAllowSingleRejectionWithComment() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
    	System.runAs(dc.testAdmin) {
			c2g__codaPurchaseInvoice__c invoice = dc.createPIN(1, dc.testAdmin.Id);
			insert invoice;
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			psr.setObjectId(invoice.Id);
			approval.processresult pr = approval.process(psr);
			System.assert(pr.isSuccess(), 'There was a problem with submitting record to Approval Process');
			Id workItemId = pr.getNewWorkItemIds()[0];
			Approval.ProcessWorkItemRequest pwir = new Approval.ProcessWorkItemRequest();
			pwir.setComments('Rejecting with comment');
			pwir.setAction('Reject');
			pwir.setWorkItemId(workItemId);
			Test.startTest();
			Approval.ProcessResult finalpr = Approval.process(pwir); 
			Test.stopTest();
			System.assert(finalpr.isSuccess(), 'Rejection with comment should go through');
			System.assertEquals('Rejected', finalpr.getInstanceStatus(), 'Rejection should has been successful');
		}
	}

	@isTest private static void testPreventSingleRejectionWithoutComment() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
    	System.runAs(dc.testAdmin) {
			c2g__codaPurchaseInvoice__c invoice = dc.createPIN(1, dc.testAdmin.Id);
			insert invoice;
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			psr.setObjectId(invoice.Id);
			approval.processresult pr = approval.process(psr);
			System.assert(pr.isSuccess(), 'There was a problem with submitting record to Approval Process');
			Id workItemId = pr.getNewWorkItemIds()[0];
			Approval.ProcessWorkItemRequest pwir = new Approval.ProcessWorkItemRequest();
			pwir.setAction('Reject');
			pwir.setWorkItemId(workItemId);
			Test.startTest(); // Process the rejection 
			try {
				Approval.ProcessResult finalpr = Approval.process(pwir); 
				System.assert(false, 'Rejection with empty comment shouldn\'t go through');
			} catch (DMLException e) {
				System.assertEquals(System.Label.Pins_Rejection_Error_No_Comment, e.getDMLMessage(0) , 'Error message should be: ' + System.Label.Pins_Rejection_Error_No_Comment);
			}
			Test.stopTest(); // Verify the rejection results 
		}
	}

	@isTest static void testFillPaymentDate(){
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
    	System.runAs(dc.testAdmin) {
			c2g__codaPurchaseInvoice__c invoice = dc.createPIN(1, dc.testAdmin.Id);
			insert invoice;
			Date testDate = Date.today().addDays(10);
			final Map<String, Date> testMap = new Map<String, Date>();

			Test.startTest();
			testMap.put(dc.testPins.get(invoice.Id).Name, testDate);
			PayableInvoiceMethods.fillPaymentDate(testMap);
			Test.stopTest();

			System.assertEquals(dc.testPins.get(invoice.Id).Payment_Date__c, testDate, 'Dates should be equal');
		}
		
	}

    private static final String VALID_ESR = '\'310877000000000000000155671';
    private static final String INVALID_ESR = '310877000000000000000155675';
    private static final String NAN_ESR = '01-P-98';

    @isTest static void esrNumberValidationPositive() {
        PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
        dc.testAccount.Payment_System__c = 'POST-ESR';
        update dc.testAccount;

        System.runAs(dc.testAdmin) {
            c2g__codaPurchaseInvoice__c invoicePositive = dc.createPIN(1, dc.testAdmin.Id);
            invoicePositive.Recipient_Bank_Number__c = VALID_ESR;
            insert invoicePositive;
            System.assertEquals(
                true,[
                SELECT ESR_Validation_Required__c FROM c2g__codaPurchaseInvoice__c WHERE Id = :invoicePositive.Id].ESR_Validation_Required__c
            );
        }
        System.assertEquals(1,[SELECT count() FROM c2g__codaPurchaseInvoice__c]);
    }

    @isTest static void esrNumberValidationNegativeInvalid() {
        PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
        dc.testAccount.Payment_System__c = 'POST-ESR';
        update dc.testAccount;
        
        System.runAs(dc.testAdmin) {
            Boolean insertErr = false;
            c2g__codaPurchaseInvoice__c invoiceNegative = dc.createPIN(1, dc.testAdmin.Id);
            invoiceNegative.Recipient_Bank_Number__c = INVALID_ESR;
            try {
                insert invoiceNegative;
            } catch (Exception e) {
                insertErr = true;
            }
            System.assert(insertErr);

            invoiceNegative.Recipient_Bank_Number__c = VALID_ESR;
            insert invoiceNegative;

            System.assertEquals(
                true,
                [SELECT ESR_Validation_Required__c FROM c2g__codaPurchaseInvoice__c WHERE Id = :invoiceNegative.Id].ESR_Validation_Required__c
            );

            Boolean updateErr = false;
            invoiceNegative.Recipient_Bank_Number__c = INVALID_ESR;
            try {
                update invoiceNegative;
            } catch (Exception e) {
                updateErr = true;
            }
            System.assert(updateErr);
        }
    }

    @isTest static void esrNumberValidationNegativeInvalidNAN() {
        PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
        dc.testAccount.Payment_System__c = 'POST-ESR';
        update dc.testAccount;
        System.runAs(dc.testAdmin) {
            Boolean insertErr = false;
            c2g__codaPurchaseInvoice__c invoiceNegative = dc.createPIN(1, dc.testAdmin.Id);
            invoiceNegative.Recipient_Bank_Number__c = NAN_ESR;
            try {
                insert invoiceNegative;
            } catch (Exception e) {
                insertErr = true;
            }
            System.assert(insertErr);
        }
    }

    @isTest static void esrNumberValidationNOTRequired() {
        PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
        System.runAs(dc.testAdmin) {
            Boolean insertErr = false;
            c2g__codaPurchaseInvoice__c invoice = dc.createPIN(1, dc.testAdmin.Id);
            invoice.Recipient_Bank_Number__c = NAN_ESR;
            insert invoice;
            System.assertEquals(
                false,
                [SELECT ESR_Validation_Required__c FROM c2g__codaPurchaseInvoice__c WHERE Id = :invoice.Id].ESR_Validation_Required__c
            );
        }
    }
}