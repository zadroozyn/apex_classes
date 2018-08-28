@isTest
private class MyItemsToApproveCtrlTest {
	
	@isTest static void additionalTabs() {
		loadCS();
		MyItemsToApproveCtrl controller = new MyItemsToApproveCtrl();
		controller.setSelectedGroupId('MockApprovalProcess');
		System.assertEquals('MockApprovalProcess',controller.getSelectedGroupId());
		System.assertEquals(3,controller.lGroups.size());
		controller.setSelectedGroupId(MyItemsToApproveCtrl.TAB_ALL);
		controller.setSelectedGroupId(MyItemsToApproveCtrl.TAB_OTHER);

		controller.dummy();
	}

	@isTest static void oneTab() {
		MyItemsToApproveCtrl controller = new MyItemsToApproveCtrl();
		System.assertEquals(MyItemsToApproveCtrl.TAB_ALL,controller.getSelectedGroupId());
		System.assertEquals(1,controller.lGroups.size());

		controller.dummy();
	}	

	private static void loadCS() {
		insert new List<Items_to_Approve_Fields__c>{
			new Items_to_Approve_Fields__c(
				Name = 'MockApprovalProcess.AccountName',
				Process_name__c = 'MockApprovalProcess',
				Field_API_Name__c = 'Account.Name'
			),
			new Items_to_Approve_Fields__c(
				Name = 'MockApprovalProcess.ContactName',
				Process_name__c = 'MockApprovalProcess',
				Field_API_Name__c = 'Contact.Name'
			),
			new Items_to_Approve_Fields__c(
				Name = 'MockApprovalProcess.CaseNumber',
				Process_name__c = 'MockApprovalProcess',
				Field_API_Name__c = 'CaseNumber'
			)		
		};
	}
	
}