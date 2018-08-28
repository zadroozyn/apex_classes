@isTest
public class OrderMatrixControllerTest {
    
    @TestSetup public static void prepareData(){
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
        //lines.add(new PBSI__PBSI_Sales_Order_Line__c(PBSI__Sales_Order__c = salesOrders[1].Id, PBSI__Item__c = lItemsToInsert[+1800].Id, PBSI__Quantity_Needed__c = 10, PBSI__Location__c =  salesOrders[1].PBSI__From_Location__c));
        insert lines;

        //List<PBSI__PBSI_Inventory__c> inventory = new List<PBSI__PBSI_Inventory__c> ();
        //for(PBSI__PBSI_Item__c current : lItemsToInsert){
        //    inventory.add(new PBSI__PBSI_Inventory__c(PBSI__qty__c=10, PBSI__item_lookup__c=current.Id, PBSI__location_lookup__c = loc.ID));
        //}
        //insert inventory;
    }



    @isTest public static void collectionFilterTest(){
        PBSI__PBSI_Sales_Order__c so1 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'Forecast'];
        PBSI__PBSI_Sales_Order__c so2 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'Stock clearance'];
        PBSI__PBSI_Sales_Order__c so3 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'New order'];

        Test.startTest();

        List<OrderMatrixSupporter.OptionWrapper> resultList1 = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableCollections(so1.Id);
        List<OrderMatrixSupporter.OptionWrapper>  resultList2 = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableCollections(so2.Id);
        List<OrderMatrixSupporter.OptionWrapper> resultList3 = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableCollections(so3.Id);

        Collection__c after_next = [SELECT Id, Status__c FROM Collection__c WHERE Collection_type__c = 'After next collection'];
        after_next.Status__c='Archived';
        update after_next;

        List<OrderMatrixSupporter.OptionWrapper> resultList4 = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableCollections(so1.Id);
        
        Test.stopTest();

        List<OrderMatrixSupporter.OptionWrapper> activeCollections1 = getActiveOptions(resultList1);
        List<OrderMatrixSupporter.OptionWrapper> activeCollections2 = getActiveOptions(resultList2);
        List<OrderMatrixSupporter.OptionWrapper> activeCollections3 = getActiveOptions(resultList3);
        List<OrderMatrixSupporter.OptionWrapper> activeCollections4 = getActiveOptions(resultList3);
        System.assertEquals(1, activeCollections1.size());
        System.assertEquals(1, activeCollections2.size());
        System.assertEquals(1, activeCollections3.size());
        System.assertEquals(1, activeCollections4.size());
        System.assertEquals(3, resultList1.size());
        System.assertEquals(2, resultList2.size());
        System.assertEquals(5, resultList3.size());
    }


    @isTest public static void itemGroupFilterTest(){
        PBSI__PBSI_Sales_Order__c so1 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'Forecast'];
        PBSI__PBSI_Sales_Order__c so2 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'Stock clearance'];
        PBSI__PBSI_Sales_Order__c so3 = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'New order'];

        Test.startTest();
        List<OrderMatrixSupporter.OptionWrapper> resultListShoes1	= (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableItemGroups(0, so1.Id);
        List<OrderMatrixSupporter.OptionWrapper> resultListShoes2	= (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableItemGroups(0, so2.Id);
        Test.stopTest();

        System.assertEquals(3, resultListShoes1.size());
        System.assertEquals(3, resultListShoes2.size());
    }



    @isTest public static void getOMDataTest(){
        PBSI__PBSI_Sales_Order__c so = [SELECT Id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c = 'New order'];
        List<OrderMatrixSupporter.CollectionWrapper> lCollections = (List<OrderMatrixSupporter.CollectionWrapper>) OrderMatrixController.fetchAvailableCollections(so.Id);
        List<OrderMatrixSupporter.OptionWrapper> lGroups = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableItemGroups(0, so.Id);
        for(OrderMatrixSupporter.CollectionWrapper current : lCollections){
            current.checked = true;
        }
        PBSI__PBSI_Sales_Order__c order = [SELECT id FROM PBSI__PBSI_Sales_Order__c WHERE Sales_Order_Type__c='New order'];
        for(OrderMatrixSupporter.OptionWrapper current : lGroups){
            if(!current.name.equalsIgnoreCase('Cloudmarathoners')){
                current.checked=true;
            } else {
                current.checked=false;
            }
        }
        List<List<Object>> result = OrderMatrixController.getOMData(order.id, lGroups, lCollections);
        
        System.assertEquals(2,      result[0].size());
        System.assertEquals(25,     result[1].size());
        System.assertEquals(5,     result[2].size());
        System.assertEquals(240,    result[3].size());// Items
        System.assertEquals(10,     result[4].size());
        System.assertEquals(0,      result[5].size());
        System.assertEquals(240,    result[6].size());// as 3?
        
        Test.startTest();

        List<OrderMatrixSupporter.MatrixLine> itemLines = new List<OrderMatrixSupporter.MatrixLine>();

        for(Integer i = 0; i < 20; i++){
            OrderMatrixSupporter.MatrixLine temp = new OrderMatrixSupporter.MatrixLine();
            PBSI__PBSI_Item__c resultItem = (PBSI__PBSI_Item__c) result[3][i];
            temp.itemId = resultItem.Id;
            temp.lineId = new List<String>();
            temp.quantity = '10';
            temp.price = '100.1';
            itemLines.add(temp);
        }
        for(Integer i = 0; i < result[4].size(); i++){
            OrderMatrixSupporter.MatrixLine temp = new OrderMatrixSupporter.MatrixLine();
            PBSI__PBSI_Sales_Order_Line__c current = (PBSI__PBSI_Sales_Order_Line__c) result[4][i];
            temp.itemId = current.PBSI__Item__c;
            temp.quantity = String.valueOf(current.PBSI__Quantity_Needed__c + 5);
            temp.price = '100';
            if(temp.lineId == null){
                temp.lineId = new List<String>(); 
            }
            temp.lineId.add(current.Id);
            if(Math.mod(i, 2) == 0){
                temp.quantity = '0';
            }
            itemLines.add(temp);
        }
        OrderMatrixController.saveLines(order.id, itemLines, true);
        Test.stopTest();
        System.assertEquals(25, [Select id FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c = : order.Id].size());
    }

	@isTest static void testTransferOM() {
		TestDataFactory tdf = TestDataFactory.instance;
		PBSI__Transfer_Order__c to = (PBSI__Transfer_Order__c)tdf.transferOrders.getAllSObjects()[0];
        List<OrderMatrixSupporter.CollectionWrapper> lCollections = (List<OrderMatrixSupporter.CollectionWrapper>) OrderMatrixController.fetchAvailableCollections(to.Id);
        List<OrderMatrixSupporter.OptionWrapper> lGroups = (List<OrderMatrixSupporter.OptionWrapper>) OrderMatrixController.fetchAvailableItemGroups(0, to.Id);
		System.assertEquals(lCollections, null, '');
		System.debug(lGroups);

        List<List<Object>> result = OrderMatrixController.getOMData(to.id, lGroups, lCollections);

		System.assertEquals(result.size(), 5, '');
        
		System.assertEquals(3, result[0].size());
		System.assertEquals(25, result[1].size());
		System.assertEquals(5, result[2].size());
		System.assertEquals(360, result[3].size());// Items
		System.assertEquals(0, result[4].size());
        
		Test.startTest();
		List<OrderMatrixSupporter.MatrixLine> itemLines = new List<OrderMatrixSupporter.MatrixLine>();

		for(Integer i = 0; i < 20; i++){
			OrderMatrixSupporter.MatrixLine temp = new OrderMatrixSupporter.MatrixLine();
			PBSI__PBSI_Item__c resultItem = (PBSI__PBSI_Item__c) result[3][i];
			temp.itemId = resultItem.Id;
			temp.lineId = new List<String>();
			temp.quantity = '10';
			itemLines.add(temp);
		}
        /*for(Integer i = 0; i < result[4].size(); i++){*/
            /*OrderMatrixSupporter.MatrixLine temp = new OrderMatrixSupporter.MatrixLine();*/
            /*PBSI__PBSI_Sales_Order_Line__c current = (PBSI__PBSI_Sales_Order_Line__c) result[4][i];*/
            /*temp.itemId = current.PBSI__Item__c;*/
            /*temp.quantity = String.valueOf(current.PBSI__Quantity_Needed__c + 5);*/
            /*temp.price = '100';*/
            /*if(temp.lineId == null){*/
                /*temp.lineId = new List<String>(); */
            /*}*/
            /*temp.lineId.add(current.Id);*/
            /*if(Math.mod(i, 2) == 0){*/
                /*temp.quantity = '0';*/
            /*}*/
			/*itemLines.add(temp);*/
        /*}*/
		OrderMatrixController.saveLines(to.Id, itemLines, true);
		Test.stopTest();
		PBSI__Transfer_Order__c to2 = [SELECT Id, (SELECT Id FROM PBSI__Transfer_Order_Lines__r) FROM PBSI__Transfer_Order__c WHERE Id =: to.Id];
		System.assertEquals(20, to2.PBSI__Transfer_Order_Lines__r.size(), '');
	}

    private static List<OrderMatrixSupporter.OptionWrapper> getActiveOptions (List<OrderMatrixSupporter.OptionWrapper> input) {
        List<OrderMatrixSupporter.OptionWrapper> output = new List<OrderMatrixSupporter.OptionWrapper> ();
        for(OrderMatrixSupporter.OptionWrapper current : input){
            if(current.checked){
                output.add(current);
            }
        }
        return output;
    }


}