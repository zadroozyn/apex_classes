@isTest
private class OscaMessageSendTest {
	@isTest static void accounts() {
		Test.setMock(HttpCalloutMock.class, new OSCA_MockCallout());
		List<Account> accs = Database.query('SELECT Id,'+String.join(OSCA_OutboundFields.ACCOUNT_SOQL,',')+' FROM Account');
		OscaMessageSend msgSend = new OscaMessageSend();
		Test.startTest();
		msgSend.sendMessage('account', JSON.serialize(accs));
		Test.stopTest();
	}

	@testSetup static void setup() {
		new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;

		tdf.accounts.createSObject('Account 1', 'CHF', false);
		tdf.accounts.createSObject('Account 2', 'USD', false);
		tdf.accounts.createSObject('Account 3', 'EUR', false);

		tdf.accounts.insertAll();
	}
}