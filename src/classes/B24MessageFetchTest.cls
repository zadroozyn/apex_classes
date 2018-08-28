@isTest
private class B24MessageFetchTest {
	
	@isTest static void salesReport() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout('SLSRPT'));
		B24MessageFetch msgFetchObj = new B24MessageFetch();
		Test.startTest();
		msgFetchObj.execute(null);
		Test.stopTest();
		System.assertEquals(1, msgFetchObj.mapClassName2MessageWrappers.keySet().size());
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(msgFetchObj.mapClassName2MessageWrappers.get('slsrpt')[0].msgJson, B24MessageWrapper.class);
		B24MessageRouter msgRouter = new B24MessageRouter(msgWrap.b24Message[0], msgFetchObj.authObj);
		System.assert(msgRouter.messages[0].isSalesReport());
		System.assert(msgRouter.authObj.isValid());
	}

	@isTest static void inventoryReport() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout('INVRPT'));
		B24MessageFetch msgFetchObj = new B24MessageFetch();
		Test.startTest();
		msgFetchObj.execute(null);
		Test.stopTest();
		System.assertEquals(1, msgFetchObj.mapClassName2MessageWrappers.keySet().size());
		B24MessageWrapper msgWrap = (B24MessageWrapper) JSON.deserialize(msgFetchObj.mapClassName2MessageWrappers.get('invrpt')[0].msgJson, B24MessageWrapper.class);
		B24MessageRouter msgRouter = new B24MessageRouter(msgWrap.b24Message[0], msgFetchObj.authObj);
		System.assert(msgRouter.messages[0].isInventoryReport());
		System.assert(msgRouter.authObj.isValid());
	}

	@isTest static void listMessages() {
		Test.setMock(HttpCalloutMock.class, new B24MockCallout('list'));
		B24MessageFetch msgFetchObj = new B24MessageFetch();
		Test.startTest();
		List<Object> lMessages = msgFetchObj.fetchListAwatingMessages();
		msgFetchObj.getClassName();
		Test.stopTest();
	}
	
	@testSetup static void setup() {
		new TestCustomSettingsFactory();
	}
	
}