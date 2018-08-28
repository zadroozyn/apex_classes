@isTest 

private class TestViewSoLinesController
{        
  public static testMethod void testso() 
  {  
    //  try
     // {     
          PBSI__PBSI_Location__c loc=new PBSI__PBSI_Location__c(Name='Andreea');
          insert loc; 
         
          try
          {
            insert TestUtil.GetProperty('DecimalPlaces', '4');
          }
          catch(Exception ex){}
          
          insert TestUtil.GetProperty('Item_Version', 'Yes');

          On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', Terms_Days__c = 7);
          insert opt;  
            
          Account account = TestUtil.GetAccount();
          account.On_Payment_Term__c = opt.Id;
          insert account; 
 			Account acc2 = ([select Id, On_Payment_Term__c from Account where Id = :account.Id limit 1]);
 			system.assertEquals(acc2.On_Payment_Term__c,opt.Id); 
           
          PBSI__PBSI_Sales_Order__c so =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = account.Id, PBSI__BillingCountry__c = 'BC');
          so.PBSI__From_Location__c = loc.Id;
          insert so;
           
          PBSI__PBSI_Item__c item = TestUtilActions.createItem();
          item.PBSI__Standard_Lead_Time__c = 5;
          update item;
          
          try
          {
            insert TestUtil.GetItemUnit(item.Id);
          }
          catch(Exception ex)
          {
          
          }
         
          insert TestUtil.GetItemVersion(item.Id);
            
          PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(so.Id, item.Id);
          //salesOrderLine.PBSI__bom__c = bom.Id;
          salesOrderLine.PBSI__Quantity_Needed__c = 3;
          salesOrderLine.PBSI__TransactionType__c = 'Sale';
          salesOrderLine.PBSI__location__c = loc.Id;
          insert salesOrderLine;
          
          List<PBSI__PBSI_Sales_Order_Line__c> solList = new List<PBSI__PBSI_Sales_Order_Line__c>();
          solList.add(salesOrderLine);
          
          Opportunity o=new Opportunity(Name='andreea',StageName='Prospecting',CloseDate=system.today()+20);
          insert o;
          
          PBSI__PBSI_Opportunity_Line__c o1=new PBSI__PBSI_Opportunity_Line__c(PBSI__Opportunity__c=o.Id,PBSI__Quantity__c=4,PBSI__Item__c=item.Id);
          insert o1;  
          
          
          insert new PBSI__BOM_Depletion_Line__c(PBSI__Sales_Order_Line__c = salesOrderLine.Id,
                                                 PBSI__Quantity__c  = 3,
                                                 PBSI__Quantity_Packed__c = 1,
                
                                                 PBSI__Item__c = item.Id);
         
         PBSI__Lot__c lot=new PBSI__Lot__c(Name='andreea', PBSI__Item__c = item.Id, PBSI__Location__c = loc.Id);
         insert lot; 
         List<PBSI__PBSI_Inventory__c> invs=new List<PBSI__PBSI_Inventory__c>();
               PBSI__PBSI_Inventory__c       Inv1 = new PBSI__PBSI_Inventory__c(
                                                PBSI__item_lookup__c = item.id,
                                                PBSI__Lot__c = lot.Id,
                                                PBSI__location_lookup__c = loc.Id,
                                                PBSI__qty__c = 4,
                                                PBSI__Area__c='a1',
                                                PBSI__Carton__c='c1');
            insert inv1;  
                  PBSI__PBSI_Inventory__c    Inv2 = new PBSI__PBSI_Inventory__c(
                                                PBSI__item_lookup__c = item.id,
                                                PBSI__Lot__c = lot.Id,
                                                PBSI__location_lookup__c = loc.Id,
                                                PBSI__qty__c = 4,
                                                PBSI__Area__c='a1',
                                                PBSI__Carton__c='c1');
            
            insert inv2;  
            
          //invs.add(InventoryMethods.receiveInventory4(5, lot.id, item.Id, loc.id, 23, 34, 'a1', 'c1', invs));
          //upsert invs;
                                      
          //invs.add(InventoryMethods.receiveInventory4(5, lot.id, item.Id, loc.id, 23, 34, 'a1', 'c1', invs));
        //  upsert invs;
    
          
          PBSI__Serial_Number_Tracker__c sn=new PBSI__Serial_Number_Tracker__c(PBSI__Serial_Number__c='andreea');
          insert sn;
           Map<String ,PBSI__Serial_Number_Tracker__c> snt=new Map<String,PBSI__Serial_Number_Tracker__c>{'andreea' => sn};
          //InventoryMethods.insertSNT( snt);
    
          
          PageReference pageRef = Page.ViewSoLines;
          pageRef.getParameters().put('id',so.id);
          Test.setCurrentPage(pageRef);
    
          SoqlService soqlService = new SoqlService();
          soqlService.GetSalesOrdersByIDs(new Set<Id>{ so.Id });
    
            PBSI__Admin__c cs=PBSI__Admin__c.getOrgDefaults();
            cs.PBSI__bom_versioning_enabled__c = true;
            update cs;
    
          PageControllerBase pb = new PageControllerBase();
          pb.getnewsocomponent();
          pb.setnewsocomponent(null);
    
          test.starttest();
                    
    
          ViewSoLinesController controller = new ViewSoLinesController();
          
          controller.capturelines();
          
          /*
          controller.calculateReservedQtyQuotes(solList);
          
          System.currentPageReference().getParameters().put('lineNo','3');
          controller.addLines();
          controller.getshowPriceType(); 
          controller.gettwodec();
          
          System.currentPageReference().getParameters().put('line1','1');
          controller.createRMA();
          
          controller.getLines()[0].getVersion();
          controller.getLines()[0].getUMS();
          
          System.currentPageReference().getParameters().put('line1','1');
          controller.advancedatp();
          controller.eline[0].item = item;
          controller.getLines()[0].changePrice();
          
          System.currentPageReference().getParameters().put('lineNo','3');
          controller.addLines();
          
          System.currentPageReference().getParameters().put('line1','1');
          controller.eline[0].item = null;
          controller.getLines()[0].changePrice();
          
          controller.getLines()[0].getshowDelete();   
          controller.getshowVersion();
          controller.getLines()[0].line.PBSI__Price__c=0;
          controller.getLines()[0].editLine();
          
          controller.getLines()[0].configure();
          controller.getLines()[0].configureGroup();
          
          System.currentPageReference().getParameters().put('linecred','1');
          controller.creditLine();
         */
         
          PBSI__PBSI_Item__c item2 = TestUtilActions.createItem(); 
          controller.getLines()[0].line.PBSI__item__c=item2.Id;
          
          System.currentPageReference().getParameters().put('line1','1');
          
          item2.PBSI__item_type__c = 'BOM';
          update item2;
          
          controller.getItemInformation();
          
          item2.PBSI__item_type__c = 'Item';
          update item2;
          
          controller.getItemInformation();
          
          controller.getLines()[0].line.PBSI__item__c=item.Id;
          
          controller.deleteLine();
 
          
          controller.saveChanges();
          
          controller.newLine();
          
          controller.getshowbom();
          
          controller.isClone = true;
          controller.geteline();
          
          controller.getItemVersions(solList);
          
          controller.changePrice();
          
          controller.NotshowSHort();
          
          controller.addlines1();
 
          test.stopTest();
    
          /*
          controller.pageController = new PageControllerBase();
          
          ApexPages.StandardController standardController = new ApexPages.StandardController(so);
          ViewSoLinesController controllerWithObj = new ViewSoLinesController();
          
          controllerWithObj.soid = null;
          
          controllerWithObj.capturelines();
          
          cs.PBSI__bom_versioning_enabled__c = false;
          update cs;
		 */
  }
  
  public static testMethod void testso1()
  {
  	          PBSI__PBSI_Location__c loc=new PBSI__PBSI_Location__c(Name='Andreea');
          insert loc; 
         
          try
          {
            insert TestUtil.GetProperty('DecimalPlaces', '4');
          }
          catch(Exception ex){}
          
          insert TestUtil.GetProperty('Item_Version', 'Yes');

          On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', Terms_Days__c = 7);
          insert opt;  
            
          Account account = TestUtil.GetAccount();
          account.On_Payment_Term__c = opt.Id;
          insert account; 
 Account acc2 = ([select Id, On_Payment_Term__c from Account where Id = :account.Id limit 1]);
 system.assertEquals(acc2.On_Payment_Term__c,opt.Id); 
           
          PBSI__PBSI_Sales_Order__c so =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = account.Id, PBSI__BillingCountry__c = 'BC');
          so.PBSI__From_Location__c = loc.Id;
          insert so;
           
          PBSI__PBSI_Item__c item = TestUtilActions.createItem();
          item.PBSI__Standard_Lead_Time__c = 5;
          item.PBSI__item_type__c = 'BOM';
          update item;
          
          try
          {
            insert TestUtil.GetItemUnit(item.Id);
          }
          catch(Exception ex)
          {
          
          }
         
          insert TestUtil.GetItemVersion(item.Id);
            
          PBSI__Bom__c bom = TestUtil.CreateBom();   
          insert bom;   
            
          PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(so.Id, item.Id);
          //salesOrderLine.PBSI__bom__c = bom.Id;
          salesOrderLine.PBSI__Quantity_Needed__c = 3;
          salesOrderLine.PBSI__TransactionType__c = 'Sale';
          insert salesOrderLine; 
          On_Invoices__c oni = new On_Invoices__c(Name='Test', Sales_Order__c = so.Id);
          insert oni;
 On_Invoices__c oni2 = ([select Id, NEW_Payment_Terms_Days__c from On_Invoices__c where Id = :oni.Id limit 1]);
 system.assertEquals(oni2.NEW_Payment_Terms_Days__c,7); 
                       
          //c2g__codaInvoice__c invoice =new c2g__codaInvoice__c(c2g__Account__c=account.Id, Ascent2FF__Sales_Order__c = so.Id, c2g__DueDate__c = system.today());
                       
//          c2g__codaInvoice__c invoice =new c2g__codaInvoice__c(c2g__Account__c=account.Id, Ascent2FF__Sales_Order__c = so.Id, c2g__DueDate__c = system.today(), c2g__InvoiceDate__c=system.today());
//          insert invoice;
          
          PBSI__PBSI_Item__c itemtoi=[select id,pbsi__product__c from PBSI__PBSI_Item__c where id =:item.Id];
          
          Pricebook2 prb=new Pricebook2(name='p');
          insert prb;
          Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
          
          PricebookEntry prbe=new PricebookEntry(IsActive=true,product2id=itemtoi.pbsi__product__c,pricebook2id=pbook.id,unitprice=12,UseStandardPrice=false);
          insert prbe;
          
         
//          c2g__codaInvoiceLineItem__c invline= new c2g__codaInvoiceLineItem__c(c2g__UnitPrice__c=123,c2g__Quantity__c=10,c2g__Invoice__c=invoice.id, Ascent2FF__Sales_Order_Line__c=salesOrderLine.Id,c2g__Product__c=itemtoi.pbsi__product__C);
//          insert invline;
 Test.starttest();         
          ATPPlannerController atp=new ATPPlannerController();
          
         atp.input.pbsi__item__c=item.Id;
         atp.calculate();

          
test.stoptest();
	}

  public static testMethod void testso2() 
  {  
    //  try
     // {     
          PBSI__PBSI_Location__c loc=new PBSI__PBSI_Location__c(Name='Andreea');
          insert loc; 
         
          try
          {
            insert TestUtil.GetProperty('DecimalPlaces', '4');
          }
          catch(Exception ex){}
          
          insert TestUtil.GetProperty('Item_Version', 'Yes');

          On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', Terms_Days__c = 7);
          insert opt;  
            
          Account account = TestUtil.GetAccount();
          account.On_Payment_Term__c = opt.Id;
          insert account; 
 Account acc2 = ([select Id, On_Payment_Term__c from Account where Id = :account.Id limit 1]);
 system.assertEquals(acc2.On_Payment_Term__c,opt.Id); 
           
          PBSI__PBSI_Sales_Order__c so =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = account.Id, PBSI__BillingCountry__c = 'BC');
          so.PBSI__From_Location__c = loc.Id;
          insert so;
           
          PBSI__PBSI_Item__c item = TestUtilActions.createItem();
          item.PBSI__Standard_Lead_Time__c = 5;
          //item.PBSI__item_type__c = 'BOM';
          update item;
          
          try
          {
            insert TestUtil.GetItemUnit(item.Id);
          }
          catch(Exception ex)
          {
          
          }
         
          insert TestUtil.GetItemVersion(item.Id);
            
          PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(so.Id, item.Id);
          //salesOrderLine.PBSI__bom__c = bom.Id;
          salesOrderLine.PBSI__Quantity_Needed__c = 3;
          salesOrderLine.PBSI__TransactionType__c = 'Sale';
          salesOrderLine.PBSI__location__c = loc.Id;
          insert salesOrderLine;
          
          List<PBSI__PBSI_Sales_Order_Line__c> solList = new List<PBSI__PBSI_Sales_Order_Line__c>();
          solList.add(salesOrderLine);
          
          Opportunity o=new Opportunity(Name='andreea',StageName='Prospecting',CloseDate=system.today()+20);
          insert o;
          
          PBSI__PBSI_Opportunity_Line__c o1=new PBSI__PBSI_Opportunity_Line__c(PBSI__Opportunity__c=o.Id,PBSI__Quantity__c=4,PBSI__Item__c=item.Id);
          insert o1;  
         
         PBSI__Lot__c lot=new PBSI__Lot__c(Name='andreea', PBSI__Item__c = item.Id, PBSI__Location__c = loc.Id);
         insert lot; 
         List<PBSI__PBSI_Inventory__c> invs=new List<PBSI__PBSI_Inventory__c>();
               PBSI__PBSI_Inventory__c       Inv1 = new PBSI__PBSI_Inventory__c(
                                                PBSI__item_lookup__c = item.id,
                                                PBSI__Lot__c = lot.Id,
                                                PBSI__location_lookup__c = loc.Id,
                                                PBSI__qty__c = 4,
                                                PBSI__Area__c='a1',
                                                PBSI__Carton__c='c1');
            insert inv1;  
                  PBSI__PBSI_Inventory__c    Inv2 = new PBSI__PBSI_Inventory__c(
                                                PBSI__item_lookup__c = item.id,
                                                PBSI__Lot__c = lot.Id,
                                                PBSI__location_lookup__c = loc.Id,
                                                PBSI__qty__c = 4,
                                                PBSI__Area__c='a1',
                                                PBSI__Carton__c='c1');
            
            insert inv2;  
            
          //invs.add(InventoryMethods.receiveInventory4(5, lot.id, item.Id, loc.id, 23, 34, 'a1', 'c1', invs));
          //upsert invs;
                                      
          //invs.add(InventoryMethods.receiveInventory4(5, lot.id, item.Id, loc.id, 23, 34, 'a1', 'c1', invs));
        //  upsert invs;
          
          PBSI__Serial_Number_Tracker__c sn=new PBSI__Serial_Number_Tracker__c(PBSI__Serial_Number__c='andreea');
          insert sn;
           Map<String ,PBSI__Serial_Number_Tracker__c> snt=new Map<String,PBSI__Serial_Number_Tracker__c>{'andreea' => sn};
          //InventoryMethods.insertSNT( snt);
          
          
          PageReference pageRef = Page.ViewSoLines;
          pageRef.getParameters().put('id',so.id);
          Test.setCurrentPage(pageRef);
    
          SoqlService soqlService = new SoqlService();
          soqlService.GetSalesOrdersByIDs(new Set<Id>{ so.Id });
    
            PBSI__Admin__c cs=PBSI__Admin__c.getOrgDefaults();
            cs.PBSI__bom_versioning_enabled__c = true;
            update cs;
    
          PageControllerBase pb = new PageControllerBase();
          pb.getnewsocomponent();
          pb.setnewsocomponent(null);
          
    
    
          ViewSoLinesController controller = new ViewSoLinesController();
          
          controller.capturelines();
          
          controller.calculateReservedQtyQuotes(solList);
          System.currentPageReference().getParameters().put('lineNo','3');
          controller.addLines();
          controller.getshowPriceType(); 
          controller.gettwodec();
          
          test.starttest();
          
          
          System.currentPageReference().getParameters().put('line1','1');
          controller.createRMA();
          
          controller.getLines()[0].getVersion();
          controller.getLines()[0].getUMS();
          
          System.currentPageReference().getParameters().put('line1','1');
          
          controller.eline[0].item = item;
          controller.getLines()[0].changePrice();
          
          System.currentPageReference().getParameters().put('lineNo','3');
          controller.addLines();
          
          System.currentPageReference().getParameters().put('line1','1');
          controller.eline[0].item = null;
          controller.getLines()[0].changePrice();
          
          controller.getLines()[0].getshowDelete();   
          controller.getshowVersion();
          controller.getLines()[0].line.PBSI__Price__c=0;
          controller.getLines()[0].editLine();
          
          controller.getLines()[0].configure();
          controller.getLines()[0].configureGroup();
          
          System.currentPageReference().getParameters().put('linecred','1');
          controller.creditLine();
          
        System.currentPageReference().getParameters().put('action','credit');       
        controller.selectedLineNRs = '1;';
        controller.PerformActionOnSelected();
        controller.getLines()[0].line.pbsi__item__c=item.Id;
        System.currentPageReference().getParameters().put('action','delete');       
        controller.selectedLineNRs = '1;';
        controller.PerformActionOnSelected();

        test.stopTest();
  }
	 
}