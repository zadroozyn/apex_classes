/**
 * Test class for the UpdateContactsFunction batch job.
 */
@isTest
private class UpdateContactsFunctionTest {
	

	@testSetup
	static void setup(){   
	}

    /**
     * Method tests UpdateContacts functionality. 
     * @return [description]
     */
	@isTest static void testUpdateContacts() {
		
		List<Contact> contacts = TestUtility.createContactsWithFunctions();
		Test.startTest();
        UpdateContactsFunction ucf = new UpdateContactsFunction();
    
        Id batchId = Database.executeBatch(ucf);
        Test.stopTest();
      
        List<Id> ids = new List<Id>();
        for (Contact c: contacts){
              ids.add(c.id);
        }

        List<Contact> results = [select FUNCTION__C from Contact where id = :ids ];
    
        System.assertEquals(null, results.get(0).FUNCTION__C);
        System.assertEquals(ContactFunctions.BUYER, results.get(1).FUNCTION__C);
        System.assertEquals(ContactFunctions.DEPARTMENT_MANAGER, results.get(2).FUNCTION__C);
        System.assertEquals(ContactFunctions.ACCOUNTING, results.get(3).FUNCTION__C);
        System.assertEquals(ContactFunctions.SHOP_ASSISTANT, results.get(4).FUNCTION__C);
        System.assertEquals(ContactFunctions.STORE_MANAGER, results.get(5).FUNCTION__C);
        System.assertEquals((ContactFunctions.STORE_MANAGER+';'+ContactFunctions.BUYER), 
        	results.get(6).FUNCTION__C);
        System.assertEquals(ContactFunctions.OWNER, results.get(7).FUNCTION__C);
        System.assertEquals(ContactFunctions.OWNER + ';' +ContactFunctions.STORE_MANAGER, 
        	results.get(8).FUNCTION__C);
        System.assertEquals( ContactFunctions.STORE_MANAGER + ';' + ContactFunctions.B2B_PORTAL_USER, 
        	results.get(9).FUNCTION__C);
       
	}

    /**
     * Method inserts one account and one contact. Then tries to updatre contac'sy function to the B2B-Portal-User. 
     * DML excepton occurs, and processErrors method on UpdateContactsFunction is called. New Error_log__c record 
     * is inserted.
     */
    @isTest static void testUpdateContactsWithErrors() {
        Account acc = TestUtility.createAccount('Test', null, true);
        Contact b2bInvalidContact = TestUtility.createContact('b2bInvalidContact', acc, true);
        
        // create and error
        b2bInvalidContact.Function__c = 'B2B-Portal-User';
        UpdateContactsFunction ucf = new UpdateContactsFunction();
        List<Contact> contacts= new List<Contact>();
        contacts.add(b2bInvalidContact);
        Database.SaveResult[] saveResults = Database.update(contacts, false);
    
        // Id batchId = Database.executeBatch(ucf);
        // Create invalid contact
        ucf.processErrors(null, saveResults, contacts);
        Integer noOfErrors = [select count() from Error_Log__c ];
        System.assertEquals(1, noOfErrors);
    }

    @isTest static void testUpdateContactsException() {
        ContactFunctionUpdateException testEx = new ContactFunctionUpdateException('Exception message');
        System.assertEquals('Exception message', testEx.getMessage());
    }
}