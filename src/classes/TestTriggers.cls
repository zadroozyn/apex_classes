/**
 * Test Class for Sales Order Triggers?
 *
 * Author: Unknown
 *
 * ver 1.1 2014-05-28 Mehmet Birgi <mehmet.birgi@nefos.com>
 *                      Adapted to premium package of AddressTools
 *                      Fixed invoice posting issues
 * ver 1.2 2016-04-18 Mehmet Birgi <mehmet.birgi@nefos.com>
 *                    Several edits to make the test run
 *
 * Copyright (c) 2014 Nefos GmbH
 *
 **/
@isTest(seealldata = true)
private class TestTriggers {

    public static testMethod void testso() {

        User testUser = TestUtil.createAdminUser('admin-' + Datetime.now().getTime() + '@test.dev');

        // set the test user to skip workflows (atm, just to be able to skip the due date overwrite issue while testing)
        ProcessControl__c testControl = ProcessControl__c.getInstance(testUser.Id);
        testControl.Skip_Workflows__c = true;
        upsert testControl;

        //Set our new user as belonging to a company
        // MBI 2016-04-18 CHG FROM
        //c2g__codaCompany__c company = [SELECT id, name FROM c2g__codaCompany__c LIMIT 1];
        // MBI 2016-04-18 CHG TO
        c2g__codaCompany__c company = [SELECT Id, Name FROM c2g__codaCompany__c WHERE Name = 'On AG'];
        // MBI 2016-04-18 CHG END
        String companyName = company.Name;
        insert new c2g__codaUserCompany__c(
            c2g__company__c = company.id,
            c2g__user__c = testUser.id);
        System.runAs( new User(id=UserInfo.getUserId()) ){ //insert setup sObject inside runAs to avoid MIXED_DML exception
            insert new groupMember(userOrGroupId = testUser.id, groupId = [SELECT id FROM Group WHERE name = :'FF '+companyName].id);
        }

        System.runAs(testUser) {

          PBSI__PBSI_Location__c loc=new PBSI__PBSI_Location__c(Name='Andreea');
          insert loc;

          try
          {
            insert TestUtil.GetProperty('DecimalPlaces', '4');
          }
          catch(Exception ex){}

          insert TestUtil.GetProperty('Item_Version', 'Yes');

          On_Payment_Terms__c opt = new On_Payment_Terms__c(Name='Test', Terms_Days__c = 7);
          insert opt;

          Account acc = TestUtil.GetAccount();
          acc.c2g__CODADaysOffset1__c = 10;
          acc.c2g__CODADaysOffset2__c = 1;
          acc.c2g__CODADaysOffset3__c = 1;
          acc.c2g__CODADaysOffset4__c = 1;
          acc.On_Payment_Term__c = opt.Id;
          System.debug('acc: ' + acc);
          insert acc;

          Account acc2 = ([select Id, On_Payment_Term__c, c2g__CODADaysOffset1__c, c2g__CODADaysOffset2__c,c2g__CODADaysOffset3__c, c2g__CODADaysOffset4__c  from Account where Id = :acc.Id limit 1]);
          system.assertEquals(acc2.On_Payment_Term__c,opt.Id);

          PBSI__PBSI_Sales_Order__c so =new PBSI__PBSI_Sales_Order__c(PBSI__Customer__c = acc2.Id, PBSI__BillingCountry__c = 'BC', PBSI__Due_Date__c = date.today());
          so.PBSI__From_Location__c = loc.Id;
          insert so;

          PBSI__PBSI_Sales_Order__c soSelected = [SELECT id,  name, PBSI__Customer__c,PBSI__Customer__r.c2g__CODADaysOffset1__c, PBSI__Customer__r.c2g__CODADaysOffset2__c, PBSI__Customer__r.c2g__CODADaysOffset3__c, PBSI__Customer__r.c2g__CODADaysOffset4__c FROM PBSI__PBSI_Sales_Order__c WHERE id = :so.id ];
          PBSI__PBSI_Item__c item = TestUtilActions.createItem();
          item.PBSI__Standard_Lead_Time__c = 5;
          item.PBSI__item_type__c = 'BOM';
          update item;

          PBSI__PBSI_Sales_Order_Line__c salesOrderLine = TestUtil.GetSalesOrderLine(so.Id, item.Id);
          //salesOrderLine.PBSI__bom__c = bom.Id;
          salesOrderLine.PBSI__Quantity_Needed__c = 3;
          salesOrderLine.PBSI__TransactionType__c = 'Sale';
          insert salesOrderLine;

          List<PBSI__PBSI_Sales_Order_Line__c> solList = new List<PBSI__PBSI_Sales_Order_Line__c>();
          solList.add(salesOrderLine);

         PBSI__Lot__c lot=new PBSI__Lot__c(Name='andreea', PBSI__Item__c = item.Id, PBSI__Location__c = loc.Id);
         insert lot;




         Test.startTest();


       	 system.assertEquals(soSelected.PBSI__Customer__r.c2g__CODADaysOffset1__c, 7);
         system.debug([Select c2g__CODADaysOffset1__c ,c2g__CODADaysOffset2__c, c2g__CODADaysOffset3__c, c2g__CODADaysOffset4__c FROM Account where id = :soSelected.PBSI__Customer__c]);





          /*
          c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(c2g__Account__c =  soSelected.PBSI__Customer__c,

                                                                   c2g__InvoiceDate__c = Date.Today(),
                                                                   c2g__Interval__c = 'Daily',
                                                                   Ascent2FF__Sales_Order__c=soSelected.id,
                                                                   c2g__CustomerReference__c = soSelected.Name,
                                                                   c2g__DueDate__c=Date.today()
                                                                   );
          System.debug('invoice: ' + invoice);
          System.debug('invoice.Due_DateF__c: ' + invoice.Due_DateF__c);
          System.debug('invoice.NEW_Payment_Terms_Days__c: ' + invoice.NEW_Payment_Terms_Days__c);
          //insert invoice;
          //system.debug([SELECT Due_DateF__c, NEW_Payment_Terms_Days__c, c2g__InvoiceDate__c FROM c2g__codaInvoice__c WHERE ID = :invoice.id]);
          try {
            insert invoice;
          } catch (Exception e) {
            System.debug('Error inserting invoice: ' + e);
          }
          */

          c2g__codaInvoice__c invoice = postInvoice(soSelected.PBSI__Customer__c, companyName);

          PBSI__PBSI_Item__c itemtoi = [select id,pbsi__product__c from PBSI__PBSI_Item__c where id =:item.Id];

          Pricebook2 prb=new Pricebook2(name='p');
          insert prb;
          Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];

          PricebookEntry prbe=new PricebookEntry(IsActive=true,product2id=itemtoi.pbsi__product__c,pricebook2id=pbook.id,unitprice=12,UseStandardPrice=false);
          insert prbe;

     //     try
       //   {
          // MBI 2016-04-18 CHG FROM
              //c2g__codaInvoiceLineItem__c invline = new c2g__codaInvoiceLineItem__c(c2g__Quantity__c=10,
              //                                                                      Ascent2FF__Sales_Order_Line__c=salesOrderLine.Id,
              //                                                                      c2g__Product__c=itemtoi.pbsi__product__c,
              //                                                                      c2g__Invoice__c = invoice.Id);
          // MBI 2016-04-18 CHG TO
          c2g__codaTaxCode__c taxCode = [select Id from c2g__codaTaxCode__c where c2g__TaxGroup__c = 'CH' limit 1];
          System.assertNotEquals(null, taxCode.Id, 'Tax Code could not be selected');
          c2g__codaInvoiceLineItem__c invline = new c2g__codaInvoiceLineItem__c(c2g__Quantity__c=10,
                                                                                Ascent2FF__Sales_Order_Line__c=salesOrderLine.Id,
                                                                                c2g__Product__c=itemtoi.pbsi__product__c,
                                                                                c2g__Invoice__c = invoice.Id,
                                                                                c2g__TaxCode1__c = taxCode.Id);
              //insert invline;
          // MBI 2016-04-18 CHG END
        //  }
        //  catch(Exception ex)
        //  {}
          Test.stopTest();

        }

  }

    private static c2g__codaInvoice__c postInvoice(Id customerID, String companyName) {


        /*
        User usr = new User(alias = 'standt',
            email='standarduser@testorg.com',
            emailencodingkey='UTF-8',
            lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = [SELECT id FROM Profile WHERE name = 'System Administrator'].id,
            timezonesidkey='America/Los_Angeles', c2g__APILicenseKey__c = 'c0a0c4f774b2ee7528eb56e7cd81ee35fae64f3e',
            username='uniqueUsernameForTesting@example.org');
        insert usr;
        */

        //System.runAs(usr){

            c2g.CODAAPICommon_6_0.Context ctx = new c2g.CODAAPICommon_6_0.Context();
            ctx.companyName = companyName;
            System.debug('Company Name: ' + companyName);

            c2g__codaInvoice__c invoice = new c2g__codaInvoice__c(
                c2g__Account__c = customerID,
                c2g__InvoiceDate__c = Date.today(),
                c2g__invoiceStatus__c = 'In Progress',
                c2g__DerivePeriod__c = true,
               c2g__DeriveCurrency__c = true,
                c2g__DeriveDueDate__c = true,
                c2g__CopyAccountValues__c = true
            );

            // MBI 2016-04-18 CHG FROM
            //try{
            //insert invoice;
            //}catch (Exception e) {}
            // MBI 2016-04-18 CHG TO
            insert invoice;
            // MBI 2016-04-18 CHG END

            return invoice;

            // Insert Invoice line items
            /*
            List<c2g__codaInvoiceLineItem__c> invoiceLines = new List<c2g__codaInvoiceLineItem__c>();
            invoiceLines.add(
            new c2g__codaInvoiceLineItem__c(
            c2g__Invoice__c = invoice.Id,
            c2g__Product__c = '01td0000001BIMc', //replace with one of yours!
            c2g__Quantity__c = 10));
            invoiceLines.add(
            new c2g__codaInvoiceLineItem__c(
            c2g__Invoice__c = invoice.Id,
            c2g__Product__c = '01td0000001BIMd', //replace with one of yours!
            c2g__Quantity__c = 2));
            insert invoiceLines;

            // Post the Invoice
            c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
            ref.Id = invoice.Id;

            // Post Invoices
            c2g.CODAAPISalesInvoice_6_0.PostInvoice(ctx,ref);
            */
        //}
    }
}