/**
 * Apex class that contains methods to test methods from BackOrderRequestMethods Apex class.
 *
 * @version 1.0 2015.11.17  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 * 													Initial version of class.
 * @see BackOrderRequestMethods Apex class.
 */

@isTest
public class BackOrderRequestMethodsTest {

	/**
	 * Method used to test filling of Inventory__c field's value.
	 *
	 * @author Ewa Latoszek <ewa.latoszek@nefoscdc.com>
	 */
	public static testMethod void inventoryFillingTest() {
		 System.runAs(TestUtility.createUser('tester', null, true)) {

			  // create data
				Account test_account = TestUtility.createAccount('Test Account', 'EUR', true);
				PBSI__Warehouse__c test_warehouse = TestUtility.createWarehouse('Test Warehouse', true);
				Style_Year__c style_year = TestUtility.createStyleYear('2015', true);
				Fabric__c fabric = TestUtility.createFabric('Fabric', true);
				List<Sizes__c> lSizes = new List<Sizes__c>();

				lSizes.add(TestUtility.createSize('Size 1', style_year.ID, false));
				lSizes.add(TestUtility.createSize('Size 2', style_year.ID, false));
				lSizes.add(TestUtility.createSize('Size 3', style_year.ID, false));
				lSizes.add(TestUtility.createSize('Size 4', style_year.ID, false));

				insert lSizes;

				PBSI__PBSI_Item_Group__c item_group = TestUtility.createItemGroup('Item Group', style_year.ID, true);

				List<PBSI__PBSI_Location__c> lLocations = new List<PBSI__PBSI_Location__c>();

				lLocations.add(TestUtility.createLocation('Location 1', test_account.ID, test_warehouse.ID, false));
				lLocations.add(TestUtility.createLocation('Location 2', test_account.ID, test_warehouse.ID, false));
				lLocations.add(TestUtility.createLocation('Location 3', test_account.ID, test_warehouse.ID, false));
				lLocations.add(TestUtility.createLocation('Location 4', test_account.ID, test_warehouse.ID, false));

				insert lLocations;

				List<PBSI__PBSI_Item__c> lItems = new List<PBSI__PBSI_Item__c>();

				lItems.add(TestUtility.createItem('Item 1', item_group.ID, null, test_warehouse.ID, fabric.ID, lSizes.get(0).ID, style_year.ID, '112231', false));
				lItems.add(TestUtility.createItem('Item 2', item_group.ID, null, test_warehouse.ID, fabric.ID, lSizes.get(1).ID, style_year.ID, '112232', false));
				lItems.add(TestUtility.createItem('Item 3', item_group.ID, null, test_warehouse.ID, fabric.ID, lSizes.get(2).ID, style_year.ID, '112233', false));
				lItems.add(TestUtility.createItem('Item 4', item_group.ID, null, test_warehouse.ID, fabric.ID, lSizes.get(3).ID, style_year.ID, '112234', false));

				insert lItems;

				List<PBSI__PBSI_Inventory__c> lInventories = new List<PBSI__PBSI_Inventory__c>();

				lInventories.add(TestUtility.createInventory(lItems.get(0).ID, lLocations.get(0).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(1).ID, lLocations.get(0).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(0).ID, lLocations.get(1).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(1).ID, lLocations.get(1).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(2).ID, lLocations.get(0).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(0).ID, lLocations.get(2).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(2).ID, lLocations.get(1).ID, false));
				lInventories.add(TestUtility.createInventory(lItems.get(1).ID, lLocations.get(2).ID, false));

				insert lInventories;

				System.debug('******************* lInventories: ' + lInventories);

				Test.startTest();

				List<Back_Order_Request__c> lBackOrderRequests = new List<Back_Order_Request__c>();

				lBackOrderRequests.add(TestUtility.createBackOrderRequest(lItems.get(0).ID, lLocations.get(0).ID, false));
				lBackOrderRequests.add(TestUtility.createBackOrderRequest(lItems.get(0).ID, null, false));
				lBackOrderRequests.add(TestUtility.createBackOrderRequest(null, lLocations.get(0).ID, false));
				lBackOrderRequests.add(TestUtility.createBackOrderRequest(null, null, false));

				lBackOrderRequests.get(0).Name = '00';
				lBackOrderRequests.get(1).Name = '01';
				lBackOrderRequests.get(2).Name = '02';
				lBackOrderRequests.get(3).Name = '03';

				insert lBackOrderRequests;

				lBackOrderRequests = [SELECT ID, Shoe__c, Location__c, Inventory__c FROM Back_Order_Request__c ORDER BY Name];

				// Case #1
				// Input: Item, Location and Inventory linked to them.
				// Description: Back Order Request is inserted to the database with Item and Location filled.
				// Result: Back Order Request has Inventory filled.
				System.assertEquals(lInventories.get(0).ID, lBackOrderRequests.get(0).Inventory__c);

				// Case #2
				// Input: Item, Location and Inventory linked to them.
				// Description: Back Order Request is inserted to the database with only with Item filled.
				// Result: Back Order Request doesn't have Inventory filled.
				System.assertEquals(null, lBackOrderRequests.get(1).Inventory__c);

				// Case #3
				// Input: Item, Location and Inventory linked to them.
				// Description: Back Order Request is inserted to the database with only Location filled.
				// Result: Back Order Request doesn't have Inventory filled.
				System.assertEquals(null, lBackOrderRequests.get(2).Inventory__c);

				// Case #4
				// Input: Item, Location and Inventory linked to them.
				// Description: Back Order Request is inserted to the database without Item and Location filled.
				// Result: Back Order Request doesn't have Inventory filled.
				System.assertEquals(null, lBackOrderRequests.get(3).Inventory__c);

				lBackOrderRequests.get(1).Location__c = lLocations.get(0).ID;
				lBackOrderRequests.get(2).Shoe__c = lItems.get(0).ID;
				lBackOrderRequests.get(3).Shoe__c = lItems.get(0).ID;
				lBackOrderRequests.get(3).Location__c = lLocations.get(0).ID;

				update lBackOrderRequests;

				lBackOrderRequests = [SELECT ID, Shoe__c, Location__c, Inventory__c FROM Back_Order_Request__c ORDER BY Name];

				// Case #5
				// Input: Item, Location and Inventory linked to them. Back Order Request without Item and Location filled.
				// Description: Back Order Request gets Item and Location.
				// Result: Back Order Request has Inventory filled.
				System.assertEquals(lInventories.get(0).ID, lBackOrderRequests.get(1).Inventory__c);

				// Case #6
				// Input: Item, Location and Inventory linked to them. Back Order Request with Item and without Location filled.
				// Description: Back Order Request gets Location.
				// Result: Back Order Request has Inventory filled.
				System.assertEquals(lInventories.get(0).ID, lBackOrderRequests.get(2).Inventory__c);

				// Case #7
				// Input: Item, Location and Inventory linked to them. Back Order Request with Location and without Item filled.
				// Description: Back Order Request gets Item.
				// Result: Back Order Request has Inventory filled.
				System.assertEquals(lInventories.get(0).ID, lBackOrderRequests.get(3).Inventory__c);

				lBackOrderRequests.get(1).Location__c = lLocations.get(1).ID;
				lBackOrderRequests.get(2).Shoe__c = lItems.get(1).ID;
				lBackOrderRequests.get(3).Shoe__c = lItems.get(1).ID;
				lBackOrderRequests.get(3).Location__c = lLocations.get(1).ID;
				lBackOrderRequests.get(0).Shoe__c = lItems.get(2).ID;
				lBackOrderRequests.get(0).Location__c = lLocations.get(2).ID;

				update lBackOrderRequests;

				lBackOrderRequests = [SELECT ID, Shoe__c, Location__c, Inventory__c FROM Back_Order_Request__c ORDER BY Name];

				// Case #8
				// Input: Item, Location and Inventory linked to them. Back Order Request with Inventory filled.
				// Description: Back Order Request has changed Location.
				// Result: Back Order Request has changed Inventory.
				System.assertEquals(lInventories.get(1).ID, lBackOrderRequests.get(2).Inventory__c);

				// Case #9
				// Input: Item, Location and Inventory linked to them. Back Order Request with Inventory filled.
				// Description: Back Order Request has changed Item.
				// Result: Back Order Request has changed Inventory.
				System.assertEquals(lInventories.get(2).ID, lBackOrderRequests.get(1).Inventory__c);

				// Case #10
				// Input: Item, Location and Inventory linked to them. Back Order Request with Inventory filled.
				// Description: Back Order Request has changed Item and Location.
				// Result: Back Order Request has changed Inventory.
				System.assertEquals(lInventories.get(3).ID, lBackOrderRequests.get(3).Inventory__c);

				// Case #11
				// Input: Item, Location. No one Inventory is not linked to them. Back Order Request with Inventory filled.
				// Description: Back Order Request has changed Item and Location.
				// Result: Back Order Request Inventory is empty.
				System.assertEquals(null, lBackOrderRequests.get(0).Inventory__c);

				Test.stopTest();
		 }
	}

}