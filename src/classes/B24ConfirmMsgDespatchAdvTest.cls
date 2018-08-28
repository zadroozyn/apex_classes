@istest
public class B24ConfirmMsgDespatchAdvTest{
	
	@istest static void B24ConfirmDesadv(){
		TestDataFactory tdf = TestDataFactory.instance;
		Test.setMock(HttpCalloutMock.class, new B24MockCallout(''));
		ProcessRealization pInstance = new ProcessRealization(tdf.trackings.getAllSObjects()[0].Id, new MockProcess());
		Test.startTest();
			B24ConfirmMsgDespatchAdv advice = new B24ConfirmMsgDespatchAdv();
 			advice.executeStep(pInstance);
 			advice.getStepName();
 			B24MessageFactory.Order msgFactOrderWarp = advice.msgFactOrderWarp;
 			System.assertEquals('7340117820218', msgFactOrderWarp.getCustomerGLN());
 			System.assertEquals(2, msgFactOrderWarp.getPackages().size());
		Test.stopTest();
	}

	@testSetup static void setup() {
		TestDataFactory tdf = TestDataFactory.instance;

		B24_Integration_Model__c isg = new B24_Integration_Model__c(
			Name = 'Intersport Germany',
			Order_inbound__c = 'B24ISGOrderCreator',
			DESADV_automation__c = true
		);
		insert isg;
		new TestCustomSettingsFactory();
		tdf.accounts.createSObject('RRS', 'USD', false);
		tdf.accounts.getSObject('RRS').put('GLN__c', '7340117820218');
		tdf.accounts.getSObject('RRS').put('B24_Integration_Model__c', isg.Id);

		tdf.accounts.insertAll();



		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.createSObject('US-Stock', false);
		tdf.locations.createSObject('transit', false);
		tdf.locations.getSObject('transit').put('PBSI__In_Transit__c',true);
		tdf.locations.insertAll();

		tdf.itemGroups.createSObject('Cloud group', '677', 'EUR', 'No desc', null, true);

		SObject item1 = tdf.items.createSObject('4.4102 W 6.5', 100, 120, 'test desc', tdf.locations.getSObject('EU-Stock').Id, 
			tdf.itemGroups.getAllSobjects()[0].Id, '7640165317761', false);

		tdf.items.insertAll();

		SObject so = tdf.salesOrders.createSObject(tdf.accounts.getSObject('RRS').Id, 'Drop Ship', tdf.locations.getSObject('US-Stock').Id, true);
		SObject to = tdf.transferOrders.createSObject(tdf.locations.getSObject('US-Stock').Id, tdf.locations.getSObject('EU-Stock').Id, tdf.locations.getSObject('transit').Id, true);
	
		Order_stage__c os = tdf.orderStages.createSObject('Processing', so.Id, true);

		Tracking__c tracking = tdf.trackings.createSObject(os.id, so.id, true );
		Tracking_Number__c trackingNumber = tdf.trackingNumbers.createSObject(tracking.id, true);
		Tracking_Number_Item__c trackingNumberItem = tdf.trackingNumberItems.createSObject(trackingNumber.id, item1.id, true);

		Tracking_Number__c trackingNumber2 = tdf.trackingNumbers.createSObject(tracking.id, true);
		Tracking_Number_Item__c trackingNumberItem2 = tdf.trackingNumberItems.createSObject(trackingNumber2.id, item1.id, true);
	}

	public class MockProcess implements IProcessDefinition {
		private List<String> steps = new List<String>{};

		public Queue getStepsQueue() {
			return new Queue(steps);
		}
		
		public String getProcessName() {
			return 'MockProcess';
		}
	}
}