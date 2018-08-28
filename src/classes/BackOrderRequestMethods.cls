/**
 * Apex class that operates on Back_Order_Request__c records.
 *
 * @version 1.0 2015.11.17  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 * 													Initial version of class.
 * @see BackOrderRequestTriggerHandler Apex Trigger.
 */

public class BackOrderRequestMethods {

	 /**
	  * Method used to get list of Back_Order_Request__c records that need to have updated Inventory__c value.<br/>
		* It is called from BackOrderRequestTriggerHandler.beforeUpdate(Map<ID, SObject>, Map<ID, SObject>) method in order to
		* get parametr for fillInventoryValue(List<Back_Order_Request__c>) method.
		*
		* @param mBackOrderRequestsOld Map of Back_Order_Request__c records with values before update.
		* @param mBackOrderRequestsNew Map of Back_Order_Request__c records with values after update.
		* @return List of Back_Order_Request__c records that need to have updated Inventory__c value.
		* @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>
		*/
	 public static List<Back_Order_Request__c> getRecordsThatNeedToHaveInventoryUpdated(Map<ID, Back_Order_Request__c> mBackOrderRequestsOld, Map<ID, Back_Order_Request__c> mBackOrderRequestsNew) {
		  List<Back_Order_Request__c> lBackOrderRequestRecords = new List<Back_Order_Request__c>();
      Back_Order_Request__c new_record;

			for (Back_Order_Request__c old_record : mBackOrderRequestsOld.values()) {
				 new_record = mBackOrderRequestsNew.get(old_record.ID);

				 if ((String.isBlank(old_record.Inventory__c) ||
				 			old_record.Shoe__c != new_record.Shoe__c ||
							old_record.Location__c != new_record.Location__c) &&
							!String.isBlank(new_record.Shoe__c) &&
							!String.isBlank(new_record.Location__c)) {

					  lBackOrderRequestRecords.add(new_record);
				 }
			}

			return lBackOrderRequestRecords;
	 }

	 /**
	  * Method used to link Inventories to given Back_Order_Request__c records base on Inventory that is related to Item and Location.</br>
		* There is assumption that the sale Item and Location is seto only on one Inventory Detail record.</br>
		* Method is called from BackOrderRequestTriggerHandler.beforeInsert(List<SObject>) and
		* BackOrderRequestTriggerHandler.beforeUpdate(Map<ID, SObject>, Map<ID, SObject>) methods.
		*
		* @param lBackOrderRequestRecords List of Back_Order_Request__c records that need to have updated Inventory__c value.
		* @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>
		*/
	 public static void fillInventoryValue(List<Back_Order_Request__c> lBackOrderRequestRecords) {
		  System.debug(LoggingLevel.INFO, '************** fill Inventory value **************');
		  Set<ID> sItemIDs = new Set<ID>();
			Set<ID> sLocationIDs = new Set<ID>();
			Map<ID, Map<ID, ID>> mLocationIDToItemIDToInventoryID = new Map<ID, Map<ID, ID>>();

			for (Back_Order_Request__c record : lBackOrderRequestRecords) {
					sItemIDs.add(record.Shoe__c);
					sLocationIDs.add(record.Location__c);
			}

			for (PBSI__PBSI_Inventory__c inventory : [SELECT 	ID, PBSI__item_lookup__c, PBSI__location_lookup__c
																								FROM 		PBSI__PBSI_Inventory__c
																								WHERE 	PBSI__item_lookup__c IN :sItemIDs AND
																												PBSI__location_lookup__c IN :sLocationIDs]) {
				 if (!mLocationIDToItemIDToInventoryID.containsKey(inventory.PBSI__location_lookup__c)) {
					  mLocationIDToItemIDToInventoryID.put(inventory.PBSI__location_lookup__c, new Map<ID, ID>());
				 }

				 mLocationIDToItemIDToInventoryID.get(inventory.PBSI__location_lookup__c).put(inventory.PBSI__item_lookup__c, inventory.ID);
			}

			System.debug(LoggingLevel.INFO, '************** mLocationIDToItemIDToInventoryID: ' + mLocationIDToItemIDToInventoryID);

			for (Back_Order_Request__c record : lBackOrderRequestRecords) {
				  System.debug(LoggingLevel.INFO, '************** before record: ' + record);
				  if (!String.isBlank(record.Location__c) && !String.isBlank(record.Shoe__c)) {
							record.Inventory__c = mLocationIDToItemIDToInventoryID.get(record.Location__c).get(record.Shoe__c);
					}
					System.debug(LoggingLevel.INFO, '************** after record: ' + record);
			}
	 }
}