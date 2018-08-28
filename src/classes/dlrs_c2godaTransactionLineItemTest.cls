/**
 * Cover the dlrs_c2godaTransactionLineItem trigger as the 
 * as the Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 * does not cover the code out of the box due to exceptions inserting the Transaction Line Item
 **/
@IsTest(SeeAllData=true)
private class dlrs_c2godaTransactionLineItemTest
{
    private static testmethod void testTrigger()
    {

        // Account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Och Sport AG'];
 
        // Currency
        c2g__codaAccountingCurrency__c curr = [SELECT Id From c2g__codaAccountingCurrency__c WHERE Name = 'CHF' and c2g__OwnerCompany__r.Name = 'On AG'];

        // Product with a Sales Revenue Account
        //ASCENT - limited the query returns to avoid test failures as there are multiple records matching criteria and we did not want to remove any records
        Product2 prd = [SELECT Id FROM Product2 WHERE Name = 'Bag Run on clouds' ORDER BY CreatedDate ASC LIMIT 1];
        //ASCENT - limited the query returns to avoid test failures as there are multiple records matching criteria and we did not want to remove any records

        // Create an invoice with a line
        c2g__codaInvoice__c inv = new c2g__codaInvoice__c(
            c2g__InvoiceCurrency__c = curr.Id,
            c2g__Account__c = acc.id,
            c2g__InvoiceDate__c = System.today()
        );

        insert inv;
            
        c2g__codaInvoiceLineItem__c item = new c2g__codaInvoiceLineItem__c(
            c2g__Invoice__c = inv.id,
            c2g__Product__c = prd.Id,
            c2g__Quantity__c = 1,
            c2g__UnitPrice__c = 100,
            c2g__DeriveUnitPriceFromProduct__c = false,
            c2g__LineDescription__c = 'Unit Test'
        );

        insert item;

        // post invoice
        c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
        ref.Id = inv.Id;

        // Post the invoices via the bulk api
        /*
        c2g.CODAAPISalesInvoice_6_0.BulkPostInvoice(new c2g.CODAAPICommon_6_0.Context(), new c2g.CODAAPICommon.Reference[] { ref });

        // Assert posted
        Id invId = inv.Id;
        inv = [Select Id, Name, c2g__InvoiceStatus__c from c2g__codaInvoice__c where Id = :invId];
        System.assertEquals('Complete', inv.c2g__InvoiceStatus__c);   */
        update [select Id from c2g__codaTransactionLineItem__c limit 1];
    }
}