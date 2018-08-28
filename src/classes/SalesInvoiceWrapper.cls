public class SalesInvoiceWrapper implements BackstagePaymentObjectWrapper {
	public Decimal outstanding {get; set;}
	public Decimal total {get; set;}
	public Id attachmentId {get; set;}
	public String attachmentName {get; set;}
	public String customerPO {get; set;}
	public String dueDate {get; set;}
	public String invoiceDate {get; set;}
	public String name {get; set;}
	public String soName {get; set;}

	public SalesInvoiceWrapper(c2g__codaInvoice__c source) {
		outstanding = source.c2g__OutstandingValue__c;
		total = source.c2g__InvoiceTotal__c;
		if(source.attachments.size() > 0 && source.c2g__InvoiceStatus__c == 'Complete') {
			attachmentId = source.attachments[0].Id;
			attachmentName = source.attachments[0].Name;
		}
		customerPO = source.Customer_PO__c;
		if(source.Due_DateF__c != null) {
			dueDate = source.Due_DateF__c.format();
		}
		if(source.c2g__InvoiceDate__c != null) {
			invoiceDate = source.c2g__InvoiceDate__c.format();
		}
		name = source.Name;
		soName = source.Sales_order_name__c;
	}

	public Decimal getOutstanding() {
		return outstanding;
	}

	public Decimal getTotal() {
		return total;
	}

	public Id getAttachmentId() {
		return attachmentId;
	}

	public String getAttachmentName() {
		return AttachmentName;
	}

	public String getCustomerPO() {
		return customerPO;
	}

 	public String getDueDate() {
 		return dueDate;
 	}

 	public String getInvoiceDate() {
 		return invoiceDate;
 	}

 	public String getName() {
 		return name;
 	}

 	 public String getSoName() {
 	 	return soName;
 	 }
}