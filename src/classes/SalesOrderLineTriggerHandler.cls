/**
 * Class contains methods that handle SalesOrderLineTriggers trigger events.<br/>
 * Methods of that class invoke methods from SalesOrderLineMethods class.
 *
 * @version 3.0  2015.11.30 Ewa Latoszek <ewa.latoszek@nefoscdc.com>
 * 							 						Added invoking of SalesOrderLineMethods.linkSalesOrderLineToCampainActivities(List<PBSI__PBSI_Sales_Order_Line__c>)
 * 													method on After Insert event.
 *
 * @version 2.0  2015.08.13 Ascent Support
 *							 						Added invoking of BacthATPByLocation Apex Batch on After Insert event.
 *
 * @version 1.0  2015.02.18 Ewa Latoszek <ewa.latoszek@nefoscdc.com>
 * 							 						Initial version of class.
 *
 * @see SalesOrderLineMethods APEX class.
 * @see ITriggerHandler APEX class.
 * @see SalesOrderLineTriggers APEX trigger.
 */

public without sharing class SalesOrderLineTriggerHandler implements ITriggerHandler {

	/**
	 * It is used to enable and disable feature.
	 */
	private static final Features_enable_disable_settings__c features_settings;

	/**
	 * Block used to assing value to features_settings attribute.
	 */
	static {
		Map<String, Features_enable_disable_settings__c> mFeatureSettings = Features_enable_disable_settings__c.getAll();

		if (mFeatureSettings.containsKey('organisation_setting')) {
			features_settings = mFeatureSettings.get('organisation_setting');
		} else {
			features_settings = new Features_enable_disable_settings__c();
		}
	}

	/**
	 * This method is called for list of records that need to be inserted during a BEFORE trigger.
	 *
	 * @param lSalesOrderLines list of records that are instering.
	 */
	public static void beforeInsert(List<SObject> lSalesOrderLines) {
     UpdateSODetails.calculateTradeLine(lSalesOrderLines, null, null);
	}

	/**
	 * This method is called for records to be updated during a BEFORE trigger.
	 *
	 * @param mSalesOrderLinesOld map of records that contain data before changes.
	 * @param mSalesOrderLinesNew map of records that contain data after changes.
	 */
	public static void beforeUpdate(Map<ID, SObject> mSalesOrderLinesOld, Map<ID, SObject> mSalesOrderLinesNew) {

	}

	/**
	 * This method is called for records to be deleted during a BEFORE trigger.
	 *
	 * @param mSalesOrderLinesOld map of records that contain data before changes.
	 * @param lSalesOrderLines map of records that contain data before changes.
	 */
	public static void beforeDelete(Map<ID, SObject> mSalesOrderLinesOld, List<SObject> lSalesOrderLines) {

	}

	/**
	 * This method is called for records inserted during an AFTER trigger.<br>
	 * Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The records are 'read only' by this point.
	 *
	 * @param mSalesOrderLines map of records that are inserted.
	 */
	public static void afterInsert(Map<ID, SObject> mSalesOrderLines) {
		if (features_settings.Enable_counting_of_styles__c) {
			SalesOrderLineMethods.handleNumberOfStylesChange((List<PBSI__PBSI_Sales_Order_Line__c>) mSalesOrderLines.values());
		}

		SalesOrderLineMethods.linkSalesOrderLineToCampainActivities((List<PBSI__PBSI_Sales_Order_Line__c>) mSalesOrderLines.values());
		/*
		BacthATPByLocation bp = new BacthATPByLocation();
		bp.solineids=mSalesOrderLines.keyset();
		Database.executeBatch(bp);
		*/
	}

	/**
	 * This method is called for records updated during an AFTER trigger.
	 *
	 * @param mSalesOrderLinesOld map of records that contain data before changes.
	 * @param mSalesOrderNew map of records that are updated.
	 */
	public static void afterUpdate(Map<ID, SObject> mSalesOrderLinesOld, Map<ID, SObject> mSalesOrderLinesNew) {
		if (features_settings.Enable_counting_of_styles__c) {
			SalesOrderLineMethods.handleNumberOfStylesChange((List<PBSI__PBSI_Sales_Order_Line__c>) mSalesOrderLinesNew.values(),(Map<ID, PBSI__PBSI_Sales_Order_Line__c>)  mSalesOrderLinesOld);
		}
	}

	/**
	 * This method is called for map of records deleted during an AFTER trigger.
	 *
	 * @param mSalesOrderLines map of records that are deleted.
	 */
	public static void afterDelete(Map<ID, SObject> mSalesOrderLines) {
		if (features_settings.Enable_counting_of_styles__c) {
			SalesOrderLineMethods.handleNumberOfStylesChange((List<PBSI__PBSI_Sales_Order_Line__c>) mSalesOrderLines.values());
		}
	}

	/**
	 * This method is called for map of records undeleted during an AFTER trigger.
	 *
	 * @param mSalesOrderLines map of records that are undeleted.
	 */
	public static void afterUnDelete(Map<ID, SObject> mSalesOrderLines) {

	}

}