@isTest
private class B24DesadvController_Test {
	
	@isTest static void salesOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		Test.setCurrentPage(new PageReference('/apex/B24Desadv?id='+tdf.salesOrders.getAllSobjects()[0].Id));
		B24DesadvController controller = new B24DesadvController();
		controller.selectAllLines();
		controller.unselectAllLines();
		controller.retLink();
		controller.sendDesadv();
		List<SelectOption> options = controller.getCarrierCodes();
		controller.selectedCarrier = '';
		System.assertEquals(false, B24DesadvController.hasOrderStages(tdf.salesOrders.getAllSobjects()[0].Id));

		PBSI__Shipped_Sales_Order_Line__c soLine = new PBSI__Shipped_Sales_Order_Line__c(
            PBSI__Item__r = (PBSI__PBSI_Item__c) tdf.items.getSObject('4.4102 W 6.5'),
            PBSI__Quantity_Shipped__c = 10
		);

		B24DesadvController.LineWrapper lw = new B24DesadvController.LineWrapper(soLine);

	}

	@isTest static void transferOrder() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		TestDataFactory tdf = TestDataFactory.instance;
		Test.setCurrentPage(new PageReference('/apex/B24Desadv?id='+tdf.transferOrders.getAllSobjects()[0].Id));
		B24DesadvController controller = new B24DesadvController();
		controller.packageNumber = 'xxxxxxx';
		controller.deliveryParty.GLN__c = '352345245234';
		PBSI__Shipped_Tranfer_Line__c toLine = new PBSI__Shipped_Tranfer_Line__c(
            PBSI__Item__r = (PBSI__PBSI_Item__c) tdf.items.getSObject('4.4102 W 6.5'),
            PBSI__Quantity__c = 10
		);
		System.assertEquals(false, B24DesadvController.hasOrderStages(tdf.transferOrders.getAllSobjects()[0].Id));
		B24DesadvController.LineWrapper lw = new B24DesadvController.LineWrapper(toLine);
		lw.toSend = true;
		controller.lines.add(lw);
		controller.sendDesadv();
	}
	
	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('RRS', 'USD', false);
		tdf.accounts.getSObject('RRS').put('GLN__c', '7340117820218');

		tdf.accounts.insertAll();

		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('US-Stock', false);
		tdf.locations.createSObject('transit', false);
		tdf.locations.getSObject('transit').put('PBSI__In_Transit__c',true);
		tdf.locations.insertAll();

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		SObject item1 = tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165317761', false);
		SObject item2 = tdf.items.createSObject('4.4102 W 7', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7630040505581', false);
		tdf.items.createSObject('4.4103 W 8', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319192', false);

		SObject item3 = tdf.items.createSObject('4.4102 W 8.5', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319338', false);
		SObject item4 = tdf.items.createSObject('4.4103 W 9', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165319345', false);

		tdf.items.insertAll();

		SObject so = tdf.salesOrders.createSObject(tdf.accounts.getSObject('RRS').Id, 'Drop Ship', tdf.locations.getSObject('US-Stock').Id, true);
		SObject to = tdf.transferOrders.createSObject(tdf.locations.getSObject('US-Stock').Id, tdf.locations.getSObject('EU-Stock').Id, tdf.locations.getSObject('transit').Id, true);
	}
}