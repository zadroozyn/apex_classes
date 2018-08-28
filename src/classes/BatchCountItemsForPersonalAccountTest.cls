@isTest class BatchCountItemsForPersonalAccountTest {

	@testSetup static void testSetup() {
		DataCreator dc = new DataCreator();
		System.runAs(dc.testAdmin) {
			final List<Account> personAccounts = new List<Account>();
			final List<Account> dealerAccounts = new List<Account>();
			for(Integer i = 0; i < 5; i++) {
				personAccounts.add(dc.createPersonAccount('Person account ' + i, 'CHF'));
				dealerAccounts.add(dc.createDealerAccount('Dealer account ' + i, 'CHF'));
			}


			final List<Account> allAccounts = new List<Account>();
			allAccounts.addAll(personAccounts);
			allAccounts.addAll(dealerAccounts);
			Database.insert(allAccounts);

			final List<PBSI__PBSI_Sales_Order__c> webOrders = new List<PBSI__PBSI_Sales_Order__c>();
			final List<PBSI__PBSI_Sales_Order__c> b2bOrders = new List<PBSI__PBSI_Sales_Order__c>();

			for(Account current : allAccounts) {
				webOrders.add(dc.createWebOrder(current));
				b2bOrders.add(dc.createPortalOrder(current));
			}

			List<PBSI__PBSI_Sales_Order__c> allSO = new List<PBSI__PBSI_Sales_Order__c>();
			allSO.addAll(webOrders);
			allSO.addAll(b2bOrders);
			Database.insert(allSO);

			c2g__codaCompany__c testCompany = TestUtility.createCompany(dc.testAdmin, 'CHF', 'CH');
			PBSI__Warehouse__c warehouse = TestUtility.createWarehouse('Test warehouse', true);
			PBSI__PBSI_Location__c testLocation = TestUtility.createLocation('Test location', warehouse.Id, true);
			PBSI__Lot__c testLot = TestUtility.createLot('Test lot', testLocation.Id, true);
			c2g__codaYear__c year = [SELECT Id FROM c2g__codaYear__c LIMIT 1];

			final List<PBSI__PBSI_Item_Group__c> parentItemGroups = new List<PBSI__PBSI_Item_Group__c>();
			parentItemGroups.add(TestUtility.createItemGroup('Shoes', null, false));
			parentItemGroups.add(TestUtility.createItemGroup('Performance running gear', null, false));
			insert parentItemGroups;

			final List<PBSI__PBSI_Item_Group__c> itemGroups = new List<PBSI__PBSI_Item_Group__c>();

			for(Integer i = 0; i < 2; i++) {
				itemGroups.add(TestUtility.createItemGroup('Shoes' + i, null, false));
				itemGroups.add(TestUtility.createItemGroup('Apparel' + i, null, false));
			}

			for(PBSI__PBSI_Item_Group__c current : itemGroups) {
				if(current.name.startsWith('Shoes')){
					current.PBSI__Parent_Group__c = parentItemGroups.get(0).Id;
				} else {
					current.PBSI__Parent_Group__c = parentItemGroups.get(1).Id;
				}
			}
			insert itemGroups;

			final List<Sizes__c> testSizes = new List<Sizes__c>();
			testSizes.add(TestUtility.createSize('M 10', null, false));
			testSizes.add(TestUtility.createSize('M 11', null, false));
			insert testSizes;

			final List<Fabric__c> testFabrics = new List<Fabric__c>();
			testFabrics.add(TestUtility.createFabric('Lime-Green', false));
			testFabrics.add(TestUtility.createFabric('Flame-Red', false));
			insert testFabrics;

			final List<PBSI__PBSI_Item__c> items = new List<PBSI__PBSI_Item__c>();
			for(Sizes__c currentSize : testSizes) {
				for(Fabric__c currentFabric : testFabrics) {
					for(PBSI__PBSI_Item_Group__c currentGroup : itemGroups) {
						items.add(TestUtility.createItem('Testitem', currentGroup.Id, testLocation.Id, warehouse.Id, currentFabric.Id, currentSize.Id, null, '100', false));
					}
				}
			}
			insert items;

			final List<PBSI__PBSI_Sales_Order_Line__c> soLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
			PBSI__PBSI_Sales_Order_Line__c tempSOL;
			allSO = [SELECT Id/*, Fulfiller__c*/ From PBSI__PBSI_Sales_Order__c];
			for(PBSI__PBSI_Sales_Order__c currentSO : allSO) {
				for(PBSI__PBSI_Item__c currentItem : items) {
					tempSOL = TestUtility.createSalesOrderLine(currentSO.Id, currentItem.Id, null, testLocation.Id, Math.random()*10, 0, false);
					tempSOL.PBSI__Quantity_Picked__c = tempSOL.PBSI__Quantity__c;
					tempSOL.PBSI__Quantity_Needed__c = 0;
					/*tempSOL.Fulfiller__c = 'KN';*/
					soLines.add(tempSOL);
				}
			}
			insert soLines;
            /*PBSI.SalesOrderAPI.ShipSalesOrderLines(soLine);*/
		}
	}

	@isTest static void testNewAccountsNoPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart();
		testNewAccounts(bj);
	}

	@isTest static void testNewAccountsWithPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart('LAST_N_DAYS:8');
		testNewAccounts(bj);
	}

	private static void testNewAccounts(BatchCountTotalsPersonAccountStart bj){
		DataCreator dc = new DataCreator();
		System.runAs(dc.testAdmin) {

			for(Account current : dc.testAccounts.values()) {
				System.assertEquals(0, current.Total_shoes_ordered__c, 'Before batch execution this field should be equal to 0.');
				System.assertEquals(0, current.Total_apparel_ordered__c, 'Before batch execution this field should be equal to 0.');
			}
			Test.startTest();
			Database.executeBatch(bj);
			Test.stopTest();
			final List<AggregateResult> aggregateResults = getAggregateResult();
			Map<Id, Account> accounts = dc.testAccounts;
			for(AggregateResult current : aggregateResults) {
				Account currentAcc =  accounts.get((Id)current.get('AccountId'));
				if(currentAcc.RecordTypeId == dc.accountRecordTypes.get('Person Account').getRecordTypeId()){
					System.assertEquals(current.get('Apparel_packed'), currentAcc.Total_apparel_ordered__c, 'Packed apparel count on order is different than one on account');
					System.assertEquals(current.get('Shoes_packed'), currentAcc.Total_shoes_ordered__c, 'Packed shoes count on order is different than one on account');
				} else {
					System.assertEquals(0, currentAcc.Total_shoes_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
					System.assertEquals(0, currentAcc.Total_apparel_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
				}
			}
		}
	}

	@isTest static void testUpdateAccountsNoPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart();
		testUpdateAccount(bj);
	}

	@isTest static void testUpdateAccountsWithPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart('LAST_N_DAYS:8');
		testUpdateAccount(bj);
	}

	private static void testUpdateAccount(BatchCountTotalsPersonAccountStart bj){
		DataCreator dc = new DataCreator();
		System.runAs(dc.testAdmin) {

			final List<Account> accounts = dc.testAccounts.values();
			for(Account current : accounts) {
				System.assertEquals(0, current.Total_shoes_ordered__c, 'Before batch execution this field should be equal to 0.');
				System.assertEquals(0, current.Total_apparel_ordered__c, 'Before batch execution this field should be equal to 0.');
				current.Total_shoes_ordered__c = 5;
				current.Total_apparel_ordered__c = 5;
			}

			update accounts;

			Test.startTest();
			Database.executeBatch(bj);
			Test.stopTest();

			final List<AggregateResult> aggregateResults = getAggregateResult();

			Map<Id, Account> mapaccounts = dc.testAccounts;
			for(AggregateResult current : aggregateResults) {
				Account currentAcc = mapaccounts.get((Id)current.get('AccountId'));
				if(currentAcc.RecordTypeId == dc.accountRecordTypes.get('Person Account').getRecordTypeId()){
					System.assertEquals(current.get('Apparel_packed'), currentAcc.Total_apparel_ordered__c, 'Packed apparel count on order is different than one on account');
					System.assertEquals(current.get('Shoes_packed'), currentAcc.Total_shoes_ordered__c, 'Packed shoes count on order is different than one on account');
				} else {
					System.assertEquals(0, currentAcc.Total_shoes_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
					System.assertEquals(0, currentAcc.Total_apparel_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
				}
			}
		}
	}

	@isTest static void testUpdateAccountWhenDeletedLinesNoPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart();
		testUpdateAccountWhenDeletedLines(bj);
	}

	@isTest static void testUpdateAccountWhenDeletedLinesWithPeriod(){
		BatchCountTotalsPersonAccountStart bj = new BatchCountTotalsPersonAccountStart('LAST_N_DAYS:8');
		testUpdateAccountWhenDeletedLines(bj);
	}

	private static void testUpdateAccountWhenDeletedLines(BatchCountTotalsPersonAccountStart bj ){
		DataCreator dc = new DataCreator();
		System.runAs(dc.testAdmin) {

			final List<Account> accounts = dc.testAccounts.values();
			for(Account current : accounts) {
				System.assertEquals(0, current.Total_shoes_ordered__c, 'Before batch execution this field should be equal to 0.');
				System.assertEquals(0, current.Total_apparel_ordered__c, 'Before batch execution this field should be equal to 0.');
				current.Total_shoes_ordered__c = 5;
				current.Total_apparel_ordered__c = 5;
			}

			update accounts;

			Test.startTest();
			Database.executeBatch(bj);
			Test.stopTest();

			final List<AggregateResult> aggregateResults = getAggregateResult();

			Map<Id, Account> mapaccounts = dc.testAccounts;
			for(AggregateResult current : aggregateResults) {
				Account currentAcc = mapaccounts.get((Id)current.get('AccountId'));
				if(currentAcc.RecordTypeId == dc.accountRecordTypes.get('Person Account').getRecordTypeId()){
					System.assertEquals(current.get('Apparel_packed'), currentAcc.Total_apparel_ordered__c, 'Packed apparel count on order is different than one on account');
					System.assertEquals(current.get('Shoes_packed'), currentAcc.Total_shoes_ordered__c, 'Packed shoes count on order is different than one on account');
				} else {
					System.assertEquals(0, currentAcc.Total_shoes_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
					System.assertEquals(0, currentAcc.Total_apparel_ordered__c, 'For accounts other than Person Account this field should always equal to 0.');
				}
			}
		}
	}

	private static List<AggregateResult> getAggregateResult(){
		return [SELECT pbsi__customer__c AccountId, SUM(Shoes_packed_on_order__c) Shoes_packed, SUM(Apparel_packed_on_order__c) Apparel_packed FROM pbsi__pbsi_sales_order__c WHERE id IN (SELECT pbsi__sales_order__c FROM PBSI__PBSI_Sales_Order_Line__c WHERE lastmodifieddate = LAST_N_DAYS:8 AND pbsi__sales_order__r.pbsi__customer__r.recordtype.name = 'person account') AND pbsi__customer__r.isDeleted = FALSE GROUP BY pbsi__customer__c ALL ROWS];
	}

	class DataCreator {

		public final Map<String,Schema.RecordTypeInfo> accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
		private final Map<String,Schema.RecordTypeInfo> salesorderRecordTypes = Schema.SObjectType.PBSI__PBSI_Sales_Order__c.getRecordTypeInfosByName();

		public User testAdmin {
			public get{
				if(this.testAdmin == null) {
					try {
						this.testAdmin = [SELECT Id, LastName FROM User WHERE LastName =: 'Admin_user'];
					} catch (Exception e){
						this.testAdmin = TestUtility.createUser('Admin_user', null, true);
					}
				}
				return this.testAdmin;
			}
			private set;
		}

		public Map<Id, Account> testAccounts {
			public get{
				return new Map<Id, Account>([SELECT Id, RecordTypeId, Total_shoes_ordered__c, Total_apparel_ordered__c FROM Account]);
			}
			private set;
		}

		public Account createPersonAccount (String name, String currencyIsoCode) {
			Account returnValue = TestUtility.createPersonAccount(name, currencyIsoCode, false);
			returnValue.recordTypeId = accountRecordTypes.get('Person Account').getRecordTypeId();
			return returnValue;
		}

		public Account createDealerAccount (String name, String currencyIsoCode) {
			Account returnValue = TestUtility.createAccount(name, currencyIsoCode, false);
			returnValue.recordTypeId = accountRecordTypes.get('Dealer').getRecordTypeId();
			return returnValue;
		}

		public PBSI__PBSI_Sales_Order__c createSalesOrder(Account acc) {
			return TestUtility.createSalesOrder(acc, null, salesOrderRecordTypes.get('Sales Order').getRecordTypeId(), 'CHF', false);
		}

		public PBSI__PBSI_Sales_Order__c createWebOrder(Account acc) {
			return TestUtility.createSalesOrder(acc, null, salesOrderRecordTypes.get('Web Order').getRecordTypeId(), 'CHF', false);
		}

		public PBSI__PBSI_Sales_Order__c createPortalOrder(Account acc) {
			return TestUtility.createSalesOrder(acc, null, salesOrderRecordTypes.get('B2B Portal').getRecordTypeId(), 'CHF', false);
		}
	}
}