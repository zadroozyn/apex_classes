@isTest public class PayableCreditNoteMethodsTest {

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

	@isTest private static void testAllowSingleRejectionWithComment() {
		PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();
    	System.runAs(dc.testAdmin) {
			c2g__codaPurchaseCreditNote__c note = dc.createPCR(1, dc.testAdmin.Id);
			insert note;
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			psr.setObjectId(note.Id);
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
			c2g__codaPurchaseCreditNote__c note = dc.createPCR(1, dc.testAdmin.Id);
			insert note;
			Approval.ProcessSubmitRequest psr = new Approval.ProcessSubmitRequest();
			psr.setObjectId(note.Id);
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

	/*@isTest private static void testDeletion() {*/
		/*PayableInvoiceTestUtility.DataCreator dc = new PayableInvoiceTestUtility.DataCreator();*/
        /*System.runAs(dc.testAdmin) {*/
			/*c2g__codaPurchaseCreditNote__c note = dc.createPCR(1, dc.testAdmin.Id);*/
			/*insert note;*/
			/*Test.startTest(); // Process the rejection */
			/*delete note;*/
			/*Test.stopTest(); // Verify the rejection results */
			/*System.assertEquals(0, dc.testPcrs.size(), 'There should be no PCR in the system.');*/
		/*}*/
	/*}*/

}