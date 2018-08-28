@isTest
class OrderMatrixTest {
	@TestSetup
	public static void prepareData(){
		TestCustomSettingsFactory tcsf = new TestCustomSettingsFactory();
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.accounts.createSObject('Test_account_1', 'CHF', true);
		tdf.locations.createSObject('Test_location_1', false);
		tdf.locations.createSObject('Test_location_2', false);
		tdf.locations.createSObject('Test_transit', true, false);
		tdf.locations.insertAll();

		List<PBSI__PBSI_Sales_Order__c> salesOrders = new List<PBSI__PBSI_Sales_Order__c>();
		salesOrders.add(tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account_1'), 'Forecast', tdf.locations.getSObjectId('Test_location_1'), false));
		salesOrders.add(tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account_1'), 'New order', tdf.locations.getSObjectId('Test_location_1'), false));
		salesOrders.add(tdf.salesOrders.createSObject(tdf.accounts.getSObjectId('Test_account_1'), 'Stock clearance', tdf.locations.getSObjectId('Test_location_1'), false));
		insert salesOrders;

		tdf.transferOrders.createSObject(tdf.locations.getSObjectId('Test_location_1'), tdf.locations.getSObjectId('Test_location_2'), tdf.locations.getSObjectId('Test_transit'), true);

		List<Collection__c> collections = new List<Collection__c>();
		collections.add(tdf.collections.createSObject('Test Winter-15', 'Old collection', 'Active', null, false));
		collections.add(tdf.collections.createSObject('Test Spring-15', 'Current collection', 'Active', null, false));
		collections.add(tdf.collections.createSObject('Test Summer-15', 'Next collection', 'Active', null, false));
		collections.add(tdf.collections.createSObject('Test Fall-15', 'After next collection', 'Active', null, false));
		collections.add(tdf.collections.createSObject('Test Bestsellers', 'Special collection', 'Active', null, false));
		collections.add(tdf.collections.createSObject('Test Winter-14', 'Old collection', 'Archived', null, false));
		tdf.collections.insertAll();

		List<PBSI__PBSI_Item_Group__c> parentGroups = new List<PBSI__PBSI_Item_Group__c>();
		parentGroups.add(tdf.itemGroups.createSObject('Shoes', System.label.Item_group_shoes_code, 'USD', 'Sample description', null, false));
		parentGroups.add(tdf.itemGroups.createSObject('Essentials', System.label.Item_group_apparel_code, 'USD', 'Sample description', null, false));
		tdf.itemGroups.insertAll();

		List<PBSI__PBSI_Item_Group__c> itemGroups = new List<PBSI__PBSI_Item_Group__c>();
		itemGroups.add(tdf.itemGroups.createSObject('Cloudrunner', 'run', 'USD','Sample description', parentGroups[0].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Cloudsprinter', 'spr', 'USD','Sample description', parentGroups[0].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Cloudmarathoners', 'mar', 'USD','Sample description', parentGroups[0].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Clouder', 'mar', 'USD','Sample description', parentGroups[0].Id, false));

		itemGroups.add(tdf.itemGroups.createSObject('Capillatus', 'cap', 'USD','Sample description', parentGroups[1].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Floccus', 'flo', 'USD','Sample description', parentGroups[1].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Humilis', 'hum', 'USD','Sample description', parentGroups[1].Id, false));
		itemGroups.add(tdf.itemGroups.createSObject('Nebulosus', 'neb', 'USD','Sample description', parentGroups[1].Id, false));
		tdf.itemGroups.upsertAll();

		List<Sizes__c> lShoeSizes =  new List<Sizes__c>();
		for(Decimal i = 8; i < 14; i+=0.5){
			lShoeSizes.add(new Sizes__c(Name='W ' + i, European_Size__c='' + (34 + i), MM__c='' + Integer.valueOf((270 + (i-8)*3)), UK_Size__c='' + i, US_Men__c='0', US_Women__c='' + i, US_Size__c='W ' + i, Type__c = '2'));
			lShoeSizes.add(new Sizes__c(Name='M ' + i+1,         European_Size__c='' + (36 + i),      MM__c='' + Integer.valueOf((280 + (i-8)*4)), UK_Size__c='' + i,      US_Men__c='' + 1,      US_Women__c='' + i,   US_Size__c='M ' + i+1,    Type__c = '1'));
		}

		lShoeSizes.add(new Sizes__c(Name='M 15',         European_Size__c='' + 50,     MM__c='350', UK_Size__c='16',      US_Men__c='15',      US_Women__c= '',   US_Size__c='M 15',    Type__c = ''));
		insert lShoeSizes;


		List<Fabric__C> lFabricsToInsert = new List<Fabric__c>();
		for(Integer i = 0; i < 10; i++){
			lFabricsToInsert.add(new Fabric__c(Name = '0.' + i + '000'));
			lFabricsToInsert.add(new Fabric__c(Name = '0.' + i + '001'));
		}
		insert lFabricsToInsert;

		List<Collection_item__c> lCollectionItemsToInsert = new List<Collection_item__c>();
		for(Integer i = 0; i < 5; i++){
			for(Integer j = 0; j < 3; j++){
				for(Integer k = 0; k < 5; k++){
					lCollectionItemsToInsert.add(new Collection_item__c(Collection__c=collections[i].Id, Fabric_Code__c=lFabricsToInsert[k].Id,Item_Group__c=itemGroups[j].id));
				}
			}
		}
		insert lCollectionItemsToInsert;

		List<PBSI__PBSI_Item__c> lItemsToInsert = new List<PBSI__PBSI_Item__c>();
		for(Integer i = 0; i < lShoeSizes.size(); i++){
			for(Integer j = 0; j < 3; j++){
				for(Integer k = 0; k < 5; k++){
					lItemsToInsert.add(new PBSI__PBSI_Item__c(Name='Test item ' + i + ' ' + j + ' ' + k + ' k', Size__c=lShoeSizes[i].Id, PBSI__Item_Group__c=itemGroups[j].id, Fabric_Code__c=lFabricsToInsert[k].id,PBSI__purchaseprice__c = 56, PBSI__salesprice__c = 88, PBSI__description__c = 'ascfasfasf', PBSI__defaultunitofmeasure__c = 'EA',EAN_Number__c='112288'));
				}
			}
		}
		System.debug('generated items: ' + lItemsToInsert.size());
		insert lItemsToInsert;

		List<PBSI__PBSI_Sales_Order_Line__c> lines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		for(Integer i = 0; i < 10; i++){
			lines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = salesOrders[1].Id, PBSI__Item__c = lItemsToInsert[i+75].Id, PBSI__Quantity_Needed__c = 10, PBSI__Location__c =  salesOrders[1].PBSI__From_Location__c));
		}
		insert lines;
	}
	@isTest
	static void testGetOptions() {
		TestDataFactory tdf = TestDataFactory.instance;
		new OrderMatrix(tdf.salesOrders.getSObjectId('0')).getOptions();
	}

	@isTest
	static void testGetFilterData() {
		TestDataFactory tdf = TestDataFactory.instance;
		new OrderMatrix(tdf.salesOrders.getSObjectId('0')).getFilterData();
	}

	@isTest
	static void testGetMatrixData() {
		TestDataFactory tdf = TestDataFactory.instance;
		Map<String, List<Id>> input = new Map<String, List<Id>>();
		input.put('collections', new List<Id>());
		input.get('collections').addAll(new Map<Id, Collection__c>([SELECT Id FROM Collection__c]).keySet());
		input.put('itemGroups', new List<Id>());
		input.get('itemGroups').addAll(new Map<Id, PBSI__PBSI_Item_Group__c>([SELECT Id FROM PBSI__PBSI_Item_Group__c]).keySet());

		new OrderMatrix(tdf.salesOrders.getSObjectId('0')).getMatrixData(input);
	}

}