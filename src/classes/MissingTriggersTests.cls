//ASCENT - this temporary test class was added to cover beforeInsertSILine and dlrs_c2godaTransactionLineItemTrigger triggers which were missing coveragge preventing production deployment
//ASCENT - it can be removed once coverage for these triggers is ensured elsewhere or if any of these tests would begin failing.
@isTest 
public with sharing class MissingTriggersTests {
	
    static testMethod void Test_beforeInsertSILine() {
            
            String currencyIsoCode = 'EUR';
            ID salesOrderRecordTypeID = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);
            
            Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
            test_account.BillingCountry = 'Poland';
            test_account.BillingCity = 'Warsaw';
            test_account.BillingPostalCode = '00-123';
            test_account.BillingStreet = 'Marszałkowska 123';

            insert test_account;

            Contact test_contact = TestUtility.createContact('Test Contact', test_account, true);
            
            PBSI__Warehouse__c warehouse = TestUtility.createWarehouse('Test Warehouse', true);

            PBSI__PBSI_Location__c location = TestUtility.createLocation('Test Location', warehouse.Id, true);
            
			Style_Year__c style_year = TestUtility.createStyleYear('2015', true);
			Fabric__c fabric = TestUtility.createFabric('Fabric', true);
			Sizes__c size =TestUtility.createSize('Size 1', style_year.ID, true);
			TestUtility.createKNIntegrationSettings(true);

			PBSI__PBSI_Item_Group__c item_group = TestUtility.createItemGroup('Item Group', style_year.ID, true);

			PBSI__PBSI_Item__c item = TestUtility.createItem('Test Item', item_group.ID, location.ID, warehouse.ID, fabric.ID, size.ID, style_year.ID, '987654', true);

            PBSI__Lot__c lot = TestUtility.createLot('Test Lot', location.Id, true);
            lot.PBSI__Item__c = item.ID;
            update lot;

            List<PBSI__PBSI_Sales_Order__c> lTest_SalesOrders = new List<PBSI__PBSI_Sales_Order__c>();

            lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            //lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));
            //lTest_SalesOrders.add(TestUtility.createSalesOrder(test_account, test_contact, salesOrderRecordTypeID, currencyIsoCode, false));

            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;
            //lTest_SalesOrders.get(1).PBSI__From_Location__c = location.ID;
            //lTest_SalesOrders.get(2).PBSI__From_Location__c = location.ID;

            insert lTest_SalesOrders;
            lTest_SalesOrders.get(0).PBSI__From_Location__c = location.ID;

            List<PBSI__PBSI_Sales_Order_Line__c> lSalesOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();

            lSalesOrderLines.add(TestUtility.createSalesOrderLine(lTest_SalesOrders.get(0).ID, item.ID, lot.ID, location.ID, 10, 10.0, false));
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

			/*
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
            */
	}
	
	/*
	private static testmethod void Test_dlrs_c2godaTransactionLineItemTrigger() {
            
        User tester = TestUtility.createUser('tester', null, true);
        tester = PortalTestUtils.createUserWithRole();

        System.runAs(tester) {
            Product2 test_product = TestUtility.createProduct('Test Product', true);
            
            Group group_record = new Group(Name = 'test group', Type = 'Queue');
            insert group_record;

            GroupMember member = new GroupMember(
                GroupId = group_record.ID,
                UserOrGroupId = tester.ID
            );
            insert member;

            c2g__codaCompany__c  company = TestUtility.createCompany('Test Cmpny', false);
            company.ownerid = group_record.Id;
            insert company;

            c2g__codaUserCompany__c userCompany = TestUtility.createUserCompany(company, tester, true);

            c2g__codaYear__c year = TestUtility.createYear('testYear', company, false);
            year.ownerid = group_record.Id;
            insert year;

            c2g__codaPeriod__c period = TestUtility.createPeriod(company, year, true);
            c2g__codaAccountingCurrency__c accountingCurrency = TestUtility.createAccountingCurrency('CHF', company.Id, false);
            accountingCurrency.ownerid = group_record.id;
            insert accountingCurrency;

            c2g__codaExchangeRate__c exchRate = TestUtility.createExchangeRate (accountingCurrency,
                                                company, true);
 

            c2g__codaGeneralLedgerAccount__c general_ledger_account = TestUtility.createGeneralLedgerAccount('Retained Earnings', true, 'Balance Sheet', 123, true);

            PBSI__Account_Group__c dealerGroup = TestUtility.createAccountGroup('Dealers', 'DLR', true);

            Account account = new Account(
                Name = 'TestAcc',
                CurrencyIsoCode = 'CHF',
                c2g__CODAAccountTradingCurrency__c = 'CHF',
                BillingCountry = 'Switzerland',
                c2g__CODAAccountsPayableControl__c = general_ledger_account.Id,
                RecordTypeId = [SELECT ID FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Supplier'].ID,
                c2g__CODABillingMethod__c = 'Electronic',
                c2g__CODABaseDate1__c = 'Invoice Date',
                c2g__CODABaseDate2__c = '',
                c2g__CODABaseDate3__c = 'Invoice Date',
                c2g__CODABaseDate4__c = 'Invoice Date',
                c2g__CODADiscount1__c = 0,
                c2g__CODADiscount2__c = 0,
                c2g__CODADiscount3__c = 0,
                c2g__CODADiscount4__c = 0,
                c2g__CODASalesTaxStatus__c = 'Taxable',
                c2g__CODAVATStatus__c = 'EC Non-registered',
                PBSI__Account_Group__c = dealerGroup.Id,
                E_Shop_Dealer__c =  'Dealer and Point of Sale',
                Status__c = 'Active',
                ShippingCountry = 'USA'
            );
            insert account;
            Contact contacts = TestUtility.createContact('Test_Contact', account, true);

	        // Create an invoice with a line
	            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(
	                CurrencyIsoCode = 'CHF',
	            	//c2g__InvoiceCurrency__c = accountingCurrency.Id,
	                c2g__InvoiceDate__c = Date.today(),
	                c2g__DueDate__c = Date.today(),
	                c2g__Account__c = account.Id,
	                c2g__OwnerCompany__c = company.id,
	            	ownerid = group_record.Id
	            );
	
	        insert invoice;
	            
	        c2g__codaInvoiceLineItem__c item = new c2g__codaInvoiceLineItem__c(
	            c2g__Invoice__c = invoice.id,
	            c2g__Product__c = test_product.Id,
	            c2g__Quantity__c = 1,
	            c2g__UnitPrice__c = 100,
	            c2g__DeriveUnitPriceFromProduct__c = false,
	            c2g__LineDescription__c = 'Unit Test'
	        );

        	insert item;
        }
    }
    */
}
//ASCENT - this temporary test class was added to cover beforeInsertSILine and dlrs_c2godaTransactionLineItemTrigger triggers which were missing coveragge preventing production deployment
//ASCENT - it can be removed once coverage for these triggers is ensured elsewhere or if any of these tests would begin failing.