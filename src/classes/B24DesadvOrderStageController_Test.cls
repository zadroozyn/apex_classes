@isTest
private class B24DesadvOrderStageController_Test {
	
	@isTest static void salesOrder() {
		TestDataFactory tdf = TestDataFactory.instance;
		Order_Stage__c stage = new Order_Stage__c(
			Sales_Order__c = tdf.salesOrders.getAllSObjects()[0].Id,
			RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_SO')
		);
		insert stage;
		Test.setCurrentPage(new PageReference('/apex/B24Desadv?id='+tdf.salesOrders.getAllSobjects()[0].Id));
		B24DesadvOrderStageController controller = new B24DesadvOrderStageController();
		controller.getAllOrderStages();
		System.assertEquals(1, Integer.valueOf(controller.getOrdersSize()));
	}

	@isTest static void transferOrder() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		TestDataFactory tdf = TestDataFactory.instance;
		Order_Stage__c stage = new Order_Stage__c(
			Transfer_Order__c = tdf.transferOrders.getAllSObjects()[0].Id,
			RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Order_Stage__c', 'Notification_TO')
		);
		insert stage;
		Test.setCurrentPage(new PageReference('/apex/B24Desadv?id='+tdf.transferOrders.getAllSobjects()[0].Id));
		B24DesadvOrderStageController controller = new B24DesadvOrderStageController();
		controller.getAllOrderStages();
		System.assertEquals(1, Integer.valueOf(controller.getOrdersSize()));
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
		
		SObject so = tdf.salesOrders.createSObject(tdf.accounts.getSObject('RRS').Id, 'Drop Ship', tdf.locations.getSObject('US-Stock').Id, true);
		SObject to = tdf.transferOrders.createSObject(tdf.locations.getSObject('US-Stock').Id, tdf.locations.getSObject('EU-Stock').Id, tdf.locations.getSObject('transit').Id, true);
	}
	
}