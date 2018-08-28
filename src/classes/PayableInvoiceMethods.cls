/**
 * Class contains methods that operates on Account object.<br>
 * Logic that is contained in this class is using i.a. in automation of invoicing functionality.
 * 
 * @version 2.0  2015.09.29  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Added fillPaymentDate(Map<String, Date>) method.
 * @version 1.0  2015.09.15  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 */
 
public without sharing class PayableInvoiceMethods {
    
    /**
     * ID prefix of Payable Invoice.
     */
    private static final String PAYABLE_INVOICE_ID_PREFIX = 'a3E';

    /**
     * Method used to fill Invoice Document ID field of Payable Invoice with ID of given attachment.
     * Method is called from AttachmentTriggerHandler.afterInsert(Map<ID, SObject>) method.
     * 
     * @param lAttachemnts List of new Attachments.
     * 
     */
    public static void fillNewInvoiceDocumentID(List<Attachment> lAttachemnts) {
        List<c2g__codaPurchaseInvoice__c> lPayableInvoicesToUpdate = new List<c2g__codaPurchaseInvoice__c>();

        for (Attachment record : lAttachemnts) {
            if (((String) record.ParentID).startsWith(PayableInvoiceMethods.PAYABLE_INVOICE_ID_PREFIX)) {
                lPayableInvoicesToUpdate.add(new c2g__codaPurchaseInvoice__c(ID = record.ParentID, Invoice_Document_ID__c = record.ID));
            }
        }

        update lPayableInvoicesToUpdate;
    }

    /**
     * Method used to fill Invoice Document ID field of Payable Invoice with ID of last attachment.
     * Method is called from AttachmentTriggerHandler.afterDelete(Map<ID, SObject>) method.
     * 
     * @param lAttachemnts List of new Attachments.
     * 
     */
    public static void changeInvoiceDocumentID(List<Attachment> lAttachemnts) {
        Set<ID> sPayableInvoiceIDs = new Set<ID>();
        Set<ID> sPayableInvoiceIDsThatHasAttachment = new Set<ID>();
        List<c2g__codaPurchaseInvoice__c> lPayableInvoicesToUpdate = new List<c2g__codaPurchaseInvoice__c>();

        for (Attachment record : lAttachemnts) {
            if (((String) record.ParentID).startsWith(PayableInvoiceMethods.PAYABLE_INVOICE_ID_PREFIX)) {
                sPayableInvoiceIDs.add(record.ParentID);
            }
        }

        for (Attachment record : [SELECT ID, ParentID, CreatedDate FROM Attachment WHERE ParentID IN :sPayableInvoiceIDs ORDER BY CreatedDate DESC]) {
            if (!sPayableInvoiceIDsThatHasAttachment.contains(record.ParentID)) {
                lPayableInvoicesToUpdate.add(new c2g__codaPurchaseInvoice__c(ID = record.ParentID, Invoice_Document_ID__c = record.ID));
                sPayableInvoiceIDsThatHasAttachment.add(record.ParentID);
            }
        }

        for (ID recordID : sPayableInvoiceIDs) {
            if (!sPayableInvoiceIDsThatHasAttachment.contains(recordID)) {
                lPayableInvoicesToUpdate.add(new c2g__codaPurchaseInvoice__c(ID = recordID, Invoice_Document_ID__c = ''));
            }
        }

        update lPayableInvoicesToUpdate;
    }
    
    /**
     * Method used to find Payable Invoice records and 
     * to update them Payment Date field according to given value.
     * 
     * @param mPayableInvoiceNameToPaymentDate Map of Payable Invoice name to Payment Date.
     * 
     */
    public static void fillPaymentDate(Map<String, Date> mPayableInvoiceNameToPaymentDate) {
        List<c2g__codaPurchaseInvoice__c> lPayableInvoicesToUpdate = new List<c2g__codaPurchaseInvoice__c>();
        
        for (c2g__codaPurchaseInvoice__c record : [SELECT ID, Name, Payment_Date__c FROM c2g__codaPurchaseInvoice__c WHERE Name IN :mPayableInvoiceNameToPaymentDate.keySet()]) {
            if (mPayableInvoiceNameToPaymentDate.containsKey(record.Name)) {
                record.Payment_Date__c = mPayableInvoiceNameToPaymentDate.get(record.Name);
                lPayableInvoicesToUpdate.add(record);
            }
        }
        
        if (!lPayableInvoicesToUpdate.isEmpty()) {
            update lPayableInvoicesToUpdate;
        }
    }

	public static void preventRejectionWithoutComment(Map<Id,c2g__codaPurchaseInvoice__c> oldMap, Map<Id,c2g__codaPurchaseInvoice__c> newMap){
		sObjectMethods.preventApprovalStep(oldMap, newMap, 'Approval_status__c', 'Rejected', System.Label.Pins_Rejection_Error_No_Comment);
	}


    public static void validateESRNumber(List<c2g__codaPurchaseInvoice__c> lInvoices) {
        for(c2g__codaPurchaseInvoice__c invoice: lInvoices) {
            if(invoice.ESR_Validation_Required__c) {
                validateESRNumberSingleRecord(invoice);
            }
        }
    }

    public static void validateESRNumber(Map<Id,SObject> mapInvoicesOld, Map<Id,SObject> mapInvoicesNew) {
        for(Id key: mapInvoicesOld.keySet()) {
            c2g__codaPurchaseInvoice__c invoiceOld = (c2g__codaPurchaseInvoice__c) mapInvoicesOld.get(key);
            c2g__codaPurchaseInvoice__c invoiceNew = (c2g__codaPurchaseInvoice__c) mapInvoicesNew.get(key);
            Boolean bankNumberChangeNotEmpty = !String.isBlank(invoiceNew.Recipient_Bank_Number__c) && 
                                            invoiceOld.Recipient_Bank_Number__c != invoiceNew.Recipient_Bank_Number__c;
            if(bankNumberChangeNotEmpty && invoiceNew.ESR_Validation_Required__c) {
                validateESRNumberSingleRecord(invoiceNew);
            }
        }
    }

    private static void validateESRNumberSingleRecord(c2g__codaPurchaseInvoice__c invoice) {
        String fullNumber = invoice.Recipient_Bank_Number__c.replace('\'','');
        if(!fullNumber.isNumeric() || !module10ESR.isValid(fullNumber)) {
            invoice.addError(Label.ESR_not_valid+' '+invoice.Recipient_Bank_Number__c);
        }
    }

    private static RecursiveModule10 module10ESR {
        get {
            if(module10ESR == null) {
                module10ESR = new RecursiveModule10();
            }
            return module10ESR;
        }
        set;
    }

    public class RecursiveModule10 {
        private Integer[] table;

        public RecursiveModule10() {
            table = new List<Integer>{0, 9, 4, 6, 8, 2, 7, 1, 3, 5};
        }

        public Boolean isValid(String fullNumber) {
            return fullNumber.right(1) == generateLastDigit(getNumberWithoutLastDigit(fullNumber));
        }

        private String generateLastDigit(String baseNumber) {
            Integer uebertrag = 0;
            for (Integer i = 0; i < baseNumber.length(); i++) {
                Integer c = Integer.valueOf((baseNumber.substring(i, i + 1)));
                Integer index = Math.mod((uebertrag + c),10);
                uebertrag = table[index];
            }
            return String.valueOf(Math.mod(10 - uebertrag,10));
        }

        private String getNumberWithoutLastDigit(String fullNumber) {
            return fullNumber.substring(0,fullNumber.length()-1);
        }

    }

}