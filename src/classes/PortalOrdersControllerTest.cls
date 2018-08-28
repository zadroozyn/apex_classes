@isTest class PortalOrdersControllerTest {

	@testSetup static void dataGenerator () {
		PortalTestUtils.generatePortalObjectsForTests();
	}

	@isTest static void test1() {
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		Contact c = [SELECT Id FROM Contact WHERE Lastname = 'Supersports1'];
		User portalRunner = [SELECT Id FROM User WHERE ContactId = :c.Id];
		Account account = [SELECT name, PBSI__Standard_Discount__c, BillingCountry from Account where name = 'Supersports'];
		List<SalesOrderWrapper> ordersFilterOn;
		List<SalesOrderWrapper> ordersFilterOff;
		List<SalesOrderWrapper> ordersFilterOn2;
		final List<SalesOrderWrapper> customerOrders;
		system.assertequals(6, [select id from pbsi__pbsi_sales_order__c].size());
		System.runAs(portalRunner) {
			Test.setCurrentPage(Page.PortalOrders);
			PortalOrdersController ctrl = new PortalOrdersController();
			PortalOrderDetailController ctrlDetail = new PortalOrderDetailController();
			ctrl.setComponentController(ctrlDetail );
			ctrlDetail.setPageController(ctrl);

			customerOrders = ctrl.getWrappedOrders();
			ordersFilterOff = ctrl.getFilteredOrders();
			System.assertEquals('1/01/' + Date.today().year(), ctrl.filterOrderFrom.textField);
			System.assertEquals('31/12/' + Date.today().year(), ctrl.filterOrderTo.textField);
			System.assertEquals('1/01/' + Date.today().year(), ctrl.filterShipFrom.textField);
			System.assertEquals('31/12/' + Date.today().year(), ctrl.filterShipTo.textField);
			ctrl.resetFilters();
			ordersFilterOn = ctrl.getFilteredOrders();
			ctrl.filterOrderFrom.textField = '1/2/2014';
			ctrl.filterOrderTo.textField = '28/2/2014';
			ctrl.filterShipFrom.textField = '3/03/2012';
			ctrl.filterShipTo.textField = '31/10/2012';
			System.assertEquals('1/02/2014', ctrl.filterOrderFrom.textField);
			System.assertEquals('28/02/2014', ctrl.filterOrderTo.textField);
			System.assertEquals('3/03/2012', ctrl.filterShipFrom.textField);
			System.assertEquals('31/10/2012', ctrl.filterShipTo.textField);
			ordersFilterOn2 = ctrl.getFilteredOrders();

			AccountWrapper accWraper = new AccountWrapper(account);
			system.assertEquals(0.0, accWraper.standardDiscount);

		}
		system.assertequals(3, customerorders.size());
		system.assertequals(3, ordersfilteron.size());
		system.assertequals(3, ordersfilteroff.size());
		system.assertequals(0, ordersfilteron2.size());
	}

}