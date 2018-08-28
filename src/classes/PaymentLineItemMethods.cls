/**
 * Class contains methods that operates on Account object.<br>
 * Logic that is contained in this class is using i.a. in automation of invoicing functionality.
 * 
 * @version 1.0  2015.09.29  Ewa Latoszek <ewa.latoszek@nefoscdc.com>.
 *                           Initial version of class.
 */

public class PaymentLineItemMethods {
    
    /**
     * Method used to find Payable Invoice records and 
     * to update them Payment Date field according to given value.
     * 
     * @param mPayableInvoiceNameToPaymentDate Map of Payable Invoice name to Payment Date.
     * 
     */
    public static void fillPaymentDateOnPayableInvoice(List<c2g__codaPaymentLineItem__c> lPaymentLineItems) {
        Map<String, Date> mPayableInvoiceNameToPaymentDate = new Map<String, Date>();
        Map<ID, List<String>> mPaymentIDToPayableInvoiceNames = new Map<ID, List<String>>();
        
        for (c2g__codaPaymentLineItem__c record : lPaymentLineItems) {
            if (record.c2g__DocumentNumber__c != null) {
                if (!mPaymentIDToPayableInvoiceNames.containsKey(record.c2g__Payment__c)) {
                    mPaymentIDToPayableInvoiceNames.put(record.c2g__Payment__c, new List<String>());
                }
                
                mPaymentIDToPayableInvoiceNames.get(record.c2g__Payment__c).add(record.c2g__DocumentNumber__c);
            }
        }
        
        for (c2g__codaPayment__c record : [SELECT ID, c2g__PaymentDate__c FROM c2g__codaPayment__c WHERE ID IN :mPaymentIDToPayableInvoiceNames.keySet()]) {
            for (String payableInvoiceName : mPaymentIDToPayableInvoiceNames.get(record.ID)) {
                mPayableInvoiceNameToPaymentDate.put(payableInvoiceName, record.c2g__PaymentDate__c);
            }
        }
        
        if (!mPayableInvoiceNameToPaymentDate.isEmpty()) {
            PayableInvoiceMethods.fillPaymentDate(mPayableInvoiceNameToPaymentDate);   
        }
    }

}