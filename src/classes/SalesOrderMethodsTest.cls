/**
 * Class contains methods that are using to test SalesOrderMethods methods.<br>
 * Class's methods use methods from TestUtility to create test data.<br>
 * The test methods that are included to this class use existing records of Company object.<br>
 * There is needed to have although one Company record in the System for the proper functioning of test methods.
 *
 * @version 3.0  2015.02.23  Ewa Byra <ewa.byra@nefoscdc.com>.
 *                           Created assingCompanyTest() test method.
 *
 * @version 2.0  2014.09.21  Ewa Byra <ewa.byra@nefoscdc.com>.
 *                           Created assingCompanyTest() test method.
 *
 * @version 1.0  2014.08.18  Ewa Byra <ewa.byra@nefoscdc.com>.
 *                           Initial version of class.
 *
 * @see SalesOrderMethods APEX class.
 * @see TestUtility APEX class.
 */

@isTest(SeeAllData=true)
public without sharing class SalesOrderMethodsTest {

    /**
     *
     */
    public static testMethod void updateNumberOfStylesTest() {
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

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c, PBSI__Item__r.Name FROM PBSI__Lots__r) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();

            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));

            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            insert lTest_SalesOrders;

            List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 50, 10.0, false));

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 50, 10.0, false));

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 50, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 50, 10.0, false));

            Set<String> sStyles = new Set<String>();

            sStyles.add(location.PBSI__Lots__r.get(0).PBSI__Item__r.Name.split(' ').get(0));
            sStyles.add(location.PBSI__Lots__r.get(1).PBSI__Item__r.Name.split(' ').get(0));
            sStyles.add(location.PBSI__Lots__r.get(2).PBSI__Item__r.Name.split(' ').get(0));
            sStyles.add(location.PBSI__Lots__r.get(3).PBSI__Item__r.Name.split(' ').get(0));

            Integer exeptedValue = sStyles.size();

            Test.startTest();

            insert lSalesOrderLines;


            lTest_SalesOrders = [SELECT ID, Number_of_styles__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(0).ID OR ID = :lTest_SalesOrders.get(1).ID OR ID = :lTest_SalesOrders.get(2).ID];

            System.assertEquals((exeptedValue > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED ? exeptedValue : null), lTest_SalesOrders.get(0).Number_of_styles__c);
            System.assertEquals((exeptedValue > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED ? exeptedValue : null), lTest_SalesOrders.get(1).Number_of_styles__c);
            System.assertEquals((exeptedValue > SalesOrderLineMethods.QUANTITY_LIMIT_NOT_CALCULATED ? exeptedValue : null), lTest_SalesOrders.get(2).Number_of_styles__c);

            Test.stopTest();
        }
    }

    /**
     * Test of SalesOrderMethods.assignCompany(Map<ID, PBSI__PBSI_Sales_Order__c>, Map<ID, PBSI__PBSI_Sales_Order__c>) method.<br>
     * There is assuption that although one Company record existis in the System.
     */
	public static testMethod void assingCompanyTest() {
        System.runAs(TestUtility.createUser('tester', null, true)) {
            System.assert([SELECT count() FROM c2g__codaCompany__c] > 0);
            TestUtility.enableAllFeatures();

            Map<String, CountryToCompanyMapping__c> mCountryToCompany = CountryToCompanyMapping__c.getAll();
            List<pw_ccpro__CountryObject__c> lCountries;

            if ([SELECT count() FROM pw_ccpro__CountryObject__c] == 0) {

                lCountries = new List<pw_ccpro__CountryObject__c>();

                lCountries.add(TestUtility.createCountry('Poland', 'PL', 'PLN', false));
                lCountries.add(TestUtility.createCountry('Italy', 'IT', 'ITA', false));
                lCountries.add(TestUtility.createCountry('Switzerland', 'CH', 'CHE', false));

                insert lCountries;
            }

            if ([SELECT count() FROM CountryToCompanyMapping__c] == 0 ||
                !mCountryToCompany.containsKey('PL') ||
                !mCountryToCompany.containsKey('IT') ||
                !mCountryToCompany.containsKey('CH')) {

                List<CountryToCompanyMapping__c> lCountryToCompanyMappingRecords = new List<CountryToCompanyMapping__c>();
                List<c2g__codaCompany__c> lCompanies = [SELECT ID FROM c2g__codaCompany__c];
                Integer i;

                if (!mCountryToCompany.containsKey('PL')) {
                    i = Math.mod(Math.round(Math.random() * 1000), lCompanies.size() - 1);
                    lCountryToCompanyMappingRecords.add(TestUtility.createCountryToCompanyMappingRecord('PL', String.valueOf(lCompanies.get(i).ID), false));
                }

                if (!mCountryToCompany.containsKey('IT')) {
                    i = Math.mod(Math.round(Math.random() * 1000), lCompanies.size() - 1);
                    lCountryToCompanyMappingRecords.add(TestUtility.createCountryToCompanyMappingRecord('IT', String.valueOf(lCompanies.get(i).ID), false));
                }

                if (!mCountryToCompany.containsKey('CH')) {
                    i = Math.mod(Math.round(Math.random() * 1000), lCompanies.size() - 1);
                    lCountryToCompanyMappingRecords.add(TestUtility.createCountryToCompanyMappingRecord('CH', String.valueOf(lCompanies.get(i).ID), false));
                }

                insert lCountryToCompanyMappingRecords;
            }

            String currencyIsoCode = 'EUR';
            /*ID salesOrderRecordTypeID = [SELECT ID FROM RecordType WHERE SobjectType = 'PBSI__PBSI_Sales_Order__c' LIMIT 1].ID;*/
			Id webOrderRecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order');

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();
            List<Account> lAccounts = new List<Account>();
            List<Contact> lContacts = new List<Contact>();
            lCountries = [SELECT ID, Name FROM pw_ccpro__CountryObject__c WHERE Name IN ('Poland', 'Italy', 'Switzerland') ORDER BY Name DESC];

            Account test_account_PL = TestUtility.createAccount('Test Account PL', currencyIsoCode, false);
            Account test_account_VA = TestUtility.createAccount('Test Account IT', currencyIsoCode, false);
            Account test_account_SM = TestUtility.createAccount('Test Account CH', currencyIsoCode, false);

            test_account_PL.BillingCountry = 'Poland';
            test_account_PL.ShippingCountry = 'Poland';
            test_account_PL.BillingCity = 'Warsaw';
            test_account_PL.BillingPostalCode = '00-123';
            test_account_PL.BillingStreet = 'Marszałkowska 123';
            test_account_PL.Status__c = 'Active';
            test_account_PL.pw_ccpro__ShippingCountryLookup__c = lCountries.get(1).ID;

			test_account_VA.ShippingCountry = 'Italy';
            test_account_VA.BillingCountry = 'Italy';
            test_account_VA.BillingCity = 'Vatican';
            test_account_VA.BillingPostalCode = '00120';
            test_account_VA.BillingStreet = 'Apostolic Palace';
            test_account_VA.Status__c = 'Active';
            test_account_VA.pw_ccpro__ShippingCountryLookup__c = lCountries.get(2).ID;

            test_account_SM.BillingCountry = 'Switzerland';
            test_account_SM.ShippingCountry = 'Switzerland';
            test_account_SM.BillingCity = 'Zürich';
            test_account_SM.BillingPostalCode = '8001';
            test_account_SM.BillingStreet = 'Contrada Omerelli 20';
            test_account_SM.Status__c = 'Active';
            test_account_SM.pw_ccpro__ShippingCountryLookup__c = lCountries.get(0).ID;

            lAccounts.add(test_account_PL);
            lAccounts.add(test_account_VA);
            lAccounts.add(test_account_SM);

            insert lAccounts;

            lContacts.add(TestUtility.createContact('Test Contact PL', lAccounts.get(0), false));
            lContacts.add(TestUtility.createContact('Test Contact IT', lAccounts.get(1), false));
            lContacts.add(TestUtility.createContact('Test Contact CH', lAccounts.get(2), false));

            insert lContacts;

            lTest_SalesOrders.add(TestUtility.createSalesOrder(lAccounts.get(0), lContacts.get(0), webOrderRecordTypeId, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(lAccounts.get(1), lContacts.get(1), webOrderRecordTypeId, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(lAccounts.get(2), lContacts.get(2), webOrderRecordTypeId, currencyIsoCode, false));

            lTest_SalesOrders.get(0).PBSI__Delivery_Country__c = lCountries.get(1).Name;
            lTest_SalesOrders.get(1).PBSI__Delivery_Country__c = lCountries.get(2).Name;
            lTest_SalesOrders.get(2).PBSI__Delivery_Country__c = lCountries.get(0).Name;

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c FROM PBSI__Lots__r) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];
            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            insert lTest_SalesOrders;

            /*System.assertEquals(mCountryToCompany.get('PL').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(0).ID].Ascent2FF__Company__c);*/
            /*System.assertEquals(mCountryToCompany.get('IT').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(1).ID].Ascent2FF__Company__c);*/
            /*System.assertEquals(mCountryToCompany.get('CH').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(2).ID].Ascent2FF__Company__c);*/

            for (PBSI__PBSI_Sales_Order__c salesOrder : lTest_SalesOrders) {
                salesOrder.Web_Order_Stage_Reached__c = SalesOrderMethods.WEB_ORDER_COMPLETE_STATUS_VALUE;
            }

            lTest_SalesOrders.get(0).PBSI__Delivery_Country__c = lCountries.get(0).Name;
            lTest_SalesOrders.get(1).PBSI__Delivery_Country__c = lCountries.get(1).Name;
            lTest_SalesOrders.get(2).PBSI__Delivery_Country__c = lCountries.get(2).Name;

            Test.startTest();

            update lTest_SalesOrders;

            Test.stopTest();

            mCountryToCompany = CountryToCompanyMapping__c.getAll();

            System.debug(LoggingLevel.INFO, '********************************** mCountryToCompany: ' + mCountryToCompany);
            System.debug(LoggingLevel.INFO, '********************************** Sales Order: ' + [SELECT ID, PBSI__Delivery_Country__c, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(0).ID]);

            System.assertEquals(mCountryToCompany.get('CH').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(0).ID].Ascent2FF__Company__c);
            System.assertEquals(mCountryToCompany.get('PL').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(1).ID].Ascent2FF__Company__c);
            System.assertEquals(mCountryToCompany.get('IT').Company_ID__c, [SELECT ID, Ascent2FF__Company__c FROM PBSI__PBSI_Sales_Order__c WHERE ID = :lTest_SalesOrders.get(2).ID].Ascent2FF__Company__c);

            delete lTest_SalesOrders;

            undelete lTest_SalesOrders;
        }
	}

    /**
     * Method used to test automation of the packing process.
     */
    public static testMethod void webOrdersPackagingProcessTest() {
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
			test_account.ShippingCountry = 'Poland';

            insert test_account;

            Contact test_contact = TestUtility.createContact('Test Contact', test_account, true);

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c FROM PBSI__Lots__r WHERE PBSI__Total_Quantity__c != 0 LIMIT 5) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();

            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));

            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            System.debug(LoggingLevel.WARN, ' ******* 266 Inserting Orders !!! ********');
            insert lTest_SalesOrders;

            List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(1).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(2).PBSI__Item__c, location.PBSI__Lots__r.get(2).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(2).ID, location.PBSI__Lots__r.get(3).PBSI__Item__c, location.PBSI__Lots__r.get(3).ID, location.ID, 10, 10.0, false));

            System.debug(LoggingLevel.WARN, ' ******* 286 Inserting Lines !!********');
            insert lSalesOrderLines;
        
            
            Test.startTest();

            for (PBSI__PBSI_Sales_Order__c salesOrder : lTest_SalesOrders) {
                salesOrder.Web_Order_Stage_Reached__c = SalesOrderMethods.WEB_ORDER_COMPLETE_STATUS_VALUE;
            }

            System.debug(LoggingLevel.WARN, ' ******* 293 Updating Sales Orders ********');
            update lTest_SalesOrders;

            Set<ID> sSalesOrderIDs = new Set<ID>();
            sSalesOrderIDs.add(lTest_SalesOrders.get(0).ID);
            sSalesOrderIDs.add(lTest_SalesOrders.get(1).ID);
            sSalesOrderIDs.add(lTest_SalesOrders.get(2).ID);

            lTest_SalesOrders = [SELECT ID, PBSI__Customer__r.BillingCountry, PBSI__Status__c, PBSI__Stage__c, Error_Message__c
                                 FROM PBSI__PBSI_Sales_Order__c
                                 WHERE ID IN :sSalesOrderIDs];

            // check country iso code setting
            Map<ID, String> mSalesOrderIDToCountryISOCode = SalesOrderMethods.getSalesOrderIDToCountryISOCode(lTest_SalesOrders);

            for (ID salesOrderID : mSalesOrderIDToCountryISOCode.keySet()) {
                System.assertEquals('PL', mSalesOrderIDToCountryISOCode.get(salesOrderID));
            }

            Test.stopTest();
        }
    }


    /**
    * Tests updateNumberOfStyles(...)
    * @author Ivan Durlen 2016-05-20
    */
    @isTest
    static void testUpdateNoOfStyles(){
            String currencyIsoCode = 'EUR';

            Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
            test_account.BillingCountry = 'Poland';
            test_account.BillingCity = 'Warsaw';
            test_account.BillingPostalCode = '00-123';
            test_account.BillingStreet = 'Marszałkowska 123';
            insert test_account;

            Contact test_contact = TestUtility.createContact('Test Contact', test_account, true);

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c, PBSI__Item__r.Name FROM PBSI__Lots__r) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];

            Id salesOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);

            PBSI__PBSI_Sales_Order__c so = TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false);
            insert so;

            List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(so.Id, location.PBSI__Lots__r.get(0).PBSI__Item__c, location.PBSI__Lots__r.get(0).ID, location.ID, 10, 10.0, false));
            lSalesOrderLines.add(TestUtility.createSalesOrderLine(so.Id, location.PBSI__Lots__r.get(1).PBSI__Item__c, location.PBSI__Lots__r.get(1).ID, location.ID, 10, 10.0, false));
            insert lSalesOrderLines;

            Set<Id> sSoIds = new Set<Id>{so.Id};

            Test.startTest();
            SalesOrderMethods.updateNumberOfStyles(sSoIds);
            Test.stopTest();
    }


    /**
    * Tests method SalesOrderMethods.getOrdersFromMap()
    * @author Ivan Durlen 2016-05-20
    */
    @isTest
    static void testGetOrdersFromMap(){
            String currencyIsoCode = 'EUR';

            Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
            test_account.BillingCountry = 'Poland';
            test_account.BillingCity = 'Warsaw';
            test_account.BillingPostalCode = '00-123';
            test_account.BillingStreet = 'Marszałkowska 123';
            insert test_account;

            Contact test_contact = TestUtility.createContact('Test Contact', test_account, true);

            PBSI__PBSI_Location__c location = [SELECT ID, (SELECT ID, PBSI__List_Price__c, PBSI__Total_Quantity__c, PBSI__Item__c, PBSI__Item__r.Name FROM PBSI__Lots__r) FROM PBSI__PBSI_Location__c WHERE Name = 'EU-Stock'];

            Id salesOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            insert lTest_SalesOrders;

            Map<Id, PBSI__PBSI_Sales_Order__c> mOrdersById = new Map<Id, PBSI__PBSI_Sales_Order__c>();
            List<Id> lSalesOrderIds = new List<Id>();
            for(PBSI__PBSI_Sales_Order__c so : lTest_SalesOrders){
                mOrdersById.put(so.Id, so);
                lSalesOrderIds.add(so.Id);
            }

            SalesOrderMethods.getOrdersFromMap(lSalesOrderIds, mOrdersById);
    }
    
}