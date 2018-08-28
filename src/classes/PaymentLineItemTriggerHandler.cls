/**
 * Trigger handler class for PaymentLineItem (API: c2g__codaPaymentLineItem__c ) object.
 * 
 * @version 1.0  2015.09.29 Ewa Latoszek (ewa.latoszek@nefoscdc.com).
 * 							Initial version of class.
 */

public class PaymentLineItemTriggerHandler implements ITriggerHandler {
	
	/**
	 * This method is called for list of records that need to be inserted during a BEFORE trigger.
	 * 
	 * @param lPaymentLineItems list of records that are instering.
	 */
	public static void beforeInsert(List<SObject> lPaymentLineItems) {
		
	}
	
	/**
	 * This method is called for records to be updated during a BEFORE trigger.
	 * 
	 * @param mPaymentLineItemsOld map of records that contain data before changes.
	 * @param mPaymentLineItemsNew map of records that contain data after changes.
	 */
	public static void beforeUpdate(Map<ID, SObject> mPaymentLineItemsOld, Map<ID, SObject> mPaymentLineItemsNew) {
		
	}	

	/**
	 * This method is called for records to be deleted during a BEFORE trigger.
	 * 
	 * @param mPaymentLineItemsOld map of records that contain data before changes.
	 * @param lPaymentLineItems map of records that contain data before changes.
	 */
	public static void beforeDelete(Map<ID, SObject> mPaymentLineItemsOld, List<SObject> lPaymentLineItems) {
		
	}

	/**
	 * This method is called for records inserted during an AFTER trigger.<br> 
	 * Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 * 
	 * @param mPaymentLineItems map of records that are inserted.
	 */
	public static void afterInsert(Map<ID, SObject> mPaymentLineItems) {
        PaymentLineItemMethods.fillPaymentDateOnPayableInvoice((List<c2g__codaPaymentLineItem__c>) mPaymentLineItems.values());
	}

	/**
	 * This method is called for records updated during an AFTER trigger.
	 *
	 * @param mPaymentLineItemsOld map of records that contain data before changes. 
	 * @param mPaymentLineItemNew map of records that are updated.
	 */
	public static void afterUpdate(Map<ID, SObject> mPaymentLineItemsOld, Map<ID, SObject> mPaymentLineItemNew) {
		
	}

	/**
	 * This method is called for map of records deleted during an AFTER trigger.
	 * 
	 * @param mPaymentLineItems map of records that are deleted.
	 */
	public static void afterDelete(Map<ID, SObject> mPaymentLineItems) {
        
	}
	
	/**
	 * This method is called for map of records undeleted during an AFTER trigger.
	 * 
	 * @param mPaymentLineItems map of records that are undeleted.
	 */
	public static void afterUnDelete(Map<ID, SObject> mPaymentLineItems) {
		
	}
}