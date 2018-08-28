@isTest class sObjectMethodsTest {
	@isTest static void filterSObjectsByField () {
		List<Account> testAccounts = new List<Account>();
		testAccounts.add(new Account(Name = 'Test acc1', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Business_Customer'), Description = 'A test account', NumberOfEmployees = 10));
		testAccounts.add(new Account(Name = 'Test acc2', RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Supplier'), Description = 'A test account', NumberOfEmployees = 20));
		final List<Account> filteredByString = sObjectMethods.filterSObjectsByField(testAccounts, 'Name', 'Test acc1');
		final List<Account> filteredById = sObjectMethods.filterSObjectsByField(testAccounts, 'RecordTypeId', RecordTypeService.getRecordTypeIdByDeveloperName('Account', 'Business_Customer'));
		final List<Account> filteredByLongTest = sObjectMethods.filterSObjectsByField(testAccounts, 'Description', 'A test account');
		final List<Account> filteredByNumber = sObjectMethods.filterSObjectsByField(testAccounts, 'NumberOfEmployees', 10);
		System.assertEquals(1, filteredByString.size(), '');
		System.assertEquals(1, filteredById.size(), '');
		System.assertEquals(2, filteredByLongTest.size(), '');
		System.assertEquals(1, filteredByNumber.size(), '');
	}
}