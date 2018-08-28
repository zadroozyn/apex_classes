@isTest
class CollectionMethodsTest{

	@testSetup
	static void prepareData(){
		TestDataFactory tdf = TestDataFactory.instance;
		tdf.locations.createSObject('CH-Stock', false);
		tdf.locations.createSObject('EU-Stock', false);
		tdf.locations.insertAll();
		tdf.collections.createSObject('Test Winter-15', 'Old collection', 'Active', null, false);
		tdf.collections.createSObject('Test Spring-15', 'Current collection', 'Active', null, false);
		tdf.collections.createSObject('Test Summer-15', 'Next collection', 'Active', null, false);
		tdf.collections.createSObject('Test Fall-15', 'After next collection', 'Active', null, false);
		tdf.collections.createSObject('Test Bestsellers', 'Special collection', 'Active', null, false);
		tdf.collections.createSObject('Test Winter-14', 'Old collection', 'Archived', null, false);
		tdf.collections.createSObject('Test Spring-14', 'Current collection', 'Archived', null, false);
		tdf.collections.createSObject('Test Summer-14', 'Next collection', 'Archived', null, false);
		tdf.collections.createSObject('Test Fall-14', 'After next collection', 'Archived', null, false);
		tdf.collections.createSObject('Test Old Bestsellers', 'Special collection', 'Archived', null, false);
		tdf.collections.createSObject('Test Winter-15 CH', 'Old collection', 'Active', tdf.locations.getSObjectId('CH-Stock'), false);
		tdf.collections.createSObject('Test Spring-15 CH', 'Current collection', 'Active', tdf.locations.getSObjectId('CH-Stock'), false);
		tdf.collections.createSObject('Test Summer-15 CH', 'Next collection', 'Active', tdf.locations.getSObjectId('CH-Stock'), false);
		tdf.collections.createSObject('Test Fall-15 CH', 'After next collection', 'Active', tdf.locations.getSObjectId('CH-Stock'), false);
		tdf.collections.createSObject('Test Bestsellers CH', 'Special collection', 'Active', tdf.locations.getSObjectId('CH-Stock'), false);
		tdf.collections.createSObject('Test Winter-15 EU', 'Old collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), false);
		tdf.collections.createSObject('Test Spring-15 EU', 'Current collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), false);
		tdf.collections.createSObject('Test Summer-15 EU', 'Next collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), false);
		tdf.collections.createSObject('Test Fall-15 EU', 'After next collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), false);
		tdf.collections.createSObject('Test Bestsellers EU', 'Special collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), false);
		tdf.collections.insertAll();

		List<Adapt_collections_mapping__c> customSettingsList = new List<Adapt_collections_mapping__c>();
		customSettingsList.add(new Adapt_collections_mapping__c(Name='Current collection', 		Map_to__c='Old collection'));
		customSettingsList.add(new Adapt_collections_mapping__c(Name='Next collection', 		Map_to__c='Current collection'));
		customSettingsList.add(new Adapt_collections_mapping__c(Name='After next collection', 	Map_to__c='Next collection'));
		insert customSettingsList;
	}

	@isTest
	static void testEnsureUniquenessOfCollectionType(){
		Exception exception1, exception2, exception3;
		Collection__c singleTestInsert = new Collection__c(Name='Test Winter-16', 	Collection_Type__c='Next collection', Status__c='Active');

		List<Collection__c> listTestInsert = new List<Collection__c>();
		listTestInsert.add(new Collection__c(Name='Test Winter-16', 		Collection_Type__c='Old collection', 		Status__c='Active'));
		listTestInsert.add(new Collection__c(Name='Test Spring-16', 		Collection_Type__c='Old collection', 		Status__c='Active'));

		Collection__c singleTestUpdate = [SELECT id FROM Collection__c WHERE Name='Test Winter-15'];
		singleTestUpdate.Collection_type__c = 'Current Collection';

		Test.startTest();

		try{
			insert singleTestInsert;
		} catch(Exception e){
			System.debug('Exception1: ' + e);
			exception1 = e;
		}

		try{
			insert listTestInsert;
		} catch(Exception e){
			System.debug('Exception1: ' + e);
			exception2 = e;
		}

		try{
			update singleTestUpdate;
		} catch(Exception e){
			System.debug('Exception1: ' + e);
			exception3 = e;
		}
		Test.stopTest();

		System.assert(exception1.getMessage().containsIgnoreCase(System.label.Collection_type_duplicate_error_msg), exception1.getMessage());
		System.assert(exception2.getMessage().containsIgnoreCase(System.label.Collection_type_duplicate_error_msg), exception2.getMessage());
		System.assert(exception3.getMessage().containsIgnoreCase(System.label.Collection_type_duplicate_error_msg), exception3.getMessage());

	}

	@isTest
	static void testCollectionUniquenessWithDifferentLocations (){
		TestDataFactory tdf = TestDataFactory.instance;

		Test.startTest();
		try {
			tdf.collections.createSObject('Test Winter-15 EU2', 'Current collection', 'Active', tdf.locations.getSObjectId('EU-Stock'), true);
		} catch (Exception e) {
			system.debug(e.getmessage());
			System.assert(e.getMessage().containsIgnoreCase(System.label.Collection_type_duplicate_error_msg), e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void testAdaptCollectionsForNewSeason(){
		Test.startTest();
		CollectionMethods.adaptCollectionsForNewSeason();
		Test.stopTest();
		TestDataFactory tdf = TestDataFactory.instance;

		System.assertEquals(System.Label.Collection_status_archived, tdf.collections.getSObject('Test Winter-15').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Winter-15').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Spring-15').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Spring-15').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Summer-15').get('Status__c'));
		System.assertEquals('Current collection', tdf.collections.getSObject('Test Summer-15').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Fall-15').get('Status__c'));
		System.assertEquals('Next collection', tdf.collections.getSObject('Test Fall-15').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Bestsellers').get('Status__c'));
		System.assertEquals('Special collection', tdf.collections.getSObject('Test Bestsellers').get('Collection_type__c'));

		System.assertEquals(System.Label.Collection_status_archived, tdf.collections.getSObject('Test Winter-15 EU').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Winter-15 EU').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Spring-15 EU').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Spring-15 EU').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Summer-15 EU').get('Status__c'));
		System.assertEquals('Current collection', tdf.collections.getSObject('Test Summer-15 EU').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Fall-15 EU').get('Status__c'));
		System.assertEquals('Next collection', tdf.collections.getSObject('Test Fall-15 EU').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Bestsellers EU').get('Status__c'));
		System.assertEquals('Special collection', tdf.collections.getSObject('Test Bestsellers EU').get('Collection_type__c'));

		System.assertEquals(System.Label.Collection_status_archived, tdf.collections.getSObject('Test Winter-15 CH').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Winter-15 CH').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Spring-15 CH').get('Status__c'));
		System.assertEquals('Old collection', tdf.collections.getSObject('Test Spring-15 CH').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Summer-15 CH').get('Status__c'));
		System.assertEquals('Current collection', tdf.collections.getSObject('Test Summer-15 CH').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Fall-15 CH').get('Status__c'));
		System.assertEquals('Next collection', tdf.collections.getSObject('Test Fall-15 CH').get('Collection_type__c'));
		System.assertEquals(System.Label.Collection_status_active, tdf.collections.getSObject('Test Bestsellers CH').get('Status__c'));
		System.assertEquals('Special collection', tdf.collections.getSObject('Test Bestsellers CH').get('Collection_type__c'));
	}
}