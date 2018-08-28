@isTest
private class ItemsToApproveFieldsTest {
	
	@isTest static void testPositive() {
		ItemsToApproveFields approvalFields = new ItemsToApproveFields();
		System.assertEquals(2,approvalFields.getAllProcessesNames().size());
		System.assertEquals(true,approvalFields.getAllProcessesNames().contains('CaseApprovalMock'));
		System.assertEquals(true,approvalFields.getAllProcessesNames().contains('AccountApprovalMock'));

		Integer matchFound = 0;
		System.assertEquals(3,approvalFields.getFieldsPaths('CaseApprovalMock').size());
		for(String fPath: approvalFields.getFieldsPaths('CaseApprovalMock')) {
			if(fPath == 'Account.Name' || fPath == 'Contact.Name' || fPath == 'CaseNumber') {
				matchFound++;
			}
		}
		System.assertEquals(3,matchFound);

		matchFound = 0;
		System.assertEquals(1,approvalFields.getFieldsPaths('AccountApprovalMock').size());
		for(String fPath: approvalFields.getFieldsPaths('AccountApprovalMock')) {
			if(fPath == 'Name') {
				matchFound++;
			}
		}
		System.assertEquals(1,matchFound);
	}

	@isTest static void testProcessNotExist() {
		ItemsToApproveFields approvalFields = new ItemsToApproveFields();
		Boolean hasError = false;
		try {
			approvalFields.getFieldsPaths('FakeProcess');
		} catch (ItemsToApproveFields.ProcessNotDefinedException e) {
			hasError = true;
		}
		System.assertEquals(true,hasError);
	}
	
	@testSetup
	private static void setup() {
		insert new List<Items_to_Approve_Fields__c>{
			new Items_to_Approve_Fields__c(
				Name = 'CaseApprovalMock.AccountName',
				Process_name__c = 'CaseApprovalMock',
				Field_API_Name__c = 'Account.Name'
			),
			new Items_to_Approve_Fields__c(
				Name = 'CaseApprovalMock.ContactName',
				Process_name__c = 'CaseApprovalMock',
				Field_API_Name__c = 'Contact.Name'
			),
			new Items_to_Approve_Fields__c(
				Name = 'CaseApprovalMock.CaseNumber',
				Process_name__c = 'CaseApprovalMock',
				Field_API_Name__c = 'CaseNumber'
			),
			new Items_to_Approve_Fields__c(
				Name = 'AccountApprovalMock.AccountName',
				Process_name__c = 'AccountApprovalMock',
				Field_API_Name__c = 'Name'
			)
		};
	}
	
}