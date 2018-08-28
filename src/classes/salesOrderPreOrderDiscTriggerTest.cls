@isTest 
private class salesOrderPreOrderDiscTriggerTest {

      static testMethod void testMethod1() {

        //Create Test Data
        Account acc1 = new Account(Name = 'Test', Pre_Order_Discount__c = 20);
        insert acc1;


        Test.startTest();
        
        PBSI__PBSI_Sales_Order__c so1 = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);
        so1.Sales_Order_Type__c = 'Pre-Order';  
        insert so1;
        PBSI__PBSI_Sales_Order__c so2 = ([select Id, Pre_Order_Discount_New__c, Pre_Order_Discount_override__c from PBSI__PBSI_Sales_Order__c limit 1]);
        System.assertEquals(20, so2.Pre_Order_Discount_New__c);
        so2.Pre_Order_Discount_override__c = 30;
        update so2;        
        PBSI__PBSI_Sales_Order__c so3 = ([select Id, Pre_Order_Discount_New__c from PBSI__PBSI_Sales_Order__c limit 1]);
        System.assertEquals(30, so3.Pre_Order_Discount_New__c);        

        
                          
        Test.stopTest();
           
      }
      
      static testMethod void testMethod2() {
      
          //Create Test Data
          Account acc1 = new Account(Name = 'Test', Pre_Order_Discount__c = 20);
          insert acc1;
          
          Test.startTest();
          
          PBSI__PBSI_Sales_Order__c so4 = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);
          insert so4;
          PBSI__PBSI_Sales_Order__c so5 = ([select Id, Pre_Order_Discount_New__c from PBSI__PBSI_Sales_Order__c where Id = :so4.Id limit 1]);
          System.assertEquals(0, so5.Pre_Order_Discount_New__c);
   
          // Bulk Test
          List<PBSI__PBSI_Sales_Order__c> soList = new List<PBSI__PBSI_Sales_Order__c>();
          for (integer i=0;i<=50;i++){  // max 50 as any more causes another trigger to fail
            PBSI__PBSI_Sales_Order__c so = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=acc1.Id);  
            soList.add(so);
          }            
          insert soList;
         
          List<PBSI__PBSI_Sales_Order__c> soList2 = new List<PBSI__PBSI_Sales_Order__c>([select Id, Pre_Order_Discount_New__c, Pre_Order_Discount_override__c from PBSI__PBSI_Sales_Order__c]);        
          update soList;
          
          Test.stopTest();
      }

 
 
}