@isTest
public with sharing class PortalTestUtils {
    private static final String communityProfileName = 'Backstage Dealer';

    private static Integer userNameCounter = 0;
    
    public static User getPortalUser(String communityUserName, Account account, Contact contact, User userWithRole, boolean doInsert){
        // Checks if user that performs insert was provided
        if(userWithRole == null) {
            //Checks if user that performs insert has roleId
            if(UserInfo.getUserRoleId() == null){
                UserRole ur = new UserRole(Name='Test role');
                Database.insert(ur);

                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = ur.id,
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = UserInfo.getProfileId(),
                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            System.assert(userWithRole.userRoleId != null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }
        Account a;
        Contact c;
        System.runAs(userWithRole) {
            if(account == null){
                account = new Account(Name='Test account');
                Database.insert(account);
                contact = new Contact(AccountId = a.id, lastname = 'Lastname');
                Database.insert(contact);
            } else if(account.OwnerId != userWithRole.Id) {
                account.OwnerId = userWithRole.Id;
                contact.OwnerId = userWithRole.Id; 
                Database.update(account);
                Database.update(contact);
            }
            if(contact == null){
                contact = new Contact(AccountId = a.id, lastname = 'Lastname');
                Database.insert(contact);
            }
            /*a = new Account(Name='Test account');*/
            /*c = new Contact(AccountId = a.id, lastname = 'lastname');*/
            /*Database.insert(a);*/
            /*Database.insert(c);*/

        }
        Profile p = [SELECT Id FROM Profile WHERE Name =: communityProfileName LIMIT 1];
        String testemail;
        If(String.isBlank(communityUserName)){
            testemail = 'communityUser' + userNameCounter++ + '@on-running.b2b-test';
        } else {
            testemail = communityUserName;
        }
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = contact .id);
        
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    } 

    public static User getPortalUser(User userWithRole, Boolean doInsert) {
    
        /* Make sure the running user has a role otherwise an exception 
           will be thrown. */
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {

                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                
                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
            System.assert(userWithRole.userRoleId!= null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        Account a;
        Contact c;
        System.runAs(userWithRole) {

            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);
            
            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);

        List<PBSI__PBSI_Sales_Order__c> orders = new List<PBSI__PBSI_Sales_Order__c>();
        orders.add(new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = a.Id, PBSI__BillingCountry__c = 'BC', Sales_Order_Type__c='New Order'));
        insert orders;
        }
        
        /* Get any profile for the given type.*/
        
        Profile p = [SELECT Id FROM Profile WHERE Name =: communityProfileName LIMIT 1];
        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = c.id);
        
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    }
    
    public static User createUserWithRole (User runner) {
        User userWithRole;
        System.runAs(runner){
            UserRole ur = new UserRole(Name='Test role');
            insert ur;

            userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = ur.id,
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = UserInfo.getProfileId(),
                        timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            insert userWithRole;
        }
        return userWithRole;
    }

    public static User createUserWithRole () {
        User runner = new User(alias = 'hasrole', email='runner@roletest1.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = UserInfo.getProfileId(),
                    timezonesidkey='America/Los_Angeles', username='runner@testorg.com');
        return createUserWithRole(runner);
    }

    public static void generatePortalObjectsForTests() {    
        User runner = PortalTestUtils.createUserWithRole();
        runner.Username = 'runner@on-portal.test';
        update runner;
        final List<Account> portalAccounts = new List<Account>();
        final List<Contact> portalContacts = new List<Contact>();
        final List<PBSI__PBSI_Sales_Order__C> portalOrders = new List<PBSI__PBSI_Sales_Order__C>();
        Map<Id, User> mPortalUser;
        Id soRecordType;
        System.runas(runner) {
			insert new Backstage_Profile_Setting__c(SetupOwnerId = UserInfo.getOrganizationId(), Available_order_types__c='re-order;pre-order;');
            PBSI__Account_Group__c aGroup = new PBSI__Account_Group__c(Name = 'Dealers', PBSI__Account_Group_Code__c='1111');
            insert aGroup;
            soRecordType = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get('Web Order').getRecordTypeId();
            portalAccounts.add(TestUtility.createAccount('Supersports', 'EUR', false));
            portalAccounts.add(TestUtility.createAccount('Hypersports', 'USD', false));

            for(Account a : portalAccounts) {
                a.PBSI__Account_Group__c = aGroup.Id;
                a.E_Shop_Dealer__c = 'Dealer and Point of Sale';
                a.ShippingCountry = 'Switzerland';
                a.Status__c = 'Active';
            }
            insert portalAccounts;

            for(Account a : portalAccounts) {
                portalContacts.add(TestUtility.createContact(a.Name + '1', a, false));
                portalContacts.add(TestUtility.createContact(a.Name + '2', a, false));
                portalOrders.add(TestUtility.createSalesOrder(a.Id, soRecordType, a.CurrencyIsoCode, false));
                portalOrders.add(TestUtility.createSalesOrder(a.Id, soRecordType, a.CurrencyIsoCode, false));
                portalOrders.add(TestUtility.createSalesOrder(a.Id, soRecordType, a.CurrencyIsoCode, false));
            }
            for(PBSI__PBSI_Sales_Order__C so : portalOrders) {
                so.PBSI__Due_date__C = Date.today();
                so.PBSI__Order_Date__c = Date.today();
                so.PBSI__Stage__c = 'Open';
                so.Sales_Order_Type__c='Re-Order';
            }
            for(Contact c : portalContacts) {
                c.FirstName = 'Adam';
                c.Email = 'example@example.com';
                c.Portal_users_language__c = 'en_US';
                c.Portal_user_locale__c = 'es_ES_EURO';
            }
            insert portalContacts;
            insert portalOrders;
            portalContacts[0].Function__c = 'B2B-Portal-User';
            update portalContacts[0];

            mPortalUser = new Map<Id, User>([
                SELECT Id
                FROM User
                WHERE ContactId IN :portalContacts
            ]);
            update portalContacts;
        }
    }
    
    private static User getRunner() {
        return [SELECT Id FROM User WHERE Username = 'runner@on-portal.test'];
    }

    public static void generateSOLines (PBSI__PBSI_Sales_Order__C order) {
        List<PBSI__PBSI_Item_Group__c> parentGroupsToInsert = new List<PBSI__PBSI_Item_Group__c>();
        parentGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Shoes group',   PBSI__Item_Group_Code__c=System.label.Item_group_shoes_code,    CurrencyIsoCode='USD', Group_Description__c= 'Sample description'));
        parentGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Apparel group', PBSI__Item_Group_Code__c=System.label.Item_group_apparel_code, CurrencyIsoCode='USD', Group_Description__c= 'Sample description'));
        insert parentGroupsToInsert;
        System.debug('Parent groups inserted ...');
        List<PBSI__PBSI_Item_Group__c> itemGroupsToInsert = new List<PBSI__PBSI_Item_Group__c>();
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Cloudrunner',         PBSI__Item_Group_Code__c='run',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[0].Id));
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Cloudsprinter',       PBSI__Item_Group_Code__c='spr',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[0].Id));
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Cloudmarathoners',    PBSI__Item_Group_Code__c='mar',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[0].Id));

        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Capillatus',  PBSI__Item_Group_Code__c='cap',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[1].Id));
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Floccus',     PBSI__Item_Group_Code__c='flo',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[1].Id));
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Humilis',     PBSI__Item_Group_Code__c='hum',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[1].Id));
        itemGroupsToInsert.add(new PBSI__PBSI_Item_Group__c(Name='Nebulosus',   PBSI__Item_Group_Code__c='neb',     CurrencyIsoCode='USD', Group_Description__c= 'Sample description',  PBSI__Parent_Group__c=parentGroupsToInsert[1].Id));

        insert itemGroupsToInsert;
        System.debug('Item groups inserted ...');

        List<Sizes__c> lShoeSizes =  new List<Sizes__c>();
        for(Decimal i = 8; i < 14; i+=0.5){
            lShoeSizes.add(new Sizes__c(Name='W ' + i,      European_Size__c='' + (34 + i),      MM__c='' + Integer.valueOf((270 + (i-8)*3)), UK_Size__c='' + i,      US_Men__c='0',      US_Women__c='' + i,   US_Size__c='W ' + i,    Type__c = '2'));
            lShoeSizes.add(new Sizes__c(Name='M ' + i+1,         European_Size__c='' + (36 + i),      MM__c='' + Integer.valueOf((280 + (i-8)*4)), UK_Size__c='' + i,      US_Men__c='' + 1,      US_Women__c='' + i,   US_Size__c='M ' + i+1,    Type__c = '1'));
        }

        lShoeSizes.add(new Sizes__c(Name='M 15',         European_Size__c='' + 50,     MM__c='350', UK_Size__c='16',      US_Men__c='15',      US_Women__c= '',   US_Size__c='M 15',    Type__c = ''));
        insert lShoeSizes;

        System.debug('Shoe sizes inserted...');
        
        List<Fabric__C> lFabricsToInsert = new List<Fabric__c>();
        for(Integer i = 0; i < 10; i++){
            lFabricsToInsert.add(new Fabric__c(Name = '0.' + i + '000'));
            lFabricsToInsert.add(new Fabric__c(Name = '0.' + i + '001'));
        }
        insert lFabricsToInsert;
        System.debug('Fabrics inserted...');
        

        List<PBSI__PBSI_Item__c> lItemsToInsert = new List<PBSI__PBSI_Item__c>();
       /* 
        
        DJA 16/05/16 removed because tests are failing with too many SOQL queries
        for(Integer i = 0; i < lShoeSizes.size(); i++){
            // to many lines caused CPU limit to be hit
            for(Integer j = 0; j < 3; j++){
                for(Integer k = 0; k < 17; k++){
                        lItemsToInsert.add(new PBSI__PBSI_Item__c(Name='Test item ' + i + ' ' + j + ' ' + k + ' k', Size__c=lShoeSizes[i].Id, PBSI__Item_Group__c=itemGroupsToInsert[j].id, Fabric_Code__c=lFabricsToInsert[k].id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
                }
            }
        }*/
        lItemsToInsert.add(new PBSI__PBSI_Item__c(Name='Test item ' + 0 + ' ' + 0 + ' ' + 0 + ' k', Size__c=lShoeSizes[0].Id, PBSI__Item_Group__c=itemGroupsToInsert[0].id, Fabric_Code__c=lFabricsToInsert[0].id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));

        insert lItemsToInsert;

        List<PBSI__PBSI_Sales_Order_Line__c> lines = new List<PBSI__PBSI_Sales_Order_Line__c>();
        for(Integer i = 0; i < 1; i++){
           //lines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = order.Id, PBSI__Item__c = lItemsToInsert[i+800].Id, PBSI__Quantity_Needed__c = 10, PBSI__Location__c =  order.PBSI__From_Location__c));
            lines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = order.Id, PBSI__Item__c = lItemsToInsert[0].Id, PBSI__Quantity_Needed__c = 10, PBSI__Location__c =  order.PBSI__From_Location__c));

        }
        System.debug(LoggingLevel.WARN, 'Lines to insert ' );
        insert lines;
        System.debug(LoggingLevel.WARN, 'Lines inserted ' );
    }
}