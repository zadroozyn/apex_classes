@isTest
private class SalesPlanningTriggerTest {
    
    @isTest static void uniqueIdAllow() {
        TestDataFactory tdf = TestDataFactory.instance;
        List<Sales_Channel__c> sc = [Select Id from Sales_Channel__c];
        List<Sales_Season__c> ss = [Select Id from Sales_Season__c];
        Id recordTypeId_Budget= RecordTypeService.getRecordTypeIdByDeveloperName('Sales_Planning__c', 'Budget'); 
        Id recordTypeId_Forecast= RecordTypeService.getRecordTypeIdByDeveloperName('Sales_Planning__c', 'Forecast');
        
        Sales_Planning__c testSP_budget = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1,
            RecordTypeId = recordTypeId_Budget
        );
        insert testSP_budget;
        Sales_Planning__c testSP_forecast = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1,
            RecordTypeId = recordTypeId_Forecast
        );
        insert testSP_forecast;
        Sales_Planning__c testChannel = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[1].Id,
            Quantity__c = 1
        );
        insert testChannel;
        Sales_Planning__c testSeason = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[1].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        insert testSeason;
        Sales_Planning__c testItem = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 9.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        insert testItem;
        Sales_Planning__c testAcc = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc2').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        insert testAcc;
        List<Sales_Planning__c> lSPs = [SELECT Id,UniqueId__c FROM Sales_Planning__c];
        System.assertEquals(6, lSPs.size());
        Set<String> sUniqeIds = new Set<String>();
        for(Sales_Planning__c sp: lSPs) {
            System.assertEquals(false, String.isBlank(sp.UniqueId__c));
            System.assertEquals(false, sUniqeIds.contains(sp.UniqueId__c));
            sUniqeIds.add(sp.UniqueId__c);
        }    
    }
    
    @isTest static void uniqueIdBlock() {
        List<Sales_Channel__c> sc = [Select Id from Sales_Channel__c];
        List<Sales_Season__c> ss = [Select Id from Sales_Season__c];
        TestDataFactory tdf = TestDataFactory.instance;
        Sales_Planning__c testSP = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        insert testSP;
        Sales_Planning__c testSame = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        Boolean failed = false;
        try {
            insert testSame;
        } catch(Exception e) {
            failed = true;
        }
        System.assertEquals(true, failed);
    }

    @isTest static void updateUniqueId() {
        List<Sales_Channel__c> sc = [Select Id from Sales_Channel__c];
        List<Sales_Season__c> ss = [Select Id from Sales_Season__c];
        TestDataFactory tdf = TestDataFactory.instance;
        Sales_Planning__c testSP = new Sales_Planning__c(
            Account__c = tdf.accounts.getSObject('Test Acc').Id,
            Item__c = tdf.items.getSObject('4.4102 W 8.5').Id,
            Sales_Season__c = ss[0].Id,
            Sales_Channel__c = sc[0].Id,
            Quantity__c = 1
        );
        insert testSP;
        String oldUniqueId = [SELECT UniqueId__c FROM Sales_Planning__c].UniqueId__c;
        testSP.Sales_Season__c = ss[1].Id;
        update testSP;
        String newUniqueId = [SELECT UniqueId__c FROM Sales_Planning__c].UniqueId__c;
        System.assertEquals(false, oldUniqueId.equals(newUniqueId));
    }

    @testSetup static void setup() {
        TestDataFactory tdf = TestDataFactory.instance;
        tdf.accounts.createSObject('Test Acc', 'USD', true);
        tdf.accounts.createSObject('Test Acc2', 'USD', true);
        tdf.locations.createSObject('US-Stock', true);
        tdf.itemGroups.createSObject('Cloud group', '677', 'USD', 'No desc', null, true);
        tdf.items.createSObject('4.4102 W 8.5', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
            tdf.itemGroups.getAllSobjects()[0].Id, '7640165319338', true);
        tdf.items.createSObject('4.4102 W 9.5', 100, 120, 'test desc', tdf.locations.getSObject('US-Stock').Id, 
            tdf.itemGroups.getAllSobjects()[0].Id, '7640165319339', true);

        Sales_Channel__c sc1 = new Sales_Channel__c(Name = 'SC1');
        Sales_Channel__c sc2 = new Sales_Channel__c(Name = 'SC2');
        insert new List<Sales_Channel__c> {sc1, sc2};

        Sales_Season__c ss = new Sales_Season__c(Season__c = 'SS',Year__c = 18);
        Sales_Season__c fw = new Sales_Season__c(Season__c = 'FW',Year__c = 18);
        insert new List<Sales_Season__c> {ss, fw};
        

    }
    
}