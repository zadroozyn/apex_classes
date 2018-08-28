public class SalesInvoiceLineItemService {

	public void setInitialFieldValues(List<c2g__codaInvoiceLineItem__c> lines) {
		DataHelper dh = new DataHelper(lines);
		for(c2g__codaInvoiceLineItem__c current : lines) {
			c2g__codaInvoice__c parent = dh.invoices.get(current.c2g__invoice__c);

			current.c2g__Dimension2__c = parent.c2g__Account__r.c2g__CODADimension2__c;
			current.Is_Shipping__c = current.Products_FF_Posting_Type__c == 'shipping';
			current.c2g__TaxCode1__c = parent.c2g__Account__r.c2g__codaOutputVatCode__c;

			if (dh.rates.containsKey(current.c2g__TaxCode1__c)) {
				current.c2g__TaxRate1__c = dh.rates.get(current.c2g__TaxCode1__c);
				current.c2g__TaxValue1__c = ((current.c2g__UnitPrice__c * current.c2g__TaxRate1__c * current.c2g__Quantity__c) / 100).setScale(2);
			}

			if(RecordTypeService.getRecordTypeIdByDeveloperName('PBSI__PBSI_Sales_Order__c', 'web_order') == parent.Ascent2FF__Sales_Order__r.RecordTypeId){
				current.c2g__Dimension1__c = dh.country2Dim1Id.get('Webshop');
			} else if(dh.country2Dim1Id.containsKey(parent.Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c)) {
				current.c2g__Dimension1__c = dh.country2Dim1Id.get(parent.Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c);
			} else { 
				current.c2g__Dimension1__c = dh.country2Dim1Id.get('Other');
			}

			if (dh.invoicedLines.containsKey(current.Ascent2FF__Invoiced_Line__c)){
				current.Ascent2FF__Sales_Order_Line__c = dh.invoicedLines.get(current.Ascent2FF__Invoiced_Line__c).PBSI__Sales_Order_Line__c;
			}
		}
	}

	private class DataHelper {

		Set<Id> invoiceIds;
		Set<Id> invoicedLineIds;
		Set<String> countries;
		Set<Id> vatCodes;

		Map<Id, c2g__codaInvoice__c> invoices;
		Map<Id, Double> rates;
		Map<String, Id> country2Dim1Id;
		Map<Id, PBSI__Invoiced_Line__c> invoicedLines;

		private DataHelper(List<c2g__codaInvoiceLineItem__c> input) {
			this.invoiceIds = new Set<Id>();
			this.invoicedLineIds = new Set<Id>();
			processLineItems(input);
			queryInvoices();
			this.countries = new Set<String> {'Webshop', 'Other'};
			this.vatCodes = new Set<Id>();
			processInvoices();
			this.rates = new Map<Id, Double>();
			populateRates();
			this.country2Dim1Id = new Map<String, Id>();
			populateCountry2Dim1IdMap();
			this.invoicedLines = new Map<Id, PBSI__Invoiced_Line__c>();
			queryInvoicedLines();
		}

		private void processLineItems(List<c2g__codaInvoiceLineItem__c> input) {
			for(c2g__codaInvoiceLineItem__c current : input) {
				invoiceIds.add(current.c2g__Invoice__c);
				invoicedLineIds.add(current.Ascent2FF__Invoiced_Line__c);
			}
			invoiceIds.remove(null);
			invoicedLineIds.remove(null);
		}

		private void queryInvoices() {
			this.invoices = new Map<Id, c2g__codaInvoice__c>([SELECT 
					Id, 
					c2g__Account__r.c2g__CODAOutputVATCode__c, 
					c2g__Account__r.c2g__CODADimension2__c, 
					Ascent2FF__Sales_Order__r.RecordType.DeveloperName, 
					Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c
					FROM c2g__codaInvoice__c
					WHERE id IN :this.invoiceIds
			]);
		}

		private void processInvoices() {
			for(c2g__codaInvoice__c current : this.invoices.values()) {
				this.countries.add(current.Ascent2FF__Sales_Order__r.PBSI__BillingCountry__c);
				this.vatCodes.add(current.c2g__Account__r.c2g__CODAOutputVATCode__c);
			}
			this.countries.remove(null);
			this.vatCodes.remove(null);
		}

		private void populateRates() {
			if(this.vatCodes.isEmpty()) {
				return;
			}
			List<c2g__codaTaxRate__c> lTaxRates = [SELECT 
				Id, 
				c2g__Rate__c, 
				c2g__TaxCode__c
					FROM c2g__codaTaxRate__c
					WHERE c2g__TaxCode__c IN :this.vatCodes
					AND c2g__StartDate__c <= :system.today() ORDER BY c2g__StartDate__c DESC];
			for (c2g__codaTaxRate__c current : lTaxRates) {
				if(!rates.containsKey(current.c2g__TaxCode__c)) {
					rates.put(current.c2g__TaxCode__c, current.c2g__Rate__c);
				}
			}
		}

		private void populateCountry2Dim1IdMap() {
			if(!this.countries.isEmpty()) {
				for (c2g__codaDimension1__c current : [SELECT Id, Name FROM c2g__codaDimension1__c WHERE Name IN :this.countries]){
					this.country2Dim1Id.put(current.name, current.Id);
				}
			}
		}

		private void queryInvoicedLines() {
			if(!this.invoicedLineIds.isEmpty()) {
				this.invoicedLines.putAll([SELECT Id, pbsi__sales_order_line__c FROM PBSI__Invoiced_Line__c WHERE id IN :this.invoicedLineIds]);
			}
		}
	}
}