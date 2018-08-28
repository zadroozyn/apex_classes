@isTest
private class SalesOrderSmallQuantitiesTest {
  
    static testMethod void smallQuantitiesLessThan3Pairs() {
        TestDataFactory tdf = TestDataFactory.instance;
        PBSI__PBSI_Sales_Order__c salesOrder = createSalesOrder((Account)tdf.accounts.getSObject('EU_Account'), 'New Order', false);
        PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.getSObject('4.4102 W 6.5');

        PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(salesOrder.Id, item.Id);
        salesOrderLine.PBSI__Quantity_Needed__c = 2;
        salesOrderLine.PBSI__TransactionType__c = 'Sale';
        
        
        Test.startTest();
    
        insert salesOrderLine;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder = [Select id, Total_Quantity_Of_Shoes_On_Order__c, PBSI__Shipping_Cost__c from PBSI__PBSI_Sales_Order__c Where id = :salesOrder.id];
        
        salesOrder.PBSI__Shipping_Cost__c = 14;
        update salesOrder;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder1 = [Select id,PBSI__Shipping_Cost__c from PBSI__PBSI_Sales_Order__c where id = :salesOrder.id Limit 1];
        system.assertequals(selectedSalesOrder1.PBSI__Shipping_Cost__c, 14);
        
        salesOrder.Exclude_handling_fee__c=true;
        update salesOrder;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder2 = [Select id,PBSI__Shipping_Cost__c, Exclude_handling_fee__c from PBSI__PBSI_Sales_Order__c where id = :salesOrder.id Limit 1];
        system.assertequals(selectedSalesOrder2.Exclude_handling_fee__c, true);
        system.assertequals(selectedSalesOrder2.PBSI__Shipping_Cost__c, 0);
       
        
        salesOrder.PBSI__Shipping_Cost__c = 15;
        update salesOrder;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder4 = [Select id,PBSI__Shipping_Cost__c, Exclude_handling_fee__c from PBSI__PBSI_Sales_Order__c where id = :salesOrder.id Limit 1];
        system.assertequals(selectedSalesOrder4.Exclude_handling_fee__c, true);
        system.assertequals(selectedSalesOrder4.PBSI__Shipping_Cost__c, 0);
        
        
        salesOrder.Exclude_handling_fee__c=false;
        update salesOrder;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder5 = [Select id,PBSI__Shipping_Cost__c, Exclude_handling_fee__c from PBSI__PBSI_Sales_Order__c where id = :salesOrder.id Limit 1];
        system.assertequals(selectedSalesOrder5.Exclude_handling_fee__c, false);
        system.assertequals(selectedSalesOrder5.PBSI__Shipping_Cost__c, 10);
        
        Test.stopTest();
    }
    
   
    private static PBSI__PBSI_Sales_Order__c createSalesOrder(Account account, String orderType, Boolean ehf) {
        
    
         PBSI__PBSI_Sales_Order__c so = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c=account.id,
                                                                     Sales_Order_Type__c = orderType,
                                                                     PBSI__Order_Date__c = date.today(),
                                                                     PBSI__Due_Date__c = date.today(),
                                                                     Exclude_handling_fee__c = ehf
                                                                     );
        insert so;
        return so;
    }

    static testMethod void smallQuantitiesLessThan600CHF() {
        TestDataFactory tdf = TestDataFactory.instance;        
        PBSI__PBSI_Sales_Order__c salesOrder = createSalesOrder((Account)tdf.accounts.getSObject('CH_Account'), 'New Order', false);
        PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.getSObject('4.4102 W 6.5');

        PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(salesOrder.Id, item.Id);
        salesOrderLine.PBSI__Quantity_Needed__c = 2;
        salesOrderLine.PBSI__Price__c = 10;
        salesOrderLine.PBSI__TransactionType__c = 'Sale';
        
        
        Test.startTest();
        insert salesOrderLine;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder = [Select id, Total_Quantity_Of_Shoes_On_Order__c, PBSI__Shipping_Cost__c from PBSI__PBSI_Sales_Order__c Where id = :salesOrder.id];            
        
        salesOrder.PBSI__Shipping_Cost__c = 30;
        update salesOrder;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder1 = [Select id,PBSI__Shipping_Cost__c from PBSI__PBSI_Sales_Order__c where id = :salesOrder.id Limit 1];
        system.assertequals(selectedSalesOrder1.PBSI__Shipping_Cost__c, 30);
        Test.stopTest();
        
    }

    static testMethod void smallQuantitiesGreaterThan600CHF() {
        TestDataFactory tdf = TestDataFactory.instance;
        PBSI__PBSI_Sales_Order__c salesOrder = createSalesOrder((Account)tdf.accounts.getSObject('CH_Account'), 'New Order', false);
        PBSI__PBSI_Item__c item = (PBSI__PBSI_Item__c) tdf.items.getSObject('4.4102 W 6.5');

        PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(salesOrder.Id, item.Id);
        salesOrderLine.PBSI__Quantity_Needed__c = 2;
        salesOrderLine.PBSI__Price__c = 601;
        salesOrderLine.PBSI__TransactionType__c = 'Sale';
        
        
        Test.startTest();
        
        insert salesOrderLine;
        PBSI__PBSI_Sales_Order__c selectedSalesOrder = [Select id, Total_Quantity_Of_Shoes_On_Order__c, PBSI__Shipping_Cost__c from PBSI__PBSI_Sales_Order__c Where id = :salesOrder.id];
        system.assertEquals(selectedSalesOrder.PBSI__Shipping_Cost__c, 15);
        
        Test.stopTest();
    }

    @testSetup static void setup() {
        TestDataFactory tdf = TestDataFactory.instance;

        SObject pt = tdf.paymentTerms.createSObject('test_pt',5,true);

        Sobject locCH = tdf.locations.createSObject('CH-Stock',false);
        Sobject locEU = tdf.locations.createSObject('EU-Stock',false);
        tdf.locations.insertAll();

        tdf.accounts.createSObject('CH_Account', 'CHF', false);
        tdf.accounts.getSObject('CH_Account').put('On_Payment_Term__c', pt.Id);
        tdf.accounts.getSObject('CH_Account').put('small_quantities__c', 'Small Quantity Surcharge (Sales < CHF 600)');
        tdf.accounts.getSObject('CH_Account').put('Default_Location__c', locCH.Id);

        tdf.accounts.createSObject('EU_Account', 'EUR', false);
        tdf.accounts.getSObject('EU_Account').put('On_Payment_Term__c', pt.Id);
        tdf.accounts.getSObject('EU_Account').put('small_quantities__c', 'Small Quantity Surcharge (Sales < 3 Pairs)');
        tdf.accounts.getSObject('EU_Account').put('Default_Location__c', locEU.Id);

        tdf.accounts.insertAll();

        SObject itemGroup = tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

        tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', locCH.Id, 
            itemGroup.Id, '7640165317761', false);
        tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', locEU.Id, 
            itemGroup.Id, '7640165317762', false);

        tdf.items.insertAll();
    }
}