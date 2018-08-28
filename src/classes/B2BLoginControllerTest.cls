@isTest
private class B2BLoginControllerTest {

	@testSetup static void setupMethod() {
		UserRole adminRole = [SELECT Id, Name FROM UserRole WHERE Name='On Admin'];
		User adminUser = TestUtil.createAdminUser('Adm@on-running.test');
		adminUser.UserRoleId = adminRole.Id;
		update adminUser;
		System.runAs(adminUSer){
		Id customerPortalProfileID = [SELECT Id From Profile WHERE Name='Backstage Dealer'][0].Id;
		Account testAccount = new Account(OwnerId=adminUser.Id, Name='Customer Portal Login Test Account');
		insert testAccount;
		Contact testContact = new Contact(LastName='Test contact', AccountId=testAccount.Id);
		insert testContact;
		User testCustomerPortalUser = new User(Username='test.user@on-running.test', Email='test.user@example.com', FirstName='John', 
			LastName='Smith', CommunityNickname='JSmith', ContactId=testContact.Id, Alias='JSmith', ProfileId=customerPortalProfileID, EmailEncodingKey='UTF-8',
			LanguageLocaleKey='en_US', LocaleSidKey='de_CH', TimeZoneSidKey='GMT');
		insert testCustomerPortalUser;
		System.setPassword(testCustomerPortalUser.Id, 'Test1234');
	}	
}
	
	@isTest static void b2bLoginTest() {
		Test.setCurrentPage(Page.SiteLogin);
		ApexPages.currentPage().getHeaders().put('Accept-Language', 'en_US,GMT');
        System.currentPageReference().getParameters().put('startURL', '/apex/test');
		B2BLoginController controller = new B2BLoginController();

		Test.startTest();
		controller.username='test.user@on-running.test';
		controller.password='test';
		PageReference failedLogin = controller.login();
		System.debug( ApexPages.getMessages());
		controller.password='Test1234';
		PageReference successLogin = controller.login();
		System.debug( ApexPages.getMessages());

		Test.stopTest();
		System.assertEquals(null, failedLogin);
		System.assertEquals(null, successLogin);
		System.assertEquals('en_US', controller.lang);
	}

	@isTest static void b2bforgotPasswordTest() {
		Test.setCurrentPage(Page.ForgotPassword);
		ApexPages.currentPage().getHeaders().put('Accept-Language', 'en_US;GMT');
        System.currentPageReference().getParameters().put('startURL', '/apex/test');
		B2BLoginController controller = new B2BLoginController();
		controller.username = 'test.user@on-running.test';
		PageReference pr;
		Test.startTest();
		pr = controller.forgotPassword();
		Test.stopTest();
		System.assertEquals(null, pr);
	}

	@isTest static void b2bchangePasswordTest() {
		Test.setCurrentPage(Page.ChangePassword);
		ApexPages.currentPage().getHeaders().put('Accept-Language', 'en_US;GMT');
        System.currentPageReference().getParameters().put('startURL', '/apex/test');
		B2BLoginController controller = new B2BLoginController();
		controller.newPassword = 'Test4321';
		controller.confirmNewPassword = 'Test4321';
		PageReference pr;
		Test.startTest();
		pr = controller.changePassword();
		Test.stopTest();
		System.assertEquals(null, pr);
	}
}