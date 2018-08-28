/**
* Test cases for CongaFileGeneratorBatch.cls, and therfore:
*	- CongaFileGenerator.cls
*	- CustomApexLogin.cls
*
* @author Ivan Durlen, 2016/05/09
*
* Copyright (c) Nefos gmbh, 2016
*/
@isTest
private class CongaFileGeneratorBatchTest {
	
	private static String currencyIsoCode = 'CHF';


	static List<PBSI__PBSI_Sales_Order__c> fetchSalesOrders(){
		List<PBSI__PBSI_Sales_Order__c> lSalesOrders =  [SELECT Id, Conga_Order_Confirmation_Link__c, (SELECT ID FROM Attachments) 
										FROM PBSI__PBSI_Sales_Order__c];
		return lSalesOrders;									
	}


	static PBSI__PBSI_Sales_Order__c fetchSalesOrder(Id soId){
		return [SELECT Id, Conga_Order_Confirmation_Link__c, (SELECT ID FROM Attachments) 
										FROM PBSI__PBSI_Sales_Order__c
										WHERE Id = :soId
										LIMIT 1][0];
	}


	@testSetup
	static void prepareData(){
		Account testAcc = TestUtility.createAccount('Test Account', currencyIsoCode, false);
	            testAcc.BillingCountry = 'Germany';
	            testAcc.BillingCity = 'Berlin';
	            testAcc.BillingPostalCode = '00-123';
	            testAcc.BillingStreet = 'Street 123';
	            insert testAcc;

	            Contact testContact = TestUtility.createContact('Test Contact', testAcc, false);
	            insert testContact;

	            Id soRecordTypeId = SalesOrderMethods.getRecordTypeID(SalesOrderMethods.WEB_ORDER_RECORD_TYPE_NAME);

	            List<PBSI__PBSI_Sales_Order__c> lSalesOrders = new List<PBSI__PBSI_Sales_Order__c>();
	            for(Integer i=0; i < 3; i++){
	            	lSalesOrders.add(TestUtility.createSalesOrder(testAcc, testContact, soRecordTypeId, currencyIsoCode, false));
	            }

	            insert lSalesOrders;
	}

	
	@isTest 
	static void testFileGenerationAttachmentNotNeeded() {
		String sessionId = UserInfo.getSessionId();
		Schema.sObjectType sObjType = Schema.getGlobalDescribe().get('PBSI__PBSI_Sales_Order__c');

		PBSI__PBSI_Sales_Order__c so = fetchSalesOrders().get(0);
		Id soId = so.Id;

		Attachment testAttachment = new Attachment(
	  		Body = Blob.valueOf('XYZabcdef'),
	  		Name = 'TestAttachment.txt',	
	  		ContentType = 'txt',
			ParentId = so.Id
		);
		insert testAttachment;

		so = fetchSalesOrder(soId);

	 	System.assertEquals(1, so.Attachments.size());
	 	System.assert(so.Conga_Order_Confirmation_Link__c.contains('NULL_SESSION_ID'));

		// ---------- Exec batch job ----------
		CongaFileGeneratorBatch batch = new CongaFileGeneratorBatch(new Set<Id>{ so.Id }, sObjType, sessionId);

		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();

		so = fetchSalesOrder(soId);
	 	System.assert(so.Conga_Order_Confirmation_Link__c.contains('NULL_SESSION_ID'));
	}



	@isTest
	static void testBatchMethods(){
		// ---------- Simple method tests ---------- 
		List<Contact> lContacts = [SELECT Id, Name FROM Contact LIMIT 1];

		CongaFileGeneratorBatch batch = new CongaFileGeneratorBatch();
		String query = batch.buildQuery(Schema.getGlobalDescribe().get('Account'));
		System.assertEquals(null, query);

		boolean isAttNeeded = batch.isAttachmentNeeded(lContacts.get(0));
		System.assertEquals(false, isAttNeeded);

		String strAttachment = batch.generateAttachment(lContacts.get(0));
		System.assertEquals(null, strAttachment);
	}


	@isTest
	static void testInvalidCases(){
		Set<Id> sOrderIds = new Set<Id>();
		for(PBSI__PBSI_Sales_Order__c salesOrd : fetchSalesOrders()){
			sOrderIds.add(salesOrd.Id);
		}

		String sessionId = UserInfo.getSessionId();

		CongaFileGeneratorBatch batch = new  CongaFileGeneratorBatch(sOrderIds, Schema.getGlobalDescribe().get('PBSI__PBSI_Sales_Order__c'), sessionId);

		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();

		for(PBSI__PBSI_Sales_Order__c salesOrd : fetchSalesOrders()){
			System.assertEquals(0, salesOrd.Attachments.size());
		}
	}
	
	
}