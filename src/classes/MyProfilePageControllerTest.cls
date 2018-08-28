/**
*@Name: MyProfilePageControllerTest.cls
*@Author: Piotr Kożuchowski <piotr.kozuchowski@nefoscdc.com>
*@Description: Description
*/
@IsTest
public class MyProfilePageControllerTest {

    @testSetup
    static void init() {
        UserRole adminRole = [SELECT Id, Name FROM UserRole WHERE Name = 'On Admin'];
        User adminUser = TestUtil.createAdminUser('Adm@on-running.test');
        adminUser.UserRoleId = adminRole.Id;
        update adminUser;
        System.runAs(adminUSer) {
            c2g__codaCompany__c company = TestUtility.createCompany(adminUser, 'CHF', 'CH');
            Id customerPortalProfileID = [SELECT Id From Profile WHERE Name = 'Customer Community Plus Login User'][0].Id;
            Account testAccount = new Account(OwnerId = adminUser.Id, Name = 'Customer Portal Login Test Account', CurrencyIsoCode='CHF', c2g__CODAAccountTradingCurrency__c='');
            insert testAccount;
            Contact testContact = new Contact(LastName = 'Test contact', AccountId = testAccount.Id);
            insert testContact;
            User testCustomerPortalUser = PortalTestUtils.getPortalUser('test.user@on-running.test', testAccount, testContact, adminUser, true);
            /*)= new User(Username = 'test.user@on-running.test', Email = 'test.user@example.com',*/
                                                   /*FirstName = 'John', LastName = 'Smith', CommunityNickname = 'JSmith',*/
                                                   /*ContactId = testContact.Id, Alias = 'JSmith', ProfileId = customerPortalProfileID,*/
                                                   /*EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'de_CH', TimeZoneSidKey = 'GMT');*/
            /*insert testCustomerPortalUser;*/
            TestUtility.createUserCompany(company, testCustomerPortalUser, true); // method creates c2g__codaUserCompany__c record
            System.setPassword(testCustomerPortalUser.Id, 'Test1234');
        }
    }

    @isTest
    static void testController() {
        User usr = [Select Id, AccountId, ContactId, LastName From User Where Username = 'test.user@on-running.test'];
        System.runAs(usr) {
            PageReference myprofilePage = Page.MyProfilePage;
            Test.setCurrentPage(MyProfilePage);
            MyProfilePageController ctrlr = new MyProfilePageController();

            System.assertEquals(usr.Id, ctrlr.user.Id);
            System.assertEquals(usr.ContactId, ctrlr.user.Contact.Id);
            System.assertEquals(usr.AccountId, ctrlr.userAccount.Id);

            System.currentPageReference().getParameters().put('page', 'account');

            String userName = ctrlr.user.LastName;
            ctrlr.user.LastName = 'TestName';

            String contactName = ctrlr.user.Contact.LastName;
            ctrlr.user.Contact.LastName = 'TestName';

            String accountName = ctrlr.userAccount.Name;
            ctrlr.userAccount.Name = 'TestName';

            ctrlr.loadDefaults();

            System.assertEquals(userName, ctrlr.user.LastName);
            System.assertEquals(contactName, ctrlr.user.Contact.LastName);
            System.assertEquals(accountName, ctrlr.userAccount.Name);

            ctrlr.user.Contact.LastName = 'TestName';
            ctrlr.userAccount.Name = 'TestName';

            ctrlr.save();
            ctrlr.loadDefaults();
			ctrlr.getDistributorFunctionPicklistValues();
			ctrlr.getShoeSizes();

            System.assertEquals('TestName', ctrlr.user.LastName);
            System.assertEquals('TestName', ctrlr.user.Contact.LastName);
            /*System.assertEquals('TestName', ctrlr.userAccount.Name);*/
            System.assertEquals('Customer Portal Login Test Account', ctrlr.userAccount.Name);
        }
    }
}