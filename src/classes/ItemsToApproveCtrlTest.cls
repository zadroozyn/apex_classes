@isTest
private class ItemsToApproveCtrlTest {
	
	@isTest static void test_method_one() {
		ItemsToApproveCtrl controller = new ItemsToApproveCtrl();
		ApprovalGroup ag = getGroup();
		controller.aGroup = ag;
		System.assertEquals(true, ag.approvalRecords.equals(controller.visibleRecords));

		controller.getBaseUrl();
		controller.getApproveRejectUrl();
		controller.getReassignUrlSuffix();
		controller.getRetUrlHome();
		controller.getNextPage();
		controller.getPrevPage();
		System.assertEquals(false,controller.getCanGoNext());
		System.assertEquals(false,controller.getCanGoPrev());
	}

	static ApprovalGroup getGroup() {
		ApprovalGroup ag = new ApprovalGroup('MockApproval','MockApproval','Case');
		return ag;
	}
	
}