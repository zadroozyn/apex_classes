@isTest
public class SalesOrderTriggersTest
{

    @isTest
    static void testSOWithInvalidCharacters() {
        PBSI__Account_Group__c aGroup = new PBSI__Account_Group__c(Name = 'Dealers', PBSI__Account_Group_Code__c='1111');
        insert aGroup;
        Account a = TestUtility.createAccount('Supersports', 'EUR', false);
        a.PBSI__Account_Group__c = aGroup.Id;
        a.E_Shop_Dealer__c = 'Dealer and Point of Sale';
        a.ShippingCountry = 'Switzerland';
        a.Status__c = 'Active';
        insert a;

        TestUtility.createKNIntegrationSettings(true);
        Id soRecordType = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get('Web Order').getRecordTypeId();
        PBSI__PBSI_Sales_Order__C so = TestUtility.createSalesOrder(a.Id, soRecordType, a.CurrencyIsoCode, false);

        so.PBSI__Due_date__C = Date.today();
        so.PBSI__Order_Date__c = Date.today();
        so.PBSI__Stage__c = 'Open';
        so.Sales_Order_Type__c='Re-Order';
        so.Delivery_Name__c = '{Test}';
        Test.startTest();
        boolean isError = false;
        String errorMessage = '';

        try{
            insert so;
        }
        catch(Exception e){
            isError = true;
            errorMessage = e.getStackTraceString();
        }

        System.assertEquals(false, isError);
        System.assertEquals('', errorMessage);
        
        List<AggregateResult> results = [select count(Id)num from PBSI__PBSI_Sales_Order__c];
        System.assertEquals(1, results[0].get('num'));
        Test.stopTest();
    }


    @isTest
    static void testSOWithValidCharacters() {
        System.debug('Test...');
        PBSI__Account_Group__c aGroup = new PBSI__Account_Group__c(Name = 'Dealers', PBSI__Account_Group_Code__c='1111');
        insert aGroup;
        Account a = TestUtility.createAccount('Supersports', 'EUR', false);
        a.PBSI__Account_Group__c = aGroup.Id;
        a.E_Shop_Dealer__c = 'Dealer and Point of Sale';
        a.ShippingCountry = 'Switzerland';
        a.Status__c = 'Active';
        insert a;

        TestUtility.createKNIntegrationSettings(true);
        Id soRecordType = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get('Web Order').getRecordTypeId();
        PBSI__PBSI_Sales_Order__C so = TestUtility.createSalesOrder(a.Id, soRecordType, a.CurrencyIsoCode, false);
        System.debug('Sales order created...');
        so.PBSI__Due_date__C = Date.today();
        so.PBSI__Order_Date__c = Date.today();
        so.PBSI__Stage__c = 'Open';
        so.Sales_Order_Type__c='Re-Order';
        so.Delivery_Name__c = 'Test';
        Test.startTest();
        System.debug('Generated sales order');
        insert so;
        System.debug('Sales order inserted ');
        PortalTestUtils.generateSOLines(so);
        System.debug('Sales order lines are inserted');
        
        List<AggregateResult> results = [select count(Id)num from PBSI__PBSI_Sales_Order__c];
        System.assertEquals(1, results[0].get('num'));
        System.debug('First assert done ');
        
        List<PBSI__PBSI_Sales_Order_Line__c> soLines = [select Id  from PBSI__PBSI_Sales_Order_Line__c where PBSI__Sales_Order__c = :so.Id];
       
        for (PBSI__PBSI_Sales_Order_Line__c l: soLines){
          System.debug('Line ' + l.Id);
        }
        delete soLines;
        delete so;

        results = [select count(Id)num from PBSI__PBSI_Sales_Order__c];
        System.assertEquals(0, results[0].get('num'));
        
        Test.stopTest();
    }


}