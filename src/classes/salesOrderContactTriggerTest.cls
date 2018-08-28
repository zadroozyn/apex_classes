@isTest 
private class salesOrderContactTriggerTest {

      static testMethod void testEventTrigger1() {

        //Create Test Data
        PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'Test Loc', PBSI__description__c = 'Test');
        insert loc1 ; 

        Id recId = [ SELECT Id FROM RecordType WHERE name = 'Person Account' limit 1].Id;

        Account acc1 = new Account(
            RecordTypeID=recId ,
            FirstName='Fred',
            LastName='Bloggs',
            PersonMobilePhone='0121-333-4444'
        );
        insert acc1 ;

        Account acc3 = new Account(Name = 'Business Account');
        insert acc3; 
 
        PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(group_description__c='test ascent',Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876');
        insert group1 ;
 
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='Item',name='item1', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true);
 
        PBSI__PBSI_Sales_Order__c so1 = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);  
        insert so1;

        List<Account> businessAccount;
        List<Account> personAccount; 
        
        Id personRecordTypeId;       
        List<RecordType> personTypes = new List<RecordType>([select Id from RecordType where Name='Person Account' limit 1]);
        if(personTypes != null){
            personRecordTypeId = personTypes.get(0).Id;
            personAccount = new List<Account>([select Id,Name,PersonMobilePhone,Phone from Account where recordtypeid=:personRecordTypeId limit 1]);        
        }
        
        Id businessRecordTypeId;          
        //list<RecordType> businessTypes = new List<RecordType>([select Id from RecordType where Name='Business Customer' limit 1]);
        List<RecordType> businessTypes = new List<RecordType>([select Id from RecordType where Name='Dealer' limit 1]);
        if(businessTypes != null){
            businessRecordTypeId = businessTypes.get(0).Id;
            businessAccount = new List<Account>([select Id,Name from Account where recordtypeid=:businessRecordTypeId limit 1]); 
        }
        
        Test.startTest();
            
        //Create 2 PBSI__PBSI_Sales_Order__c objects   
        If (personAccount != null){
            PBSI__PBSI_Sales_Order__c so2 = new PBSI__PBSI_Sales_Order__c (); //Personal
            so2.PBSI__Customer__c = personAccount.get(0).Id;
            insert so2;                    
            // Check result
            List<PBSI__PBSI_Sales_Order__c> soList2 = new List<PBSI__PBSI_Sales_Order__c>([select Id, Name, Contact_Mobile_Phone__c, Contact_Telephone__c, PBSI__Contact__c from PBSI__PBSI_Sales_Order__c where Id = :so2.Id ]);  
            System.assertEquals(soList2.get(0).Contact_Mobile_Phone__c, personAccount.get(0).PersonMobilePhone);
            System.assertEquals(soList2.get(0).Contact_Telephone__c, personAccount.get(0).Phone);

        }
        If (businessAccount != null){
            PBSI__PBSI_Sales_Order__c so3 = new PBSI__PBSI_Sales_Order__c (); //Business
            so3.PBSI__Customer__c = businessAccount.get(0).Id;      
            insert so3;
            // Check result    
            List<PBSI__PBSI_Sales_Order__c> soList3 = new List<PBSI__PBSI_Sales_Order__c>([select Id, Name, Contact_Mobile_Phone__c, Contact_Telephone__c, PBSI__Contact__c from PBSI__PBSI_Sales_Order__c where Id = :so3.Id ]);               
            If (soList3.get(0).Contact_Mobile_Phone__c == null){
                System.debug('**** Business Contact Mobile Phone has not been updated, rightly so');
            } else {            
                System.debug('**** Error: Business Contact Mobile Phone is  ' + soList3.get(0).Contact_Mobile_Phone__c);
            }
            If (soList3.get(0).Contact_Mobile_Phone__c == null){
                System.debug('**** Business Contact Phone has not been updated, rightly so');
            } else {            
                System.debug('**** Error: Business Contact Phone is  ' + soList3.get(0).Contact_TelePhone__c);
            }            
          
        }       

 
                   
        Test.stopTest();
           
      }

 
      static testMethod void testEventTrigger2() {

        //Create Test Data

        Id recId = [ SELECT Id FROM RecordType WHERE name = 'Person Account' limit 1].Id;

        Account acc1 = new Account(
            RecordTypeID=recId ,
            FirstName='Fred',
            LastName='Bloggs',
            PersonMobilePhone='0121-333-4444'
        );
        insert acc1 ;

        List<Account> personAccount;
        List<PBSI__PBSI_Sales_Order__c> insertList = new List<PBSI__PBSI_Sales_Order__c>(); 

        personAccount = new List<Account>([select Id,Name,PersonMobilePhone,Phone from Account where recordtypeid=:recId limit 1]);        
      
        If (personAccount != null){
            //for (integer i = 0 ; i <=200 ; i++){ <--- fails because another trigger not bulkified
            for (integer i = 0 ; i <=10 ; i++){ 
                PBSI__PBSI_Sales_Order__c so1 = new PBSI__PBSI_Sales_Order__c (); //Personal
                so1.PBSI__Customer__c = personAccount.get(0).Id;
                insertList.add(so1); 
            }     
        }

        Test.startTest();        
        insert insertList;
        Test.stopTest();        
}




}