@isTest
private class SalesOrderTrackingTest {

    @isTest
    static void newTrackingNumberContactExisting() {

        String currencyIsoCode = 'EUR';

        Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
        test_account.BillingCountry = 'Poland';
        test_account.BillingCity = 'Warsaw';
        test_account.BillingPostalCode = '00-123';
        test_account.BillingStreet = 'Marszałkowska 123';
        insert test_account;

        Contact test_contact = TestUtility.createContact('Test Contact', test_account, false);
        test_contact.Email = 'test@example.com';
        insert test_contact;

        Id b2bRecordTypeID = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_Portal');
        PBSI__PBSI_Location__c location = TestUtility.createLocation('test location', null, false);
        location.Shipment_Provider__c = 'UPS';
        insert location;

        Tracking_Providers__c provider = new Tracking_Providers__c(
            Name = 'UPS',
            Base_Url__c = 'www.example.com?track='
        );
        insert provider;

        PBSI__PBSI_Sales_Order__c salesOrder = TestUtility.createSalesOrder(test_account, test_contact, b2bRecordTypeID, currencyIsoCode, false);
        salesOrder.PBSI__From_Location__c = location.Id;
        insert salesOrder;

        Test.startTest();
            salesOrder.Tracking_Information__c = '1234567';
            update salesOrder;
            List<Tracking__c> lTrackingsTest = [SELECT Id,Service_Provider__c,Contact__c,Tracking_Link_Base__c FROM Tracking__c];
            System.assertEquals(1,[SELECT count() FROM Tracking__c]);

            salesOrder.Tracking_Number_1__c = '8910';
            update salesOrder;
            System.assertEquals(2,[SELECT count() FROM Tracking__c]);

            salesOrder.Back_Order_Tracking_Number_1__c = '111213';
            update salesOrder;    
            System.assertEquals(3,[SELECT count() FROM Tracking__c]);

            salesOrder.Tracking_Information__c = salesOrder.Tracking_Information__c + ', 8910, 111213, 777666555, POv56709';
            update salesOrder;  
            System.assertEquals(4,[SELECT count() FROM Tracking__c]);

            Tracking__c track = new Tracking__c(
            	Sales_Order__c = salesOrder.Id
            );      
            insert track; 
            System.assertEquals(5,[SELECT count() FROM Tracking__c]);

            Tracking_Number__c tn = new Tracking_Number__c(
            	Tracking__c = track.Id,
            	Number__c = '9mij873'
            );
            insert tn;     
            System.assertEquals(5,[SELECT count() FROM Tracking__c]);  

        Test.stopTest();
        List<Tracking__c> lTrackings = [SELECT Id,Service_Provider__c,Contact__c,Tracking_Link_Base__c FROM Tracking__c];
        System.assertEquals(5,lTrackings.size());
        for(Tracking__c tracking: lTrackings) {
            System.assertEquals('UPS',tracking.Service_Provider__c);
            System.assertEquals(test_contact.Id,tracking.Contact__c);
            System.assertEquals('www.example.com?track=',tracking.Tracking_Link_Base__c);
        }
        List<Tracking_Number__c> tns = [SELECT Number__c,Link__c,Do_Not_Send__c FROM Tracking_Number__c];
        System.assertEquals(6,tns.size());
        for(Tracking_Number__c tnTest: tns) {
            System.assertEquals('www.example.com?track='+tnTest.Number__c,tnTest.Link__c);
            System.assertEquals(false,tnTest.Do_Not_Send__c);
        }

    }

    @isTest
    static void isTrackingNumberToSendNegative() {
        String currencyIsoCode = 'EUR';

        Account test_account = TestUtility.createAccount('Test Account', currencyIsoCode, false);
        test_account.BillingCountry = 'Poland';
        test_account.BillingCity = 'Warsaw';
        test_account.BillingPostalCode = '00-123';
        test_account.BillingStreet = 'Marszałkowska 123';
        insert test_account;

        Contact test_contact = TestUtility.createContact('Test Contact', test_account, false);
        test_contact.Email = 'test@example.com';
        insert test_contact;

        Id b2bRecordTypeID = RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'B2B_Portal');
        PBSI__PBSI_Location__c location = TestUtility.createLocation('test location', null, false);
        location.Shipment_Provider__c = 'UPS';
        insert location;

        Tracking_Providers__c provider = new Tracking_Providers__c(
            Name = 'UPS',
            Base_Url__c = 'www.example.com?track='
        );
        insert provider;

        PBSI__PBSI_Sales_Order__c salesOrder = TestUtility.createSalesOrder(test_account, test_contact, b2bRecordTypeID, currencyIsoCode, false);
        salesOrder.PBSI__From_Location__c = location.Id;
        insert salesOrder;
        Test.startTest();
            salesOrder.Tracking_Information__c = String.join(TrackingNumberHandler.trackingExceptionsAnyPlace,', ');
            update salesOrder;
            salesOrder.Tracking_Information__c = salesOrder.Tracking_Information__c + ', '
                +String.join(TrackingNumberHandler.trackingExceptionsStartsWith,', ');
            update salesOrder;
        Test.stopTest();
        List<Tracking_Number__c> tns = [SELECT Number__c,Link__c,Do_Not_Send__c FROM Tracking_Number__c];
        System.assertEquals(
            TrackingNumberHandler.trackingExceptionsAnyPlace.size() + TrackingNumberHandler.trackingExceptionsStartsWith.size(),
            tns.size()
        );
        for(Tracking_Number__c tnTest: tns) {
            System.assertEquals(true,tnTest.Do_Not_Send__c);
        }
    }

}