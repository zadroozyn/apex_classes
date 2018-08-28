@isTest
private class CommunityUserFactoryTest {

    private class TestData {
        public PBSI__Account_Group__c dealerGroup {get; set;}
        public Account account {get; set;}
        public Contact[] contacts {get; set;}
		public User testRunner {get; set;}

        public TestData() {
			testRunner = PortalTestUtils.createUserWithRole();
            System.runAs(testRunner){
                dealerGroup = TestUtility.createAccountGroup('Dealers', 'DLR', true);

                account = TestUtility.createAccount('Test Account', 'USD', false);
                account.PBSI__Account_Group__c = dealerGroup.Id;
                account.E_Shop_Dealer__c =  'Dealer and Point of Sale';
                account.Status__c = 'Active';
                account.ShippingCountry = 'USA';
                insert account;

                contacts = TestUtility.createContacts('Test Contact', account, false, 20);
				for(Contact c : contacts) {
					c.email = 'example@example.com';
				}
            }
        }
    }

    @isTest
    static void testCreateUserOnContactCreation() {
        TestData testData = new TestData();


        for (Integer i = 0; i < 10; i++) {
            testData.contacts[i].Function__c = 'B2B-Portal-User';
        }

        Test.startTest();
		System.runAs(testData.testRunner){
			insert testData.contacts;
		}
        Test.stopTest();

        User[] users = [Select Id, isActive From User Where ContactId In :testData.contacts];
        System.debug(users);

        System.assertEquals(10, users.size());
        for (User usr : users) {
            System.assertEquals(true, usr.isActive);
        }
    }

    @isTest
    static void testUpsertUserOnContactUpdate() {
        TestData testData = new TestData();

		System.runAs(testData.testRunner){
			insert testData.contacts;

			for (Integer i = 0; i < 10; i++) {
				testData.contacts[i].Function__c = 'B2B-Portal-User';
			}
			Test.startTest();
			update testData.Contacts;

			for (Integer i = 0; i < 5; i++) {
				testData.contacts[i].Function__c = '';
			}

			update testData.contacts;
			Test.stopTest();
		}
        User[] users = [Select Id, isActive, Contact.Function__c From User Where ContactId In :testData.contacts];
        System.assertEquals(10, users.size());

        for (User usr : users) {
            if (Utility.contains(usr.Contact.Function__c, 'B2B-Portal-User')) {
                System.assertEquals(true, usr.isActive);
            }
            else {
                System.assertEquals(false, usr.isActive);

            }
        }

    }
}