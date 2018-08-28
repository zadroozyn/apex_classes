/**
 * Class contains handler methods that are used by CustomerVisitTrigger Apex class.
 * 
 * @version 1.0  2015.07.09  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 * 
 * @see CustomerVisitTrigger APEX trigger.
 * @see Customer Visit (API: Customer_Visit__c) sObject.
 */
 
public without sharing class CustomerVisitTriggerHandler implements ITriggerHandler {
	
	/**
	 * This method is called for list of records that need to be inserted during a BEFORE trigger.
	 * 
	 * @param lCustomerVisits list of records that are instering.
	 */
	public static void beforeInsert(List<SObject> lCustomerVisits) {
		CustomerVisitMethods.fillContactFields((List<Customer_Visit__c>) lCustomerVisits);
	}
	
	/**
	 * This method is called for records to be updated during a BEFORE trigger.
	 * 
	 * @param mCustomerVisitsOld map of records that contain data before changes.
	 * @param mCustomerVisitsNew map of records that contain data after changes.
	 */
	public static void beforeUpdate(Map<ID, SObject> mCustomerVisitsOld, Map<ID, SObject> mCustomerVisitsNew) {

	}	

	/**
	 * This method is called for records to be deleted during a BEFORE trigger.
	 * 
	 * @param mCustomerVisitsOld map of records that contain data before changes.
	 * @param lCustomerVisits map of records that contain data before changes.
	 */
	public static void beforeDelete(Map<ID, SObject> mCustomerVisitsOld, List<SObject> lCustomerVisits) {
		
	}

	/**
	 * This method is called for records inserted during an AFTER trigger.<br> 
	 * Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 * 
	 * @param mCustomerVisits map of records that are inserted.
	 */
	public static void afterInsert(Map<ID, SObject> mCustomerVisits) {
		
	}

	/**
	 * This method is called for records updated during an AFTER trigger.
	 *
	 * @param mCustomerVisitsOld map of records that contain data before changes. 
	 * @param mCustomerVisitNew map of records that are updated.
	 */
	public static void afterUpdate(Map<ID, SObject> mCustomerVisitsOld, Map<ID, SObject> mCustomerVisitNew) {
		
	}

	/**
	 * This method is called for map of records deleted during an AFTER trigger.
	 * 
	 * @param mCustomerVisits map of records that are deleted.
	 */
	public static void afterDelete(Map<ID, SObject> mCustomerVisits) {
		
	}
	
	/**
	 * This method is called for map of records undeleted during an AFTER trigger.
	 * 
	 * @param mCustomerVisits map of records that are undeleted.
	 */
	public static void afterUnDelete(Map<ID, SObject> mCustomerVisits) {
		
	}
	
}