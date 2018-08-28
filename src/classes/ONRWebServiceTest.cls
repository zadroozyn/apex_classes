@isTest
private class ONRWebServiceTest{

    /**
    * Prepares data for the test.
    * @author Ivan Durlen <ivan.durlen@nefos.com> 2016/05/30
    */
    @testSetup
    static void prepareData(){
		new TestCustomSettingsFactory();
        Account a = TestUtility.createAccount('Supersports', 'EUR', false);
        a.E_Shop_Dealer__c = 'Dealer and Point of Sale';
        a.ShippingCountry = 'Switzerland';
        a.Status__c = 'Active';
        insert a;

        List<PBSI__PBSI_Location__c> lLocations = new List<PBSI__PBSI_Location__c>();
        lLocations.add(new PBSI__PBSI_Location__c(
            Name = 'CH-Stock',
            CurrencyIsoCode = 'CHF',
            PBSI__Country__c = 'Switzerland' ));
        lLocations.add(new PBSI__PBSI_Location__c(
            Name = 'DE-Stock',
            CurrencyIsoCode = 'EUR',
            PBSI__Country__c = 'Germany' ));
        insert lLocations;

        //TODO: Item groups, fabric codes, etc.
          ONRLogisticsGateway.setValuesFromCustomSettings();
    }


    /**
    * @author Ivan Durlen <ivan.durlen@nefos.com> 2016/05/30
    */
    static Id getRecordTypeId(String recordTypeName){
        return Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    

     /**
    * @author Ivan Durlen <ivan.durlen@nefos.com> 2016/05/30
    */
    static Id getLocationIdByCountry(String countryName){
        List<PBSI__PBSI_Location__c> lLocations = [SELECT Id 
                                FROM PBSI__PBSI_Location__c 
                                WHERE PBSI__Country__c = :countryName];
        return lLocations.get(0).Id;
    }
    

     /**
    * @author Ivan Durlen <ivan.durlen@nefos.com> 2016/05/30
    */
    static Id getAccountId(){
        List<Account> lAccounts = [SELECT Id FROM Account LIMIT 1];
        return lAccounts.get(0).Id;
    }



    static PBSI__PBSI_Sales_Order__c getSalesOrder()
    {
        PBSI__PBSI_Location__c loc=new PBSI__PBSI_Location__c(Name='Lux' );
        insert loc; 
        
        try
        {
            insert TestUtil.GetProperty('DecimalPlaces', '4');
        }
        catch(Exception ex){
            
        }
        
        On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', Terms_Days__c = 7);
        insert opt;  
        
        
        pw_ccpro__CountryObject__c country = new pw_ccpro__CountryObject__c(Name='United Kingdom', pw_ccpro__IsoCode_2__c='GB', pw_ccpro__IsoCode_3__c='GBP', Delivery_Estimate__c=5);
        insert country; 
        
        Account account = TestUtil.GetAccount();
        account.On_Payment_Term__c = opt.Id;
        insert account; 
        
        PBSI__PBSI_Sales_Order__c so =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = account.Id, PBSI__BillingCountry__c = 'BC');
        so.PBSI__From_Location__c = loc.Id;
        so.Delivery_Name__c = 'Test Name';
        so.PBSI__Delivery_Streetnew__c = 'Street Name';
        so.PBSI__Delivery_Address_line2__c = 'Address 2';        
        so.PBSI__Delivery_State__c = 'State';
        so.PBSI__Delivery_City__c = 'City';   
        so.PBSI__Delivery_Postal_Code__c = 'PO CODE';
        so.PBSI__Delivery_Country__c = 'United Kingdom';                             
        insert so;
        
        PBSI__PBSI_Item__c item = TestUtilActions.createItem();
        item.PBSI__Standard_Lead_Time__c = 5;
        item.PBSI__item_type__c = 'BOM';
        update item;
        
        try {
            insert TestUtil.GetItemUnit(item.Id);
        } catch(Exception ex) {
        
        }
        
        insert TestUtil.GetItemVersion(item.Id);
        
        PBSI__Bom__c bom = TestUtil.CreateBom();   
        insert bom;   
        Test.startTest();
        PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(so.Id, item.Id);
        salesOrderLine.PBSI__Quantity_Needed__c = 3;
        salesOrderLine.PBSI__TransactionType__c = 'Sale';
        insert salesOrderLine;
        
        ONRWebService.packAllLineItemsImpl(so.Id);
        ONRWebService.UpdateAllLineItemsEstimatedShipDateImpl(so.Id);
        
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
        Test.stopTest();
        return so;    
    }  

    static testMethod void testShippingNotification()
    {
        Test.setMock(HttpCalloutMock.class, new ONRMockKNPostResponse());
        Test.setMock(HttpCalloutMock.class, new ONRMockKNGETResponse());       
        PBSI__PBSI_Sales_Order__c sales_order = getSalesOrder();
        
        ONRWebService.shippingNotificationWeb(sales_order.Id);
        
		PBSI__PBSI_Sales_Order__c order = [SELECT Id, KN_Shipping_Notice_Sent__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: sales_order.Id];
        System.assertEquals(false, order.KN_Shipping_Notice_Sent__c);
    }
}