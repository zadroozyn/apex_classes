/**
 * Trigger handler class for Back_Order_Request__c object.
 *
 * @version 1.0 2015.11.17  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 * 													Initial version of class.
 * @see BackOrderRequestTriggers Apex Trigger.
 */

public class BackOrderRequestTriggerHandler implements ITriggerHandler {

	/**
	 * This method is called for list of records that need to be inserted during a BEFORE trigger.
	 *
	 * @param lBackOrderRequests list of records that are instering.
	 */
	public static void beforeInsert(List<SObject> lBackOrderRequests) {
			BackOrderRequestMethods.fillInventoryValue((List<Back_Order_Request__c>) lBackOrderRequests);
	}

	/**
	 * This method is called for records to be updated during a BEFORE trigger.
	 *
	 * @param mBackOrderRequestsOld map of records that contain data before changes.
	 * @param mBackOrderRequestsNew map of records that contain data after changes.
	 */
	public static void beforeUpdate(Map<ID, SObject> mBackOrderRequestsOld, Map<ID, SObject> mBackOrderRequestsNew) {
		  BackOrderRequestMethods.fillInventoryValue(BackOrderRequestMethods.getRecordsThatNeedToHaveInventoryUpdated((Map<ID, Back_Order_Request__c>) mBackOrderRequestsOld, (Map<ID, Back_Order_Request__c>) mBackOrderRequestsNew));
	}

	/**
	 * This method is called for records to be deleted during a BEFORE trigger.
	 *
	 * @param mBackOrderRequestsOld map of records that contain data before changes.
	 * @param lBackOrderRequests map of records that contain data before changes.
	 */
	public static void beforeDelete(Map<ID, SObject> mBackOrderRequestsOld, List<SObject> lBackOrderRequests) {

	}

	/**
	 * This method is called for records inserted during an AFTER trigger.<br>
	 * Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 *
	 * @param mBackOrderRequests map of records that are inserted.
	 */
	public static void afterInsert(Map<ID, SObject> mBackOrderRequests) {

	}

	/**
	 * This method is called for records updated during an AFTER trigger.
	 *
	 * @param mBackOrderRequestsOld map of records that contain data before changes.
	 * @param mBackOrderRequestNew map of records that are updated.
	 */
	public static void afterUpdate(Map<ID, SObject> mBackOrderRequestsOld, Map<ID, SObject> mBackOrderRequestNew) {

	}

	/**
	 * This method is called for map of records deleted during an AFTER trigger.
	 *
	 * @param mBackOrderRequests map of records that are deleted.
	 */
	public static void afterDelete(Map<ID, SObject> mBackOrderRequests) {

	}

	/**
	 * This method is called for map of records undeleted during an AFTER trigger.
	 *
	 * @param mBackOrderRequests map of records that are undeleted.
	 */
	public static void afterUnDelete(Map<ID, SObject> mBackOrderRequests) {

	}
}