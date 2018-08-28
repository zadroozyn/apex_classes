public without sharing class SalesInvoiceMethods {

	public static void invoiceSalesOrders(Set<ID> sSalesOrderIDs) {
		if (!sSalesOrderIDs.isEmpty()) {
			List<c2g.CODAAPICommon.Reference> lInvoiceReferences = Ascent2FF.InvoiceClass.createInvoice(sSalesOrderIDs);
		}
	}

	public static void recalculateSharesForPortalUsers(Map<Id, SObject> mOldSobjects, Map<Id, SObject> mNewSobjects) {
		Map<Id, c2g__codaInvoice__c> mOldInvoices = (Map<Id, c2g__codaInvoice__c>) mOldSobjects;
		Map<Id, c2g__codaInvoice__c> mNewInvoices = (Map<Id, c2g__codaInvoice__c>) mNewSobjects;
		List<Id> invoiceIdsWithChangedCustomer = getInvoiceIdsWithChangedAcc(mOldInvoices, mNewInvoices);
		if(invoiceIdsWithChangedCustomer.size() == 0) {
			return;
		}
		List<c2g__codaInvoice__c> lNewChangedInvoices = getInvoicesFromMap(invoiceIdsWithChangedCustomer, mNewInvoices);
		List<SObject> oldShares = ShareHandler.getShares(invoiceIdsWithChangedCustomer, 'c2g__codaInvoice__c', 'Portal_user_access__c');
		delete oldShares;
		BackstageShareService srv = new BackstageShareService();
		Database.insert(srv.createSharesForObjects(lNewChangedInvoices, Schema.c2g__codaInvoice__c.sObjectType));
	}

	private static List<Id> getInvoiceIdsWithChangedAcc(Map<Id, c2g__codaInvoice__c> mOldInvoices, Map<Id, c2g__codaInvoice__c> mNewInvoices) {
		List<Id> resultList = new List<Id>();
		for(Id currentId : mOldInvoices.keySet()) {
			if(mOldInvoices.get(currentId).c2g__Account__C != mNewInvoices.get(currentId).c2g__Account__C) {
				resultList.add(mNewInvoices.get(currentId).Id);
			}
		}
		return resultList;
	}

	public static void setFirstDueDate(List<c2g__codaInvoice__c> lInvoices) {
		for(c2g__codaInvoice__c invoice: lInvoices) {
			if(invoice.Due_DateF__c != null) {
				invoice.c2g__DueDate__c = invoice.Due_DateF__c;                
			}
		}
	}

	public static void copyCommentFromSO(List<c2g__codaInvoice__c> lInvoices) {
		Map<Id, List<c2g__codaInvoice__c>> mapSoId2BlankCommentsInvoices = new Map<Id, List<c2g__codaInvoice__c>>();
		for(c2g__codaInvoice__c invoice: lInvoices) {
			if(String.isBlank(invoice.Comments__c) && invoice.Ascent2FF__Sales_Order__c != null) {
				if(mapSoId2BlankCommentsInvoices.containsKey(invoice.Ascent2FF__Sales_Order__c)) {
					mapSoId2BlankCommentsInvoices.get(invoice.Ascent2FF__Sales_Order__c).add(invoice);
				} else {
					mapSoId2BlankCommentsInvoices.put(invoice.Ascent2FF__Sales_Order__c, new List<c2g__codaInvoice__c>{ invoice });
				}
			}
		}
		List<PBSI__PBSI_Sales_Order__c> lSalesOrders = [SELECT Id, PBSI__Comments__c FROM PBSI__PBSI_Sales_Order__c WHERE Id IN :mapSoId2BlankCommentsInvoices.keySet()];
		for(PBSI__PBSI_Sales_Order__c so: lSalesOrders) {
			List<c2g__codaInvoice__c> lInvoicesToFill = mapSoId2BlankCommentsInvoices.get(so.Id);
			if(lInvoicesToFill != null) {
				for(c2g__codaInvoice__c inv: lInvoices) {
					inv.Comments__c = so.PBSI__Comments__c;
				}
			}
		}
	}

	private static List<c2g__codaInvoice__c> getInvoicesFromMap(List<Id> invoiceIds, Map<Id, c2g__codaInvoice__c> mInvoices) {
		List<c2g__codaInvoice__c> resultList = new List<c2g__codaInvoice__c>();
		for(Id currentId :invoiceIds) {
			resultList.add(mInvoices.get(currentId));
		}
		return resultList;
	}
}