@isTest
public with sharing class TestBatchAtp {
    static testMethod void myUnitTest() {
        
         PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
 PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
          
                insert loc1 ; 
                insert loc2;
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
           
           // try {
                insert acc1; 
           // }
           // catch(DmlException e) {
             //       System.debug(e.getMessage());
            // } 
                
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',Group_Description__c='grp1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(name='itemmb1',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112288');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(name='itemmb12',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf1', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,EAN_Number__c='112277');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='itemmb2', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112266');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='itemmb3', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf3', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112255');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='itemmb31', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf31', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112244');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='itemmb4', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf4', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112233');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
//            try {
                insert items ;
  //          }
    //        catch(DmlException e) {
      //          System.debug(e.getMessage()); 
        //    }
            /*
               PBSI.bomController bc=new PBSI.bomController(new ApexPages.StandardController(item12));
            bc.newLine();
            bc.lines[0].line.PBSI__Item__c=item3.Id;
            bc.lines[0].line.PBSI__Quantity__c=1;
          
             bc.saveChanges();
       */
        
         
       
         PBSI__Lot__c defaultlotitem2= new PBSI__Lot__c(PBSI__Item__c=item2.Id,PBSI__Location__c=loc1.Id); 
          PBSI__Lot__c defaultlotitem3=new PBSI__Lot__c(PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
          PBSI__Lot__c defaultlotitem4=new PBSI__Lot__c(PBSI__Item__c=item4.Id,PBSI__Location__c=loc1.Id);
          
        
         insert defaultlotitem2;insert defaultlotitem3;insert defaultlotitem4; 
       
       
      PBSI__Lot__c lot1=new PBSI__Lot__c(Name='secondlot',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot2=new PBSI__Lot__c(Name='xcccccccccccc',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot3=new PBSI__Lot__c(Name='te',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      //insert lot1;insert lot2;insert lot3;
      PBSI__Lot__c[] lots = new PBSI__Lot__c[]{lot1,lot2,lot3};
       PBSI__PBSI_Inventory__c inv2=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item2.Id,PBSI__Lot__c=defaultlotitem2.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
       PBSI__PBSI_Inventory__c inv3=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=defaultlotitem3.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
        PBSI__PBSI_Inventory__c inv31=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot1.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         PBSI__PBSI_Inventory__c inv32=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot2.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         
       
      
       PBSI__PBSI_Inventory__c[] inv=new PBSI__PBSI_Inventory__c[]{inv2,inv3,inv31,inv32};
       insert  inv;
       
        for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);

        // AsyncApexJob correctly follows SeeAllData=false as this count returns 0 even if existing Batch Job history in org.
        System.assertEquals(0, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);       
       Test.starttest();
       
        //BatchATP bm=new BatchATP();
        //ID batchprocessid = Database.executeBatch(bm);
        RunBatchATP r = new RunBatchATP();
        //r.syncbatch();
        r.syncbatchobject();
        //ScheduleATP sb = new ScheduleATP();
        r.syncbatchobjectav();
        
        //Datetime dt = Datetime.now().addMinutes(1);
        //String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
        //System.schedule('Schedule',sch,sb);
        set<Id> itemsids = new set<Id>();
        for (PBSI__PBSI_Item__c i: items)
        	  itemsids.add(i.Id);
        	  		Date dt2 = date.newInstance(system.today().year(), system.today().month(), system.today().day()); 
        	  
       	Map<Id,Map<Id,double>> atpmap = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,false,false);
       	Map<Id,Map<Id,double>> atpmap1 = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,true,true);
       	Map<Id,Map<Id,double>> atpmap2 = CommonUtils.CalculateATPTodayInventoryMap(dt2,itemsids,false,true);
  /*
         BatchATPObject bm2=new BatchATPObject();
         ID batchprocessid2 = Database.executeBatch(bm2);
         ScheduleATPObject sb2 = new ScheduleATPObject();
        System.schedule('Schedule',sch,sb2);
    */
        Test.stoptest();      	  
        
        /*
                System.assertEquals(1, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);
        // This proves that the Scheduled Job has kicked off the Batch Job. You may now proceed to test Batch Job itself directly in its own test method.
        System.assertEquals('Queued', [SELECT Status
                                       FROM AsyncApexJob
                                       WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')].Status);
    */
    }
    
        static testMethod void myUnitTest2() {
        
         PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
 PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
          
                insert loc1 ; 
                insert loc2;
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
           
           // try {
                insert acc1; 
           // }
           // catch(DmlException e) {
             //       System.debug(e.getMessage());
            // } 
                
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',Group_Description__c='grp1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(name='itemmb1',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112288');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(name='itemmb12',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf1', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,EAN_Number__c='112277');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='itemmb2', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112266');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='itemmb3', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf3', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112255');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='itemmb31', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf31', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112244');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='itemmb4', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf4', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112233');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
//            try {
                insert items ;
  //          }
    //        catch(DmlException e) {
      //          System.debug(e.getMessage()); 
        //    }
            /*
               PBSI.bomController bc=new PBSI.bomController(new ApexPages.StandardController(item12));
            bc.newLine();
            bc.lines[0].line.PBSI__Item__c=item3.Id;
            bc.lines[0].line.PBSI__Quantity__c=1;
          
             bc.saveChanges();
       */
        
         
       
         PBSI__Lot__c defaultlotitem2= new PBSI__Lot__c(PBSI__Item__c=item2.Id,PBSI__Location__c=loc1.Id); 
          PBSI__Lot__c defaultlotitem3=new PBSI__Lot__c(PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
          PBSI__Lot__c defaultlotitem4=new PBSI__Lot__c(PBSI__Item__c=item4.Id,PBSI__Location__c=loc1.Id);
          
        
         insert defaultlotitem2;insert defaultlotitem3;insert defaultlotitem4; 
       
       
      PBSI__Lot__c lot1=new PBSI__Lot__c(Name='secondlot',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot2=new PBSI__Lot__c(Name='xcccccccccccc',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot3=new PBSI__Lot__c(Name='te',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      //insert lot1;insert lot2;insert lot3;
      PBSI__Lot__c[] lots = new PBSI__Lot__c[]{lot1,lot2,lot3};
       PBSI__PBSI_Inventory__c inv2=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item2.Id,PBSI__Lot__c=defaultlotitem2.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
       PBSI__PBSI_Inventory__c inv3=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=defaultlotitem3.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
        PBSI__PBSI_Inventory__c inv31=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot1.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         PBSI__PBSI_Inventory__c inv32=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot2.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         
       
      
       PBSI__PBSI_Inventory__c[] inv=new PBSI__PBSI_Inventory__c[]{inv2,inv3,inv31,inv32};
       insert  inv;
       
        for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);

        // AsyncApexJob correctly follows SeeAllData=false as this count returns 0 even if existing Batch Job history in org.
        System.assertEquals(0, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);       
       Test.starttest();
       /*
        BatchATP bm=new BatchATP();
         ID batchprocessid = Database.executeBatch(bm);
         RunBatchATP r = new RunBatchATP();
         r.syncbatch();
         ScheduleATP sb = new ScheduleATP();
       */
        Datetime dt = Datetime.now().addMinutes(1);
        String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
        //System.schedule('Schedule',sch,sb);
         
         BatchATPObject bm2=new BatchATPObject();
         ID batchprocessid2 = Database.executeBatch(bm2);
         ScheduleATPObject sb2 = new ScheduleATPObject();
        System.schedule('Schedule',sch,sb2);
 
 
         BatchATPObjectAvailability bm3=new BatchATPObjectAvailability();
         ID batchprocessid3 = Database.executeBatch(bm3);
         ScheduleATPObjectAvailability sb3 = new ScheduleATPObjectAvailability();
        System.schedule('Schedule3',sch,sb3);
  
        Test.stoptest();      	  
        
        /*
                System.assertEquals(1, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);
        // This proves that the Scheduled Job has kicked off the Batch Job. You may now proceed to test Batch Job itself directly in its own test method.
        System.assertEquals('Queued', [SELECT Status
                                       FROM AsyncApexJob
                                       WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')].Status);
    */
    }
    
     static testMethod void myUnitTest3() {
        
         PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping');
 PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
          
                insert loc1 ; 
                insert loc2;
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
           
           // try {
                insert acc1; 
           // }
           // catch(DmlException e) {
             //       System.debug(e.getMessage());
            // } 
                
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',Group_Description__c='grp1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(name='itemmb1',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112288');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(name='itemmb12',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf1', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,EAN_Number__c='112277');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='itemmb2', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112266');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='itemmb3', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf3', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112255');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='itemmb31', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf31', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112244');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='itemmb4', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf4', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112233');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
//            try {
                insert items ;
  //          }
    //        catch(DmlException e) {
      //          System.debug(e.getMessage()); 
        //    }
            /*
               PBSI.bomController bc=new PBSI.bomController(new ApexPages.StandardController(item12));
            bc.newLine();
            bc.lines[0].line.PBSI__Item__c=item3.Id;
            bc.lines[0].line.PBSI__Quantity__c=1;
          
             bc.saveChanges();
       */
        
         
       
         PBSI__Lot__c defaultlotitem2= new PBSI__Lot__c(PBSI__Item__c=item2.Id,PBSI__Location__c=loc1.Id); 
          PBSI__Lot__c defaultlotitem3=new PBSI__Lot__c(PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
          PBSI__Lot__c defaultlotitem4=new PBSI__Lot__c(PBSI__Item__c=item4.Id,PBSI__Location__c=loc1.Id);
          
        
         insert defaultlotitem2;insert defaultlotitem3;insert defaultlotitem4; 
       
       
      PBSI__Lot__c lot1=new PBSI__Lot__c(Name='secondlot',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot2=new PBSI__Lot__c(Name='xcccccccccccc',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot3=new PBSI__Lot__c(Name='te',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      //insert lot1;insert lot2;insert lot3;
      PBSI__Lot__c[] lots = new PBSI__Lot__c[]{lot1,lot2,lot3};
      insert lots;
       PBSI__PBSI_Inventory__c inv2=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item2.Id,PBSI__Lot__c=defaultlotitem2.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
       PBSI__PBSI_Inventory__c inv3=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=defaultlotitem3.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
        PBSI__PBSI_Inventory__c inv31=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot1.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         PBSI__PBSI_Inventory__c inv32=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot2.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         
       
      
       PBSI__PBSI_Inventory__c[] inv=new PBSI__PBSI_Inventory__c[]{inv2,inv3,inv31,inv32};
       insert  inv;
       
        for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);

        // AsyncApexJob correctly follows SeeAllData=false as this count returns 0 even if existing Batch Job history in org.
        System.assertEquals(0, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);       
       Test.starttest();
       /*
        BatchATP bm=new BatchATP();
         ID batchprocessid = Database.executeBatch(bm);
         RunBatchATP r = new RunBatchATP();
         r.syncbatch();
         ScheduleATP sb = new ScheduleATP();
       */
        Datetime dt = Datetime.now().addMinutes(1);
        String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
        //System.schedule('Schedule',sch,sb);
         
         //BatchATPObject bm2=new BatchATPObject();
         //ID batchprocessid2 = Database.executeBatch(bm2);
         ScheduleATPObjectHourly sb2 = new ScheduleATPObjectHourly();
        System.schedule('Schedule2br',sch,sb2);
        
        ATPPlannerObjectController apo = new ATPPlannerObjectController();
        apo.calculate();
        apo.getItemGroup();
        apo.getFabricCode();
        apo.getSize();
        apo.getLocation();
        Test.stoptest();      	  
        
        /*
                System.assertEquals(1, [SELECT COUNT()
                                FROM AsyncApexJob
                                WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')]);
        // This proves that the Scheduled Job has kicked off the Batch Job. You may now proceed to test Batch Job itself directly in its own test method.
        System.assertEquals('Queued', [SELECT Status
                                       FROM AsyncApexJob
                                       WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE NamespacePrefix = null AND Name = 'BatchJob')].Status);
    */
    }

     static testMethod void myUnitTest4() {
        
         PBSI__PBSI_Location__c loc1 = new PBSI__PBSI_Location__c(Name = 'aaaaaddd213123', PBSI__description__c = 'Shipping',Is_Stock_Location__c=true);
 PBSI__PBSI_Location__c loc2 = new PBSI__PBSI_Location__c(Name = 'aaaaadddasdasd', PBSI__description__c = 'Shipping');               
          
                insert loc1 ; 
                insert loc2;
          Account acc1 = new Account(Name = 'efdfsdfsdf', ShippingState = 'NY', PBSI__Payment_Terms__c = 'Net 35');
           
           // try {
                insert acc1; 
           // }
           // catch(DmlException e) {
             //       System.debug(e.getMessage());
            // } 
                
            Contact contact = new Contact(LastName = 'Rafiuddin', Email = 'akbar@ptd.net', AccountId = acc1.Id, PBSI__Level__c = 'Shipping ATTN');
            try {
                insert contact;
            }
            catch(DmlException e) { 
                    System.debug(e.getMessage()); 
            }
            PBSI__PBSI_Item_Group__c group1 = new PBSI__PBSI_Item_Group__c(Name = 'dsdsd', PBSI__Description__c = 'PBS Tools', PBSI__Item_Group_Code__c = '876',Group_Description__c='grp1');
     
       
                insert group1 ;
        
            
        PBSI__PBSI_Item__c item1 = new PBSI__PBSI_Item__c(name='itemmb1',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112288');
        PBSI__PBSI_Item__c item12 = new PBSI__PBSI_Item__c(name='itemmb12',PBSI__Item_Type__c='BOM',PBSI__Bom_Type__c='BOM-Phantom', PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf1', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,EAN_Number__c='112277');
        PBSI__PBSI_Item__c item2 = new PBSI__PBSI_Item__c(name='itemmb2', PBSI__purchaseprice__c = 1, PBSI__salesprice__c = 90, PBSI__description__c = 'Hammer test 4sdfsdfs', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true, PBSI__Item_Group__c = group1.Id,PBSI__Is_Serialized__c=true,EAN_Number__c='112266');
        PBSI__PBSI_Item__c item3 = new PBSI__PBSI_Item__c(name='itemmb3', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf3', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112255');
        PBSI__PBSI_Item__c item31 = new PBSI__PBSI_Item__c(name='itemmb31', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf31', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112244');
        PBSI__PBSI_Item__c item4 = new PBSI__PBSI_Item__c(name='itemmb4', PBSI__purchaseprice__c = 5, PBSI__salesprice__c = 120, PBSI__description__c = 'sdfsdf4', PBSI__defaultunitofmeasure__c = 'EA', PBSI__Default_Location__c = loc1.Id, PBSI__Lot_Tracking__c = true,  PBSI__Item_Group__c = group1.Id,PBSI__Allow_for_Drop_Ship__c=true,EAN_Number__c='112233');
        PBSI__PBSI_Item__c[] items = new PBSI__PBSI_Item__c[] {item1, item12,item2,item3,item4,item31};
//            try {
                insert items ;
  //          }
    //        catch(DmlException e) {
      //          System.debug(e.getMessage()); 
        //    }

       
         PBSI__Lot__c defaultlotitem2= new PBSI__Lot__c(PBSI__Item__c=item2.Id,PBSI__Location__c=loc1.Id); 
          PBSI__Lot__c defaultlotitem3=new PBSI__Lot__c(PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
          PBSI__Lot__c defaultlotitem4=new PBSI__Lot__c(PBSI__Item__c=item4.Id,PBSI__Location__c=loc1.Id);
          PBSI__Lot__c[] lots1 = new PBSI__Lot__c[]{defaultlotitem2,defaultlotitem3,defaultlotitem4};
		insert lots1;        
       
       
      PBSI__Lot__c lot1=new PBSI__Lot__c(Name='secondlot',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot2=new PBSI__Lot__c(Name='xcccccccccccc',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      PBSI__Lot__c lot3=new PBSI__Lot__c(Name='te',PBSI__Lot_Status__c='Released',PBSI__Item__c=item3.Id,PBSI__Location__c=loc1.Id);
      //insert lot1;insert lot2;insert lot3;
      PBSI__Lot__c[] lots = new PBSI__Lot__c[]{lot1,lot2,lot3};
      insert lots;
       PBSI__PBSI_Inventory__c inv2=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item2.Id,PBSI__Lot__c=defaultlotitem2.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
       PBSI__PBSI_Inventory__c inv3=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=defaultlotitem3.id,PBSI__qty__c=120,PBSI__location_lookup__c=loc1.id);
        PBSI__PBSI_Inventory__c inv31=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot1.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         PBSI__PBSI_Inventory__c inv32=new PBSI__PBSI_Inventory__c(PBSI__item_lookup__c=item3.Id,PBSI__Lot__c=lot2.id,PBSI__qty__c=300,PBSI__location_lookup__c=loc1.id);
         
       
      
       PBSI__PBSI_Inventory__c[] inv=new PBSI__PBSI_Inventory__c[]{inv2,inv3,inv31,inv32};
       insert  inv;
		ATP__c atp1 = new ATP__c(Item__c = item3.Id,Location__c = loc1.Id,Current_ATP__c = 10,Current_ATP_Last_Calculated_at__c = system.today()) ;
		insert atp1;       
       Test.starttest();
        ATPPlannerObjectController apo = new ATPPlannerObjectController();
        apo.calculate();
        apo.getItemGroup();
        apo.getFabricCode();
        apo.getSize();
        apo.getLocation();
        Test.stoptest();      	  
     }
     
     
     
	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   @isTest static void testScheduleATPObjectAvailability() {
      Test.startTest();
	  scheduleJob(System.schedule('SCH1', CRON_EXP, new ScheduleATPObjectAvailability()));
      Test.stopTest();
   }

   @isTest static void testScheduleATPObject() {
      Test.startTest();
	  scheduleJob(System.schedule('SCH2', CRON_EXP, new ScheduleATPObject()));
      Test.stopTest();
   }

   static void scheduleJob (String job) {
      String jobId = job;
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
   }
}