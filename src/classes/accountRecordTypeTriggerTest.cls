@isTest 
private class accountRecordTypeTriggerTest {

      static testMethod void testTriggerMethod1() {
//system.debug('*************     IN TEST METHOD 1 ************');
//        //Create Test Data

//        Id inactiveRecordId = [ SELECT Id FROM RecordType WHERE sObjectType = 'Account' and Name = 'Inactive Account' limit 1].Id;
//system.debug('****** Inactive record id = ' + inactiveRecordId);         
//        Id activeRecordId = [ SELECT Id FROM RecordType WHERE sObjectType = 'Account' and Name = 'Dealer' limit 1].Id;
//system.debug('****** Active record id = ' + activeRecordId ); 

//        Account acc1 = new Account(
//        RecordTypeID=inactiveRecordId ,
//        Name = 'Fred Bloggs',
//        Account_Type__c = 'Inactive');            
//        insert acc1 ;

//        Account acc2 = new Account(
//        RecordTypeID=activeRecordId ,
//        Name='John Bloggs',
//        Account_Type__c = 'Active');
//        insert acc2 ;

//        List<Account> accList;

//        Test.startTest();
//system.debug('******************  TEST 1 CHANGING IT **********************');        
//        accList = new List<Account>([select Id, Name, Account_Type__c, RecordTypeId from Account]);
//        for(Account acc:accList){
//            System.debug('****** Before update : Account/Account Type/Record Type Id  : ' + acc.Name + '  /  ' + acc.Account_Type__c + '  /  ' + acc.RecordTypeId);
//            if (acc.Account_Type__c == 'Inactive'){
//                acc.Account_Type__c = 'Active';                
//            }else {
//                acc.Account_Type__c = 'Inactive';
//            }            
//        }                
//        update accList;
//system.debug('******************  TEST 2 PUTTING IT BACK **********************');          
//        accList = [select Id, Name, Account_Type__c, RecordTypeId from Account];       
//        for(Account acc:accList){
//           System.debug('****** Before putting back : Account/Account Type/Record Type Id  : ' + acc.Name + '  /  ' + acc.Account_Type__c + '  /  ' + acc.RecordTypeId);        
//            if (acc.Account_Type__c == 'Inactive'){
//                acc.Account_Type__c = 'Active';                
//            }else {
//                acc.Account_Type__c = 'Inactive';
//            }  
//        }           
//        update accList;            
//        accList = [select Id, Name, Account_Type__c, RecordTypeId from Account];       
//        for(Account acc:accList){
//System.debug('****** FINAL RESULT : Account/Account Type/Record Type Id  : ' + acc.Name + '  /  ' + acc.Account_Type__c + '  /  ' + acc.RecordTypeId);        
//        }    
                   
//        Test.stopTest();
           
      }

 
}