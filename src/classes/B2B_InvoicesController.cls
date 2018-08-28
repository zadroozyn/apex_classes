public with sharing class B2B_InvoicesController extends B2BPortalPageControllerBase {

    public Account account {get; set;}

    public PortalDateWrapper filterInvoiceDateFrom {get; set;}
    public PortalDateWrapper filterInvoiceDateTo {get; set;}

    public PortalDateWrapper filterDueDateFrom {get; set;}
    public PortalDateWrapper filterDueDateTo {get; set;}

  
    public PortalDateWrapper filterCreditNoteDateFrom {get; set;}
    public PortalDateWrapper filterCreditNoteDateTo {get; set;}
 

	public List<c2g__codaInvoice__c> customerInvoices;
	public String dateFormatString {get; set;}
    public List<String> filterPaymentStatus {get; set;}
    public List<String> filterInvoicesCreditNotes {get; set;}

    public B2B_InvoicesController() {
		dateFormatString = DateFormat.getDateFormatForCurrentUser();
        setDefaultValues();
		try {
            this.account = [Select Id, Name, Owner.Name, Owner.Email, Account_Balance__c, CurrencyIsoCode From Account Where Id IN (SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId())];
        } catch(Exception e) {
			LogService log = LogService.getLogService();
			log.addError().type('Backstage').relatedObjId(UserInfo.getUserId()).info('Following user tried to open Backstage Invoices page (B2BInvoicesPayments.page), but he/she doesn\'t have AccountId');
			log.save();
		}
    }

	public List<BackstagePaymentObjectWrapper> getInvoices() {
		List<BackstagePaymentObjectWrapper> output = new List<BackstagePaymentObjectWrapper>();
		for(String box : filterInvoicesCreditNotes) {
			if(box.equals('Invoices')) {
				for(c2g__codaInvoice__c current : querySalesInvoices()) {
						output.add((BackstagePaymentObjectWrapper) new SalesInvoiceWrapper(current));
				}
			}
			if(box.equals('Credit Notes')) {
				for(c2g__codaCreditNote__c currentCredit : querySalesCreditNotes()) {
						output.add((BackstagePaymentObjectWrapper) new SalesCreditNotesWrapper(currentCredit));
				}
			}
		}
			
		return output;
	}

	private List<c2g__codaInvoice__c> querySalesInvoices() {
		 String query = 'SELECT Id,' 
			+ 'Customer_PO__c,'
			+ 'Due_DateF__c,'
			+ 'Name,'
			+ 'Sales_order_name__c,'	
			+ 'c2g__InvoiceDate__c,'
			+ 'c2g__InvoiceStatus__c,'
			+ 'c2g__InvoiceTotal__c,'
			+ 'c2g__OutstandingValue__c,'
			+ 'c2g__PaymentStatus__c,'
			+ '(SELECT Id, Name FROM Attachments WHERE ContentType = \'application/pdf\' ORDER BY CreatedDate DESC LIMIT 1)'
            + ' FROM c2g__codaInvoice__c'
			+ ' WHERE c2g__InvoiceStatus__c = \'Complete\'' 
			+ (this.filterPaymentStatus.isEmpty() ? '' : ' AND c2g__PaymentStatus__c IN (\'' + String.join(this.filterPaymentStatus, '\',\'') + '\')')
			+ (this.filterInvoiceDateFrom.dateField == null ? '' : ' AND c2g__invoiceDate__c >= ' + String.valueOf(this.filterInvoiceDateFrom.dateField))
			+ (this.filterInvoiceDateTo.dateField == null ? '' : ' AND c2g__invoiceDate__c <= ' + String.valueOf(this.filterInvoiceDateFrom.dateField))
			+ (this.filterDueDateFrom.dateField == null ? '' : ' AND Due_DateF__c >= ' + String.valueOf(this.filterDueDateFrom.dateField))
			+ (this.filterDueDateTo.dateField == null ? '' : ' AND Due_DateF__c <= ' + String.valueOf(this.filterDueDateTo.dateField))
			+ 'ORDER BY Sales_Order_Name__c DESC LIMIT 500';
			system.debug(query);
		 return Database.query(query);
	}	

		private List<c2g__codaCreditNote__c> querySalesCreditNotes() {
		 String query = 'SELECT Id,' 
			+ 'Name,'
			+ 'c2g__CreditNoteDate__c,'
			+ 'c2g__InvoiceDate__c,'
			+ 'c2g__CreditNoteStatus__c,'
			+ 'c2g__Invoice__c,'
			+ 'c2g__CreditNoteTotal__c,'
			+ 'c2g__OutstandingValue__c,'
			+ 'c2g__PaymentStatus__c,'
			+ 'c2g__Invoice__r.Customer_PO__c,'
			+ '(SELECT Id, Name FROM Attachments WHERE ContentType = \'application/pdf\' ORDER BY CreatedDate DESC LIMIT 1)'
            + ' FROM c2g__codaCreditNote__c'
			+ ' WHERE c2g__CreditNoteStatus__c = \'Complete\'' 
			+ (this.filterPaymentStatus.isEmpty() ? '' : ' AND c2g__PaymentStatus__c IN (\'' + String.join(this.filterPaymentStatus, '\',\'') + '\')')
			+ (this.filterInvoiceDateFrom.dateField == null ? '' : ' AND c2g__CreditNoteDate__c >= ' + String.valueOf(this.filterInvoiceDateFrom.dateField))
			+ (this.filterInvoiceDateTo.dateField == null ? '' : ' AND c2g__CreditNoteDate__c <= ' + String.valueOf(this.filterInvoiceDateFrom.dateField))
			+ (this.filterDueDateFrom.dateField == null ? '' : ' AND c2g__DueDate__c >= ' + String.valueOf(this.filterDueDateFrom.dateField))
			+ (this.filterDueDateTo.dateField == null ? '' : ' AND c2g__DueDate__c <= ' + String.valueOf(this.filterDueDateTo.dateField))
			+ ' ORDER BY Name DESC LIMIT 500';
			system.debug(query);
		 return Database.query(query);
	}

    public SelectOption[] getPaymentStatuses() {
        SelectOption[] options = new SelectOption[] {
            new SelectOption('Paid', Label.B2B_Invoices_Payment_Paid),
            new SelectOption('Unpaid', Label.B2B_Invoices_Payment_Unpaid),
            new SelectOption('Part Paid', Label.B2B_Invoices_Payment_Part_Paid)
        };
        return options;
    }

    public SelectOption[] getInvoiceCreditNotes() {
    	SelectOption[] options = new SelectOption[] {
    		new SelectOption('Invoices', Label.B2B_Invoices_Invoices),
    		new SelectOption('Credit Notes', Label.B2B_Invoices_Credit_Notes)
    	};
    	return options;
    }

    public void setDefaultValues() {
        filterPaymentStatus = new String[] {
            'Paid', 'Unpaid', 'Part Paid'
        };
        filterInvoicesCreditNotes = new String[] {
        	'Invoices', 'Credit Notes'
        };
        Date today = Date.today();
        filterCreditNoteDateFrom = new PortalDateWrapper(Date.newInstance(today.year(), 1, 1), this.dateFormatString);
        filterInvoiceDateFrom = new PortalDateWrapper(Date.newInstance(today.year(), 1, 1), this.dateFormatString);
        filterDueDateFrom = new PortalDateWrapper(Date.newInstance(today.year(), 1, 1), this.dateFormatString);

        filterCreditNoteDateTo = new PortalDateWrapper(Date.newInstance(today.year(), 12, 31), this.dateFormatString);
        filterInvoiceDateTo = new PortalDateWrapper(Date.newInstance(today.year(), 12, 31), this.dateFormatString);
        filterDueDateTo = new PortalDateWrapper(Date.newInstance(today.year(), 12, 31), this.dateFormatString);
    }

	public void clearFilterValues() {
		filterCreditNoteDateFrom.dateField = null;
		filterInvoiceDateFrom.dateField = null;
		filterDueDateFrom.dateField = null;
		filterCreditNoteDateTo.dateField = null;
		filterInvoiceDateTo.dateField = null;
		filterDueDateTo.dateField = null;
		filterPaymentStatus.clear();
		filterInvoicesCreditNotes.clear();
	}
}