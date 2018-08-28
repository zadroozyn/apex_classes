public without sharing class SalesCreditNotesTriggerHandler extends TriggerHandler {
		
	private static SalesCreditNotesTriggerHandler instance;
	private boolean isTest = false;

	private SalesCreditNotesTriggerHandler () {}

	public  static SalesCreditNotesTriggerHandler getInstance () {
		if(instance == null) {
			SalesCreditNotesTriggerHandler.instance = new SalesCreditNotesTriggerHandler();
		}
		return instance;
	}

	protected override void handleAfterInsert () {
		BackstageShareService srv = new BackstageShareService();
		insert srv.createSharesForObjects(Trigger.new, Schema.c2g__codaCreditNote__c.sObjectType);
	}

	protected override void handleAfterUpdate () {
		SalesCreditNotesMethods.recalculateSharesForPortalUsers(Trigger.oldMap, Trigger.newMap);
		createPdf(Trigger.oldMap, Trigger.newMap);	
	}


	public static void createPdf(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
		Map<Id, String> recordsToGeneratePdfs = new Map<Id, String>();
		for(Id creditNoteId : newMap.keySet()) {
			c2g__codaCreditNote__c oldRecord = (c2g__codaCreditNote__c) oldMap.get(creditNoteId);
			c2g__codaCreditNote__c newRecord = (c2g__codaCreditNote__c) newMap.get(creditNoteId);
			system.debug('credit note status' + newRecord.c2g__CreditNoteStatus__c);
			if(oldRecord.c2g__CreditNoteStatus__c != newRecord.c2g__CreditNoteStatus__c && newRecord.c2g__CreditNoteStatus__c == 'Complete') {
				recordsToGeneratePdfs.put(creditNoteId, 'On Credit Note - ' + newRecord.AccountName__c + ' - ' + newRecord.Name + '.pdf');
			}
			
		}
		if(!recordsToGeneratePdfs.isEmpty()) {
			generatePdf(recordsToGeneratePdfs);
		}
	}

	@future(callout=true)
	public static void generatePdf(Map<Id, String> recordsToGeneratePdfs) {
		List<Attachment> attachList = new List<Attachment>();
		for(Id creditNoteId : recordsToGeneratePdfs.keySet()) {
			Attachment attach = new Attachment();
			PageReference pdf = new PageReference('/apex/c2g__codasalescreditnoteprint?id=' + creditNoteId);
			if(Test.isRunningTest()) {
				attach.Body = Blob.valueOf('');
			} else {
		  		attach.Body = pdf.getContentAsPDF();
			}

			attach.Name =  recordsToGeneratePdfs.get(creditNoteId);
			attach.ParentId = creditNoteId;
			attach.ContentType = 'application/pdf';	
			
			attachList.add(attach);
			
		}
		insert attachList;
	}
}