/**
 * Test calss for the SalesOrderSelector class. 
 * @author  Dive Jakobusic
 */
@isTest
private class SalesOrderSelectorTest {
	
	private static Map<String,Id> recordTypeIdByDevNameMap = new Map<String, Id>();

	private static final String WEB_ORDER_RECORD_TYPE_DEV_NAME = 'Web Order';

	private static final String BILL_OF_DELIVERY_PDF_ID = 'billOfDId';

	private static final String RETURN_INFO_PDF_ID = 'retInfoId';
	
	/**
	* Prepares data for the test create custom settings and account>
	* @author Dive Jakobusic
	*/
	@testSetup
	static void prepareData(){
		ONRLogisticsGateway.setValuesFromCustomSettings();
		Account a = TestUtility.createAccount('Supersports', 'EUR', false);
		a.E_Shop_Dealer__c = 'Dealer and Point of Sale';
		a.ShippingCountry = 'Switzerland';
		a.Status__c = 'Active';
		a.Customer_Language__c = 'German';
		a.BillingCountry = 'Switzerland';
		insert a;
	}

	@isTest static void testUpdateCargoCarePdfIds() {
		
		PBSI__PBSI_Sales_Order__C salesOrder = TestUtility.createSalesOrder( getAccountId(), getRecordTypeId(WEB_ORDER_RECORD_TYPE_DEV_NAME), 'CHF', true);
		
		SalesOrderSelector.updateCargoCarePdfIds(salesOrder.Id, BILL_OF_DELIVERY_PDF_ID, RETURN_INFO_PDF_ID);
		PBSI__PBSI_Sales_Order__c salesOrderAfterUpdate = [SELECT Return_Information_PDF_Id__c, Bill_of_Delivery_PDF_Id__c FROM PBSI__PBSI_Sales_Order__c
			WHERE Id =:salesOrder.Id];
		System.assertEquals(BILL_OF_DELIVERY_PDF_ID, salesOrderAfterUpdate.Bill_of_Delivery_PDF_Id__c);
		System.assertEquals(RETURN_INFO_PDF_ID, salesOrderAfterUpdate.Return_Information_PDF_Id__c);
	}
	
	@isTest 
	static void testGetCargoCareUrls() {
		PBSI__PBSI_Sales_Order__C salesOrder = TestUtility.createSalesOrder( getAccountId(), getRecordTypeId(WEB_ORDER_RECORD_TYPE_DEV_NAME), 'CHF', true);
		PBSI__PBSI_Sales_Order__c salesOrderAfterInsert = SalesOrderSelector.getCongaURLsForCargoCareDocs(salesOrder.Id);
		System.assertEquals(null, salesOrderAfterInsert.URL_Return_Information__c);
		System.assertEquals(null, salesOrderAfterInsert.URL_Bill_of_Delivery__c);
	}


	/**
	* Method gets record type id for record type developer name.
	*/
	static Id getRecordTypeId(String recordTypeDevName){

		Id recTypeId = recordTypeIdByDevNameMap.get(recordTypeDevName);
		if (recTypeId == null){
			recTypeId = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get(recordTypeDevName).getRecordTypeId();
			recordTypeIdByDevNameMap.put(recordTypeDevName, recTypeId);
		}
		return recTypeId;
	}
	
	/**
	* Method gets Id of account.
	*/
	static Id getAccountId(){
		List<Account> lAccounts = [SELECT Id FROM Account LIMIT 1];
		return lAccounts.get(0).Id;
	}

}