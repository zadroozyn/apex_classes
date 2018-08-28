@isTest
private class B24AdminControllerTest {
	
	@isTest static void fetchMessageJob() {
		B24AdminController controller = new B24AdminController();
		controller.turnOnMessageFetch();
		System.assertNotEquals(null, controller.b24FetchJobId);
		controller.turnOffMessageFetch();
		System.assertEquals(null, controller.b24FetchJobId);
		controller.getMessageFetchClassName();
		controller.getInvrptOutClassName();
		controller.showAddNewDesadvTO();
		controller.showAddNewInvrptDaily();
		controller.hideAddNewInvrptDaily();

		controller.to.PBSI__From_Location__c = 'a0X4E00000040OY';
		controller.to.PBSI__To_Location__c = 'a0X4E00000040OT';
		controller.so.PBSI__Customer__c = '0014E00000hOXxw';
		controller.addNewDesadvTO();

		controller.invrpt_out_daily_acc.AccountId = '0014E00000hOXxw';
		controller.invrpt_out_daily_rpt = '00O570000077nly';
		controller.addNewInvrptDaily();

		controller.removeLineId = '';
		controller.removeInvrptOut();

		controller.sendNowSingleInvrpt();
		controller.sendNowAllInvrpt();
		controller.turnOffInvrptOut();
		controller.turnOnInvrptOut();
		controller.saveAllChanges();
		controller.cancelAllChanges();
	}

	
}