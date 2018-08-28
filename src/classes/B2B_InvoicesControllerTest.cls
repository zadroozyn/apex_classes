@isTest
private class B2B_InvoicesControllerTest {

    @testSetup
    static void init() {
        User tester = TestUtility.createUser('tester', null, true);
        tester = PortalTestUtils.createUserWithRole();
        //==========================================
        c2g__codaCompany__c companyTmp = new c2g__codaCompany__c();
        companyTmp.Name = 'testCompany';
        insert companyTmp;

        Group companyGroup = null;

        System.runAs(tester) {
            //Group group_record = new Group(Name = 'test group', Type = 'Queue');
            //insert group_record;

            //QueuesObject queue = new QueuesObject(QueueID = group_record.id, sObjectType = 'c2g__codaPurchaseInvoice__c');
            //insert  queue;

            //GroupMember member = new GroupMember(
            //    GroupId = group_record.ID,
            //    UserOrGroupId = tester.ID
            //);
            //insert member;
            //=======================================

            c2g.CODACompanyWebService.createQueue(companyTmp.Id, 'CAD', companyTmp.Name);
            c2g.CODAYearWebService.calculatePeriods(null);
            c2g.CODACompanyWebService.activateCompany(companyTmp.Id, 'CAD', companyTmp.Name);

            String queueName = 'FF ' + companyTmp.Name;
            companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];
            insert new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = tester.Id);

            //=======================================
           

            c2g__codaUserCompany__c userCompany = TestUtility.createUserCompany(companyTmp, tester, true);

            c2g__codaYear__c year = TestUtility.createYear('testYear', companyTmp, false);
            year.ownerid = companyGroup.Id;
            insert year;

            c2g__codaPeriod__c period = TestUtility.createPeriod(companyTmp, year, true);
            c2g__codaAccountingCurrency__c accountingCurrency = TestUtility.createAccountingCurrency('CHF', companyTmp.Id, false);
            accountingCurrency.ownerid = companyGroup.id;
            insert accountingCurrency;


            c2g__codaExchangeRate__c exchRate = TestUtility.createExchangeRate (accountingCurrency,
                                                companyTmp, true);

            c2g__codaGeneralLedgerAccount__c general_ledger_account = TestUtility.createGeneralLedgerAccount('Retained Earnings', true, 'Balance Sheet', 123, true);

            PBSI__Account_Group__c dealerGroup = TestUtility.createAccountGroup('Dealers', 'DLR', true);

            Account account = new Account(
                Name = 'TestAcc',
                CurrencyIsoCode = 'CHF',
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
                ShippingCountry = 'USA'
            );
            insert account;
            Contact contacts = TestUtility.createContact('Test_Contact', account, true);

			PBSI__PBSI_Location__c loc = new PBSI__PBSI_Location__c(Name = 'Test location');
			insert loc;
			PBSI__PBSI_Sales_Order__c order = new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = account.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='Forecast', PBSI__From_Location__c = loc.Id);
			insert order;
			/*PortalTestUtils.generateSOLines(order);*/

            c2g__codaInvoice__c testInvoice = new c2g__codaInvoice__c(
                CurrencyIsoCode = 'USD',
                c2g__InvoiceDate__c = Date.today().addDays(-7),
                c2g__DueDate__c = Date.today().addDays(-7),
                c2g__Account__c = account.Id,
                c2g__OwnerCompany__c = companyTmp.id,
                ownerid = companyGroup.Id,
				Ascent2FF__Sales_Order__c = order.Id
            );
            insert testInvoice;
            /*
			testInvoice.c2g__InvoiceStatus__c = 'Complete';
			PBSI__PBSI_Sales_Order_Line__c testLine = [select id from 
			c2g__codaInvoiceLineItem__c invoiceLine = new c2g__codaInvoiceLineItem__c(c2g__Invoice__c=testInvoice.Id, 
            Ascent2FF__Sales_Order_Line__c = 
			update testInvoice;*/
        }
    }


    @isTest
    static void testController() {
        Profile p = [Select Id From Profile Where Name = 'Backstage Dealer'];
        Contact c = [Select Id From Contact];


        User usr = TestUtility.createUser('TestUsr', p.Id, false);
        usr.ContactId = c.Id;
        insert usr;
		usr = [SELECT Id, ContactId, AccountId FROM User WHERE Id =: usr.Id];

		List<SalesInvoiceWrapper> invoices;
        System.runAs(usr) {
            B2B_InvoicesController ctrl = new B2B_InvoicesController();
			/*System.assertEquals(1, ctrl.getInvoices().size());*/

            String[] defaultPaymentStatus = new String[] {
                'Paid', 'Unpaid', 'Part Paid'
            };

            String[] defaultInvoicesCreditNotes = new String[] {
                'Invoices', 'Credit Notes'
            };

             
            SelectOption[] defaultOptions = new SelectOption[] {
                new SelectOption('Invoices', Label.B2B_Invoices_Invoices),
                new SelectOption('Credit Notes', Label.B2B_Invoices_Credit_Notes)
            };
            //ctrl.filterInvoicesCreditNotes();
            
            List<c2g__codaInvoice__c> lCreditNotes = [SELECT id, name FROM c2g__codaInvoice__c];
    

            System.assertEquals(defaultInvoicesCreditNotes, ctrl.filterInvoicesCreditNotes);
            System.assertEquals(defaultOptions, ctrl.getInvoiceCreditNotes());

            System.assertEquals(defaultPaymentStatus, ctrl.filterPaymentStatus);
			System.assertEquals('1/1/' + Date.today().year(), ctrl.filterInvoiceDateFrom.textField);
			System.assertEquals('12/31/' + Date.today().year(), ctrl.filterInvoiceDateTo.textField);
            //========================================================================================
            System.assertEquals('1/1/' + Date.today().year(), ctrl.filterCreditNoteDateFrom.textField);
            System.assertEquals('12/31/' + Date.today().year(), ctrl.filterCreditNoteDateTo.textField);
            //========================================================================================
			System.assertEquals('1/1/' + Date.today().year(), ctrl.filterDueDateFrom.textField);
			System.assertEquals('12/31/' + Date.today().year(), ctrl.filterDueDateTo.textField);
            //=======================================================================================
            ctrl.filterCreditNoteDateFrom.textField = '1/2/2014';
            ctrl.filterCreditNoteDateTo.textField = '2/28/2014';
			ctrl.filterInvoiceDateFrom.textField = '1/2/2014';
			ctrl.filterInvoiceDateTo.textField = '2/28/2014';
			ctrl.filterDueDateFrom.textField = '3/3/2012';
			ctrl.filterDueDateTo.textField = '10/31/2012';
			ctrl.getPaymentStatuses();
			System.assertEquals('1/2/2014', ctrl.filterInvoiceDateFrom.textField);
			System.assertEquals('2/28/2014', ctrl.filterInvoiceDateTo.textField);
            System.assertEquals('1/2/2014',  ctrl.filterCreditNoteDateFrom.textField);
            System.assertEquals('2/28/2014', ctrl.filterCreditNoteDateTo.textField);
            //=======================================================================================
			System.assertEquals('3/3/2012', ctrl.filterDueDateFrom.textField);
			System.assertEquals('10/31/2012', ctrl.filterDueDateTo.textField);
			ctrl.getInvoices();
			ctrl.clearFilterValues();

        }
		
    }

}