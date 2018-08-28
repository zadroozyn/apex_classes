/**
 * Class contains methods that are using to test SalesInvoiceMethods methods.<br>
 * Class's methods use methods from TestUtility to create test data.<br>
 * The test methods that are included to this class use existing records of Company object.<br>
 * There is needed to have although one Company record in the System for the proper functioning of test methods.
 * 
 * @version 1.0  2014.08.18  Ewa Byra <ewa.byra@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see SalesInvoiceMethods APEX class.
 * @see TestUtility APEX class.
 */

@isTest
public without sharing class SalesInvoiceMethodsTest {

	/**
     * Method used to test invoicing automation.
     */
    /*@isTest(SeeAllData=true) public static void webOrdersInvoicingTest() {
        System.runAs(TestUtility.createUser('tester', null, true)) {
        	System.assert([SELECT count() FROM c2g__codaCompany__c] > 0);
            TestUtility.enableAllFeatures();

            String currencyIsoCode = 'EUR';
            ID salesOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);
            
            Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);

            test_account.BillingCountry = 'Poland';
            test_account.BillingCity = 'Warsaw';
            test_account.BillingPostalCode = '00-123';
            test_account.BillingStreet = 'Marszałkowska 123';

            insert test_account;

            Contact test_contact = TestUtility.createContact('Test Contact', test_account, true);

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c FROM PBSI__Lots__r) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();

            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            //lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            //lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));

            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            //lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            //lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            insert lTest_SalesOrders;

            List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            //lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            insert lSalesOrderLines;

            Integer i = 0;

            for (PBSI__PBSI_Sales_Order__c salesOrder : lTest_SalesOrders) {
                salesOrder.Web_Order_Stage_Reached__c = SalesOrderMethods.WEB_ORDER_COMPLETE_STATUS_VALUE;
                salesOrder.Tracking_Number_1__c = '1234567' + i;

                i++;
            }

            Test.startTest();

            update lTest_SalesOrders;

            List<c2g__codaInvoice__c> lSalesInvoices;

            Set<ID> sSalesOrderIDs = new Set<ID>();
            sSalesOrderIDs.add(lTest_SalesOrders.get(0).ID);
            //sSalesOrderIDs.add(lTest_SalesOrders.get(1).ID);
            //sSalesOrderIDs.add(lTest_SalesOrders.get(2).ID);

           	lSalesInvoices = [SELECT ID FROM c2g__codaInvoice__c WHERE Ascent2FF__Sales_Order__c IN :sSalesOrderIDs];

            Test.stopTest();
            
        }
    }*/
    @isTest private static void testSharingAssignForPortalUsers () {

        User runner = new User(alias = 'hasrole', email='runner@roletest1.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = UserInfo.getProfileId(),
                    timezonesidkey='America/Los_Angeles', username='runner@testorg.com');

        User userWithRole = PortalTestUtils.createUserWithRole(runner);


        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();

        User superPortalUser;
        User hyperPortalUser;
        User hyperPortalUser2;

        PBSI__PBSI_Sales_Order__c superOrder;
        PBSI__PBSI_Sales_Order__c hyperOrder;
        PBSI__PBSI_Sales_Order__c hyperOrder2;
        PBSI__PBSI_Sales_Order__c ultraOrder;

        c2g__codaCompany__c company;
        List<c2g__codaInvoice__share> sharesBeforeUpdate;
        List<c2g__codaInvoice__c> invoices;
        Test.startTest();
        //company = TestUtility.createCompany(userWithRole, 'CHF', 'CH');

        System.runAs(userWithRole){

            accounts.add(new Account(Name='Supersports Inc.'));
            accounts.add(new Account(Name='Hypersports Inc.'));
            accounts.add(new Account(Name='Ultrasports Inc.'));
            
            insert accounts;

            contacts.add(new Contact(AccountId=accounts[0].Id, Lastname='Sslastname'));
            contacts.add(new Contact(AccountId=accounts[1].Id, Lastname='Hslastname'));
            contacts.add(new Contact(AccountId=accounts[1].Id, Lastname='Hslastname1'));
            contacts.add(new Contact(AccountId=accounts[2].Id, Lastname='Uslastname'));
            insert contacts;

            superPortalUser = PortalTestUtils.getPortalUser('michael@supersports.com', accounts[0], contacts[0], userWithRole, true);
            hyperPortalUser = PortalTestUtils.getPortalUser('thomas@hypersports.com', accounts[1], contacts[1], userWithRole, true);
            hyperPortalUser2 = PortalTestUtils.getPortalUser('katrin@ultrasports.com', accounts[1], contacts[2], userWithRole, true);

            superOrder = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = accounts[0].Id, PBSI__Contact__c=contacts[0].Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today());
            hyperOrder = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = accounts[1].Id, PBSI__Contact__c=contacts[1].Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today());
            hyperOrder2 = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = accounts[1].Id, PBSI__Contact__c=contacts[2].Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today());
            ultraOrder = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = accounts[2].Id, PBSI__Contact__c=contacts[3].Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today());
            insert new List<PBSI__PBSI_Sales_Order__C>{superOrder, hyperOrder, hyperOrder2, ultraOrder};
        
            invoices = new List<c2g__codaInvoice__c>();
        
            //invoices.add(new c2g__codaInvoice__c(c2g__Account__c = accounts[0].Id, c2g__OwnerCompany__c = company.Id, Ascent2FF__Sales_Order__c = superOrder.Id));
            //invoices.add(new c2g__codaInvoice__c(c2g__Account__c = accounts[1].Id, c2g__OwnerCompany__c = company.Id, Ascent2FF__Sales_Order__c = hyperOrder.Id));
            //invoices.add(new c2g__codaInvoice__c(c2g__Account__c = accounts[1].Id, c2g__OwnerCompany__c = company.Id, Ascent2FF__Sales_Order__c = hyperOrder2.Id));
            //invoices.add(new c2g__codaInvoice__c(c2g__Account__c = accounts[2].Id, c2g__OwnerCompany__c = company.Id, Ascent2FF__Sales_Order__c = ultraOrder.Id));
            /*insert invoices;*/
            /*sharesBeforeUpdate = [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[3].Id AND RowCause = 'Portal_user_access__c'];*/
            /*invoices[3].c2g__Account__c = accounts[1].Id;*/
            /*update invoices[3];*/
        }
        Test.stopTest();
        
        /*System.assertEquals(1, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[0].Id AND UserOrGroupId =: superPortalUser.Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(1, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[1].Id AND UserOrGroupId =: hyperPortalUser.Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(1, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[1].Id AND UserOrGroupId =: hyperPortalUser2.Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(2, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[1].Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(2, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[2].Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(0, sharesBeforeUpdate.size());*/
        /*System.assertEquals(2, [SELECT Id FROM c2g__codaInvoice__share WHERE ParentId =: invoices[3].Id AND RowCause = 'Portal_user_access__c'].size());*/
        /*System.assertEquals(5, [SELECT Id FROM c2g__codaInvoice__share WHERE RowCause = 'Portal_user_access__c'].size());*/
        
    }

    @isTest static void commentsFromSO() {
        TestDataFactory tdf = TestDataFactory.instance;
        String sampleComment = 'Sample comment';
        Account acc = tdf.accounts.createSObject('Test_account', 'CHF', true);
        PBSI__PBSI_Sales_Order__c so = tdf.salesOrders.createSObject(acc.Id, 'Re-Order', null, false);
        so.PBSI__Comments__c = sampleComment;
        insert so;
        c2g__codaInvoice__c inv = new c2g__codaInvoice__c(
            c2g__Account__c = acc.Id,
            Comments__c = null,
            Ascent2FF__Sales_Order__c = so.Id
        );
        Test.startTest();
        SalesInvoiceMethods.copyCommentFromSO(new List<c2g__codaInvoice__c>{inv});
        Test.stopTest();

        System.assertEquals(sampleComment, inv.Comments__c);
    }
}