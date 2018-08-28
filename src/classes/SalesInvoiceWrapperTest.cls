@isTest
public class SalesInvoiceWrapperTest {
	@isTest
	static void testConstructor() {
		c2g__codaInvoice__c n = new c2g__codaInvoice__c();
		n.c2g__InvoiceDate__c = Date.today();
		n.recalculateFormulas();
		SalesInvoiceWrapper nn = new SalesInvoiceWrapper(n);
	}
}