/**
 * Selector class for the PBSI__PBSI_Sales_Order__c object.
 * @author Dive Jakobusic
 */
public with sharing class SalesOrderSelector {
	
	/**
	 * Method updates fields that holds lates Ids for fields which are used by
	 * Cargo Care interface.
	 * @param salesOrderId         Order id.
	 * @param billOfDeliveryPdfId  Id of the latest bill of delivery pdf.
	 * @param returnInfoPdfId      Id of the latest return information pdf.
	 */
	public static void updateCargoCarePdfIds(Id salesOrderId, String billOfDeliveryPdfId, String returnInfoPdfId){
		
		if (billOfDeliveryPdfId == null && returnInfoPdfId == null) return;
		
		PBSI__PBSI_Sales_Order__c order = new PBSI__PBSI_Sales_Order__c(Id=salesOrderId);
		if (billOfDeliveryPdfId != null) order.Bill_of_Delivery_PDF_Id__c = billOfDeliveryPdfId;
		if (returnInfoPdfId != null) order.Return_Information_PDF_Id__c = returnInfoPdfId;
		update order;
	}

	/**
	 * Method gets sales order with given Id. Retrieves values for conga urls. 
	 * @param  salesOrderId id of sales order.
	 * @return              fetched sales order.
	 */
	public static PBSI__PBSI_Sales_Order__c getCongaURLsForCargoCareDocs(Id salesOrderId){
		return [SELECT Id, URL_Bill_of_Delivery__c, URL_Return_Information__c, URL_Purchase_Confirmation__c FROM PBSI__PBSI_Sales_Order__c WHERE Id = :salesOrderId ];
	}
}