@isTest
public with sharing class UserMethodsTest {
    
    @testSetup private static void setup () {
        User runner = new User(alias = 'runner', email='runner@on-running.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = UserInfo.getProfileId(),
                    timezonesidkey='America/Los_Angeles', username='runner@testorg.com');
        insert runner;

        User userWithRole = PortalTestUtils.createUserWithRole(runner);

        System.runAs(userWithRole){
            c2g__codaCompany__c company1 = TestUtility.createCompany(userWithRole, 'CHF', 'CH');
            
            Account a1 = new Account(Name='Supersports Inc');
            Account a2 = new Account(Name='Hypersports Inc');
            Account a3 = new Account(Name='Ultrasports Inc');
            insert new List<Account> {a1, a2, a3};
            Contact c1 = new Contact(LastName = 'TestContact', AccountId = a1.Id);
            Contact c2 = new Contact(LastName = 'TestContact', AccountId = a2.Id);
            Contact c3 = new Contact(LastName = 'TestContact', AccountId = a3.Id);
            insert new List<Contact> {c1, c2, c3};

            List<PBSI__PBSI_Sales_Order__c> orders = new List<PBSI__PBSI_Sales_Order__c>();
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a1.Id, PBSI__Contact__c=c1.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a1.Id, PBSI__Contact__c=c1.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a1.Id, PBSI__Contact__c=c1.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a1.Id, PBSI__Contact__c=c1.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a2.Id, PBSI__Contact__c=c2.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a2.Id, PBSI__Contact__c=c2.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a2.Id, PBSI__Contact__c=c2.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a3.Id, PBSI__Contact__c=c3.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a3.Id, PBSI__Contact__c=c3.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));
            orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a3.Id, PBSI__Contact__c=c3.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order', PBSI__Due_Date__c=Date.today()));

            insert orders;

            List<c2g__codaInvoice__c> invoices = new List<c2g__codaInvoice__c>();
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a1.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[0].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a1.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[1].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a1.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[2].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a1.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[3].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a2.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[4].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a2.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[5].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a2.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[6].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a3.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[7].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a3.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[8].Id));
            invoices.add(new c2g__codaInvoice__c(c2g__Account__c = a3.Id, c2g__OwnerCompany__c = company1.Id, Ascent2FF__Sales_Order__c = orders[9].Id));
            insert invoices;
            /*SalesInvoiceMethods.invoiceSalesOrders(new Set<Id>{superOrder.Id});*/
            /*c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(c2g__Account__c = a.Id, c2g__OwnerCompany__c = company.Id, Ascent2FF__Sales_Order__c = superOrder.Id);*/
            /*insert invoice;*/
        }
    }

    @isTest private static void testShareInsert () {
        System.debug('TEST DEBUG' + [SELECT ID FROM c2g__codaInvoice__c]);
        User userWithRole = [SELECT Id FROM User WHERE UserRole.Name = 'TEST ROLE'];
        User u1, u2, u3;
        Account superAcc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Supersports Inc'];
        Account hyperAcc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Hypersports Inc'];
        Account ultraAcc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Ultrasports Inc'];
        Contact superCont = [SELECT Id FROM Contact WHERE AccountId =: superAcc.Id];
        Contact hyperCont = [SELECT Id FROM Contact WHERE AccountId =: hyperAcc.Id];
        Contact ultraCont = [SELECT Id FROM Contact WHERE AccountId =: ultraAcc.Id];
        
        Test.startTest();
        System.runAs(userWithRole) {
            u1 = PortalTestUtils.getPortalUser('michael@supersports.com', superAcc, superCont, userWithRole, true);
            u2 = PortalTestUtils.getPortalUser('micheal@hypersports.com', hyperAcc, hyperCont, userWithRole, true);
            u3 = PortalTestUtils.getPortalUser('thomas@ultrasports.com', ultraAcc, ultraCont, userWithRole, true);
			final Set<Id> sUserIds = new Set<Id>();
			sUserIds.add(u1.Id);
			sUserIds.add(u2.Id);
			sUserIds.add(u3.Id);
			UserMethods.grantAccountContactEditForPortalUsers(sUserIds);
        }
        Test.stopTest(); 
        
        System.assertEquals(4, [SELECT Id FROM c2g__codaInvoice__share WHERE UserOrGroupId = : u1.Id].size());
        System.assertEquals(3, [SELECT Id FROM c2g__codaInvoice__share WHERE UserOrGroupId = : u2.Id].size());
        System.assertEquals(3, [SELECT Id FROM c2g__codaInvoice__share WHERE UserOrGroupId = : u3.Id].size());
        System.assertEquals(1, [SELECT Id FROM AccountShare WHERE UserOrGroupId = : u1.Id AND AccountId =: superAcc.Id].size());
        /*System.assertEquals(3, [SELECT Id FROM c2g__codeInvoice__share WHERE UserOrGroupId = : u1.Id].size());*/
        /*System.assertEquals(4, [SELECT Id FROM c2g__codeInvoice__share WHERE ParentId = : superAcc.Id].size());*/
    }
}