@isTest class PortalOrderDetailControllerTest {

	@testSetup
	public static void dataGenerator () {
		PortalTestUtils.generatePortalObjectsForTests();
	}

	@isTest static void testCreationOfReOrder() {
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		Contact c = [SELECT Id FROM Contact WHERE Lastname = 'Supersports1'];
		User portalRunner = [SELECT Id FROM User WHERE ContactId = :c.Id];
		Account account = [SELECT name, PBSI__Standard_Discount__c, BillingCountry from Account where name = 'Supersports'];
		PageReference omReference;
		Id newOrderId;
		System.runAs(portalRunner) {
			Test.setCurrentPage(Page.PortalOrders);
			PortalOrdersController pageCtrl = new PortalOrdersController();
			PortalOrderDetailController componentCtrl = new PortalOrderDetailController();
			pageCtrl.setComponentController(componentCtrl);
			componentCtrl.setPageController(pageCtrl);
			pageCtrl.initialiseOrderDetail();
			componentCtrl.newDate.dateField = Date.today().addDays(1);

			omReference = componentCtrl.createNewOrder();
			newOrderId = componentCtrl.orderIdForOM;
		}

		System.assertNotEquals(null, omReference, 'Order matrix reference shouldn\'t be null');
		System.assertNotEquals(null, newOrderId, 'New order id shouldn\'t be null');
		System.assert(omReference.getURL().contains('/apex/ordercomposer?id=' + newOrderId), 'Wrong order matrix reference URL. Expected: \'' + '[SF URL]/apex/ordercomposer&?orderId=' + newOrderId+ '\'. Actual: \'' + omReference.getURL() + '\'/');
	}

	@isTest static void testCreationOfPreOrderAndLoadingOpenOrder() {
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		Contact c = [SELECT Id FROM Contact WHERE Lastname = 'Supersports1'];
		User portalRunner = [SELECT Id FROM User WHERE ContactId = :c.Id];
		Account account = [SELECT name, PBSI__Standard_Discount__c, BillingCountry from Account where name = 'Supersports'];
		PageReference omReference;
		Id newOrderId;
		Boolean isOrderEditable;
		String orderStatusAfterSave;
		System.runAs(portalRunner) {
			Test.setCurrentPage(Page.PortalOrders);
			PortalOrdersController pageCtrl = new PortalOrdersController();
			PortalOrderDetailController componentCtrl = new PortalOrderDetailController();
			pageCtrl.setComponentController(componentCtrl);
			componentCtrl.setPageController(pageCtrl);
			pageCtrl.initialiseOrderDetail();
			componentCtrl.newOrderType = 'Pre-Order';
			componentCtrl.newDate.dateField = Date.today().addDays((Integer)B2B_Portal_New_Order_Date_Intervals__c.getInstance('Pre-Order').Min_days_in_the_future__c+1);

			omReference = componentCtrl.createNewOrder();
			newOrderId = componentCtrl.orderIdForOM;
			System.currentPageReference().getParameters().put('orderId', newOrderId);

			pageCtrl = new PortalOrdersController();
			componentCtrl = new PortalOrderDetailController();
			pageCtrl.setComponentController(componentCtrl);
			componentCtrl.setPageController(pageCtrl);
			pageCtrl.initialiseOrderDetail();
			isOrderEditable = componentCtrl.getIsOrderEditable();
			componentCtrl.orderDate.dateField = Date.today().addDays((Integer)B2B_Portal_New_Order_Date_Intervals__c.getInstance('Pre-Order').Min_days_in_the_future__c+1);
			componentCtrl.submitOrder();
			orderStatusAfterSave =  componentCtrl.currentOrder.PBSI__Status__c;
		}

		System.assertNotEquals(null, omReference, 'Order matrix reference shouldn\'t be null');
		System.assertNotEquals(null, newOrderId, 'New order id shouldn\'t be null');
		System.assert(omReference.getURL().contains('/apex/ordercomposer?id=' + newOrderId), 'Wrong order matrix reference URL. Expected: \'' + '[SF URL]/apex/ordercomposer&?orderId=' + newOrderId+ '\'. Actual: \'' + omReference.getURL() + '\'/');
		System.assert(isOrderEditable, 'Order should be editable at this stage.');
		System.assertEquals('in progress', orderStatusAfterSave, 'After submission, order status should be \'in progress\'');
	}

	@isTest static void testWrongDateReOrder() {
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		Contact c = [SELECT Id FROM Contact WHERE Lastname = 'Supersports1'];
		User portalRunner = [SELECT Id FROM User WHERE ContactId = :c.Id];
		Account account = [SELECT name, PBSI__Standard_Discount__c, BillingCountry from Account where name = 'Supersports'];
		String errorMsg;
		PageReference omReference;
		System.runAs(portalRunner) {
			Test.setCurrentPage(Page.PortalOrders);
			PortalOrdersController pageCtrl = new PortalOrdersController();
			PortalOrderDetailController componentCtrl = new PortalOrderDetailController();
			pageCtrl.setComponentController(componentCtrl);
			componentCtrl.setPageController(pageCtrl);
			pageCtrl.initialiseOrderDetail();
			componentCtrl.newDate.dateField = Date.today().addDays(-1);
			omReference = componentCtrl.createNewOrder();
			errorMsg = componentCtrl.newOrderMsg;
		}
		System.assertEquals(null, omReference, 'This should be null, as new re-order shouldn\'t be created in past.');
		System.assertEquals(Label.B2B_Re_Order_Date_Error, errorMsg, 'Error msg should be one for re-order.');
	}

	@isTest static void testWrongDatePreOrder() {
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		Contact c = [SELECT Id FROM Contact WHERE Lastname = 'Supersports1'];
		User portalRunner = [SELECT Id FROM User WHERE ContactId = :c.Id];
		Account account = [SELECT name, PBSI__Standard_Discount__c, BillingCountry from Account where name = 'Supersports'];
		String errorMsg;
		PageReference omReference;
		System.runAs(portalRunner) {
			Test.setCurrentPage(Page.PortalOrders);
			PortalOrdersController pageCtrl = new PortalOrdersController();
			PortalOrderDetailController componentCtrl = new PortalOrderDetailController();
			pageCtrl.setComponentController(componentCtrl);
			componentCtrl.setPageController(pageCtrl);
			pageCtrl.initialiseOrderDetail();
			componentCtrl.newOrderType = 'Pre-Order';
			componentCtrl.newDate.dateField = Date.today().addDays(-1);
			omReference = componentCtrl.createNewOrder();
			errorMsg = componentCtrl.newOrderMsg;
		}
		System.assertEquals(null, omReference, 'This should be null, as new re-order shouldn\'t be created in past.');
		System.assertEquals(Label.B2B_Pre_Order_Date_Error, errorMsg, 'Error msg should be one for pre-order.');
	}
}