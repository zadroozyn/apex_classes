/**
 * Class contains methods that are using to test LinkSOLineToCampainActivitiesBatch Apex Batch.<br/>
 * Class's methods use methods from TestUtility to create test data.
 *
 *
 * @version 1.0  2015.11.20  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 * 													 Initial version of class.
 *
 * @see LinkSOLineToCampainActivitiesBatch Apex class.
 * @see TestUtility APEX class.
 */

@isTest
public with sharing class LinkSOLineToCampainActivitiesBatchTest {

	  /**
       * Method used to test LinkSOLineToCampainActivitiesBatch batch job.
       */
		public static testMethod void linkSOLineToCampainActivitiesBatchTest() {
			User tester = TestUtility.createUser('tester', null, true); // method creates an user that has System Administrator profile

			System.runAs(tester) {

				// create & setup Company
				c2g__codaCompany__c company = TestUtility.createCompany(tester, 'CHF', 'CH');
				c2g__codaGeneralLedgerAccount__c general_ledger_account = TestUtility.createGeneralLedgerAccount('1100', false, 'Balance Sheet', 1, true);
				c2g__codaPeriod__c period = [SELECT ID FROM c2g__codaPeriod__c WHERE c2g__OwnerCompany__c = :company.ID LIMIT 1]; // It was created in TestUtility.createCompany(User, String, String) method.

				// create Products, Warehouse, Location and so on
				List<Product2> lProducts = new List<Product2>();

				lProducts.add(TestUtility.createProduct('Cloudrunner Edition Stormblack / Sea M 12', false));
				lProducts.add(TestUtility.createProduct('Cloudrunner Edition Stormblack / Mauve W 11', false));
				lProducts.add(TestUtility.createProduct('Cloud Black / White M 10', false));

				insert lProducts;

				Style_Year__c style_year = TestUtility.createStyleYear('2014', true);

				List<Sizes__c> lSizes = new List<Sizes__c>();

				lSizes.add(TestUtility.createSize('M 12', style_year.ID, false));
				lSizes.add(TestUtility.createSize('W 11', style_year.ID, false));
				lSizes.add(TestUtility.createSize('M 10', style_year.ID, false));

				insert lSizes;

				List<Fabric__c> lFabricCodes = new List<Fabric__c>();

				lFabricCodes.add(TestUtility.createFabric('0.12341', false));
				lFabricCodes.add(TestUtility.createFabric('0.12342', false));
				lFabricCodes.add(TestUtility.createFabric('0.12343', false));

				insert lFabricCodes;

				PBSI__Warehouse__c warehouse = TestUtility.createWarehouse('CH-Stock', true);
				PBSI__PBSI_Location__c location = TestUtility.createLocation('CH-Stock', warehouse.ID, true);

				List<PBSI__PBSI_Item_Group__c> lItem_groups = new List<PBSI__PBSI_Item_Group__c>();

				lItem_groups.add(TestUtility.createItemGroup('Cloudrunner', style_year.ID, false));
				lItem_groups.add(TestUtility.createItemGroup('Cloud Black', style_year.ID, false));

				insert lItem_groups;

				List<PBSI__PBSI_Item__c> lItems = new List<PBSI__PBSI_Item__c>();

				lItems.add(TestUtility.createItem('Cloudrunner Edition Stormblack / Sea M 12', lItem_groups.get(0).ID, location.ID, warehouse.ID, lFabricCodes.get(0).ID, lSizes.get(0).ID, style_year.ID, '12341', false));
				lItems.add(TestUtility.createItem('Cloudrunner Edition Stormblack / Mauve W 11', lItem_groups.get(0).ID, location.ID, warehouse.ID, lFabricCodes.get(1).ID, lSizes.get(1).ID, style_year.ID, '12342', false));
				lItems.add(TestUtility.createItem('Cloud Black / White M 10', lItem_groups.get(1).ID, location.ID, warehouse.ID, lFabricCodes.get(2).ID, lSizes.get(2).ID, style_year.ID, '12343', false));

				insert lItems;

				// create Person Account
				Account test_account = new Account();

				test_account.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
				test_account.FirstName = 'Jan';
				test_account.LastName = 'Kowalski';

				insert test_account;

				test_account = [SELECT ID, PersonContactId FROM Account WHERE ID = :test_account.ID];

				// create Campaign and Campaign Activities
				List<wbsendit__Campaign_Activity__c> lCampaignActivities = new List<wbsendit__Campaign_Activity__c>();

				lCampaignActivities.add(new wbsendit__Campaign_Activity__c(Name = 'Cloudrunner Campaign', wbsendit__Contact__c = test_account.PersonContactId, wbsendit__Activity__c = 'Clicked', wbsendit__Activity_Date__c = Datetime.now().addDays(-1)));
				lCampaignActivities.add(new wbsendit__Campaign_Activity__c(Name = 'Cloud Black / White Campaign', wbsendit__Contact__c = test_account.PersonContactId, wbsendit__Activity__c = 'Opened', wbsendit__Activity_Date__c = Datetime.now().addDays(-2)));

				insert lCampaignActivities;

				// create Sales Order with lines
				ID recordTypeID = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName().get('Web Order').getRecordTypeId();

				PBSI__PBSI_Sales_Order__c order = TestUtility.createSalesOrder(test_account, new Contact(ID = test_account.PersonContactId), recordTypeID, 'CHF', false);
				order.PBSI__From_Location__c = location.ID;
				insert order;

				List<PBSI__PBSI_Sales_Order_Line__c> lOrderLines = new List<PBSI__PBSI_Sales_Order_Line__c>();

				lOrderLines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = order.ID, PBSI__Item__c = lItems.get(0).ID));
				lOrderLines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = order.ID, PBSI__Item__c = lItems.get(1).ID));
				lOrderLines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = order.ID, PBSI__Item__c = lItems.get(2).ID));

				insert lOrderLines;

				// run batch & check results
				Test.startTest();

				Database.executeBatch(new LinkSOLineToCampainActivitiesBatch());

				Test.stopTest();

				System.assertEquals(12, [SELECT ID FROM Sales_Order_to_Campain_Activity__c].size());
			}
		}

}