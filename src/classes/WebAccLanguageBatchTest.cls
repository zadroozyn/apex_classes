@isTest
private class WebAccLanguageBatchTest {
	
	@isTest static void test_method_one() {
		insert new Account(
			RecordTypeId = '01257000000Bflh',
			LastName = 'noname'
		);
		Database.executeBatch(new WebAccLanguageBatch(), 100);
	}
	
}