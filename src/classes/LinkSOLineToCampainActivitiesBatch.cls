/**
 * Batch class that is not scheduled. It is invoked manually.
 * It is used to link Sales Order Lines to the Campaing Activities.
 *
 * @version 1.0  2015.11.30 Ewa Latoszek <ewa.latoszek@nefoscdc.com>
 * 							 						Initial version of class.
 *
 * @see SalesOrderLineMethods APEX class.
 */

global class LinkSOLineToCampainActivitiesBatch implements Database.Batchable<sObject> {

	String query;

	Boolean removeDuplicatesMode;

	/**
	 * Class constructor used to assign default value to the query parameter.
	 */
	global LinkSOLineToCampainActivitiesBatch() {
		this('SELECT ID, PBSI__SOAccount__c, PBSI__Sales_Order__c, CreatedDate FROM PBSI__PBSI_Sales_Order_Line__c', false);
	}

	/**
	 * Class constructor used to assign given value to the query parameter.
	 */
	global LinkSOLineToCampainActivitiesBatch(String query) {
		this(query, false);
	}

	/**
	 * Class constructor used to assign given value to the query parameter.
	 */
	global LinkSOLineToCampainActivitiesBatch(String query, Boolean removeDuplicatesMode) {
		this.query = query;
		this.removeDuplicatesMode = removeDuplicatesMode;
	}

	/**
	 * Batch's start method. It invokes Database.getQueryLocator(String) method in order to
	 * retrieve Sales Order Line records to process.
	 */
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
	 * Batch's execute method. It invokes SalesOrderLineMethods.linkSalesOrderLineToCampainActivities(List<PBSI__PBSI_Sales_Order_Line__c>) method
	 * in order to create connection between Sales Order Line records to Campaign Activities.
	 */
  global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (!removeDuplicatesMode) {
				SalesOrderLineMethods.linkSalesOrderLineToCampainActivities((List<PBSI__PBSI_Sales_Order_Line__c>) scope);
		} else {
				// collecting
				Map<ID, Map<String, List<Sales_Order_to_Campain_Activity__c>>> mSalesOrderLineIDToCampaignNameToListOfLinks = new Map<ID, Map<String, List<Sales_Order_to_Campain_Activity__c>>>();

				for (Sales_Order_to_Campain_Activity__c record : (List<Sales_Order_to_Campain_Activity__c>) scope) {
						if (!mSalesOrderLineIDToCampaignNameToListOfLinks.containsKey(record.Sales_Order_Line__c)) {
								mSalesOrderLineIDToCampaignNameToListOfLinks.put(record.Sales_Order_Line__c, new Map<String, List<Sales_Order_to_Campain_Activity__c>> ());
						}

						if (!mSalesOrderLineIDToCampaignNameToListOfLinks.get(record.Sales_Order_Line__c).containsKey(record.Email_Tracking_Statistics__r.Name)) {
								mSalesOrderLineIDToCampaignNameToListOfLinks.get(record.Sales_Order_Line__c).put(record.Email_Tracking_Statistics__r.Name, new List<Sales_Order_to_Campain_Activity__c>());
						}

						mSalesOrderLineIDToCampaignNameToListOfLinks.get(record.Sales_Order_Line__c).get(record.Email_Tracking_Statistics__r.Name).add(record);
				}

				// sorting & removing
				List<Sales_Order_to_Campain_Activity__c> linksToRemove = new List<Sales_Order_to_Campain_Activity__c>();
				Sales_Order_to_Campain_Activity__c activityToLeave, activityToCheck;

				for (ID soLineID : mSalesOrderLineIDToCampaignNameToListOfLinks.keySet()) {
						for (String campaignName : mSalesOrderLineIDToCampaignNameToListOfLinks.get(soLineID).keySet()) {
								if (mSalesOrderLineIDToCampaignNameToListOfLinks.get(soLineID).get(campaignName).size() < 2) {
										continue;
								}

								activityToLeave = mSalesOrderLineIDToCampaignNameToListOfLinks.get(soLineID).get(campaignName).get(0);

								for (Integer index = 1; index < mSalesOrderLineIDToCampaignNameToListOfLinks.get(soLineID).get(campaignName).size(); index++) {
										activityToCheck = mSalesOrderLineIDToCampaignNameToListOfLinks.get(soLineID).get(campaignName).get(index);

										if (activityToLeave.Email_Tracking_Statistics__r.wbsendit__Activity_Date__c < activityToCheck.Email_Tracking_Statistics__r.wbsendit__Activity_Date__c) {
												activityToLeave = activityToCheck;
												linksToRemove.add(activityToLeave);
										} else {
												linksToRemove.add(activityToCheck);
										}
								}
						}
				}

				delete linksToRemove;
		}
	}

	/**
	 * Batch's execute method. It does nothig.
	 */
	global void finish(Database.BatchableContext BC) {

	}

}