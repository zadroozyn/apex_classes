public with sharing class SalesCreditNotesWrapper implements BackstagePaymentObjectWrapper {
	
	public Decimal outstanding {get; set;}
	public Decimal total {get; set;}
	public Id attachmentId {get; set;}
	public String attachmentName {get; set;}
	public String  invoiceDate {get; set;}
	public String name {get; set;}
	public String customerPO {get; set;}
	

	public SalesCreditNotesWrapper(c2g__codaCreditNote__c source) {
			outstanding = source.c2g__OutstandingValue__c;
			total = source.c2g__CreditNoteTotal__c;
			customerPO = source.c2g__Invoice__r.Customer_PO__c;

			if(source.c2g__invoiceDate__c != null) {
				invoiceDate = source.c2g__invoiceDate__c.format();
			}

			if(source.attachments.size() > 0 && source.c2g__CreditNoteStatus__c == 'Complete') {
				attachmentId = source.attachments[0].Id;
				attachmentName = source.attachments[0].Name;
			}

			name = source.Name;
			
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
 		return '';
 	}

 	public String getInvoiceDate() {
 		return invoiceDate;
 	}

 	public String getName() {
 		return name;
 	}

 	 public String getSoName() {
 	 	return '';
 	 }

}