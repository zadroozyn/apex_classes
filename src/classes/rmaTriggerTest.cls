@isTest 
private class rmaTriggerTest {

      static testMethod void testMethod1() {

        //Create Test Data
        PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'Test Loc', PBSI__description__c = 'Test');
        insert loc1 ; 

        Id recId = RecordTypeService.getRecordTypeIdByDeveloperName('Account','Business_Customer');

        Account acc1 = new Account(
            RecordTypeID=recId ,
           // FirstName='Fred',
            //LastName='Bloggs',
            Name='Accounttest'
            //PersonMobilePhone='0121-333-4444'
        );
        insert acc1 ;
 
        PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(group_description__c='test ascent',Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876');
        insert group1 ;
 
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(PBSI__Item_Type__c='Item',name='item1', PBSI__purchaseprice__c = 50, PBSI__salesprice__c = 100, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true);
        item1.EAN_Number__c = 'Test Item 1';
        insert item1;
 
        PBSI__PBSI_Sales_Order__c so1 = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);  
        insert so1;
    
                     
        PBSI__PBSI_Sales_Order_Line__c soLine = new PBSI__PBSI_Sales_Order_Line__c();   
        soLine.PBSI__Sales_Order__c = so1.Id;    
        soLine.PBSI__Item__c = item1.Id;    
        soLine.PBSI__Quantity_Needed__c = 65; 
        insert soLine;
  
        Case cs = new Case();
        insert cs;

        Test.startTest(); 
                
        // Insert
        List<PBSI__RMA_Lines__c> rmaLines = new List<PBSI__RMA_Lines__c>();     
        for(integer i=0;i<200;i++){
            PBSI__RMA_Lines__c rma = new PBSI__RMA_Lines__c();
            rma.PBSI__Sales_Order_Line__c = soLine.Id; 
            rma.PBSI__RMA__c = cs.Id;
            rma.PBSI__Quantity_Received__c = 2;
            rmaLines.add(rma);   
        }
        insert rmaLines;       
         
        List<Case> caseList1 = new List<Case>([select Id, Subtotal__c from Case limit 1]);
        Case cs1 = caseList1[0];
system.debug('**** TEST    Case Subtotal = ' + cs1.Subtotal__c);

        //Update
        List<PBSI__RMA_Lines__c> rmaList = new List<PBSI__RMA_Lines__c>([select Id from PBSI__RMA_Lines__c]);
        update rmaList;     
            // Check result
        List<Case> caseList2 = new List<Case>([select Id, Subtotal__c from Case limit 1]);
        Case cs2 = caseList2[0];
system.debug('**** TEST    Case Subtotal = ' + cs2.Subtotal__c);
            //System.assertEquals(soList2.get(0).Contact_Telephone__c, personAccount.get(0).Phone);

        //Delete
        List<PBSI__RMA_Lines__c> rmaList2 = new List<PBSI__RMA_Lines__c>([select Id from PBSI__RMA_Lines__c]);
        delete rmaList2;  
        List<Case> caseList3 = new List<Case>([select Id, Subtotal__c from Case limit 1]);
        Case cs3 = caseList3[0];
system.debug('****TEST Case Subtotal = ' + cs3.Subtotal__c);
               
        Test.stopTest();
           
      }

}