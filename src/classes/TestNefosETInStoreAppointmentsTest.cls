@isTest
private class TestNefosETInStoreAppointmentsTest {

private static testmethod void ContactTriggerTest()

  {     

           insert new et4ae5__Configuration__c(et4ae5__Support_Ticket_Recipient__c = 'mbi@nefos.com');

           Test.startTest();

           Lead l = new Lead(LastName='TestExample', AnnualRevenue=666);

           // Insert lead

           insert l;

           // If no exceptions occurred, it was successful 

           System.assert(!String.isBlank(l.Id));

           Test.stopTest();

  }
}