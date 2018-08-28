public without sharing class B24SObjectFactory {

	private B24Settings b24Settings = new B24Settings();

	public B24SObjectFactory() {

	}

	public B24SObjectCreatorBase.ParentChildren salesOrder(B24MessageWrapper.OrderModel messageOrder, String messageId) {

		B24SObjectCreator soCreator = b24Settings.getOrderCreatorClass(messageOrder.getBuyerGln());
		return soCreator.createSObject(messageOrder, messageId);

	}
	
	public B24SObjectCreatorBase.ParentChildren salesReport(B24MessageWrapper.SalesReportModel messageSalesReport) {
		Sales_Report__c sReport = new Sales_Report__c(
			Status__c = 'Not Processed',
			Document_Date__c = messageSalesReport.documentDate,
			Document_Reference__c = messageSalesReport.msgRefNo,
			Period_Begin__c = messageSalesReport.periodStartDate,
			Period_End__c = messageSalesReport.periodEndDate

		);
		Account accBuyer = new Account(GLN__c = messageSalesReport.buyer);
		sReport.Account__r = accBuyer;

		List<Sales_Report_Item__c> items = new List<Sales_Report_Item__c>();
		for(B24MessageWrapper.SalesReportLineModel line: messageSalesReport.lines) {
			Sales_Report__c extKeySLSRPT = new Sales_Report__c(Document_Reference__c = sReport.Document_Reference__c);
			items.add(
				new Sales_Report_Item__c(
					Sales_Report__r = extKeySLSRPT,
					Store_Account__r = new Account(GLN__c = line.location),
					Item__r = new PBSI__PBSI_Item__c(EAN_Number__c = line.ean),
					Item_ID__c = line.itemId,
					Sales_Quantity__c = line.salesQuantity,
					Returned_Quantity__c = line.returnedQuantity,
					Net_Price__c = line.netPrice,
					Sales_Price__c = line.salesPrice
				)
			);
		}

		B24SObjectCreatorBase.ParentChildren retObj = new B24SObjectCreatorBase.ParentChildren();
		retObj.parent = sReport;
		retObj.children = items;
		return retObj;
	}

	public B24SObjectCreatorBase.ParentChildren inventoryReport(B24MessageWrapper.InventoryReportModel messageInventoryReport) {
		Inventory_Report__c invReport = new Inventory_Report__c(
			Status__c = 'Not Processed',
			Document_Date__c = messageInventoryReport.documentDate,
			Document_Reference__c = messageInventoryReport.msgRefNo

		);
		Account accBuyer = new Account(GLN__c = messageInventoryReport.buyer);
		invReport.Account__r = accBuyer;

		List<Inventory_Report_Item__c> items = new List<Inventory_Report_Item__c>();
		for(B24MessageWrapper.InventoryLineModel line: messageInventoryReport.lines) {
			Inventory_Report__c extKeyINVRPT = new Inventory_Report__c(Document_Reference__c = invReport.Document_Reference__c);
			items.add(
				new Inventory_Report_Item__c(
					Inventory_Report__r = extKeyINVRPT,
					Store_Account__r = new Account(GLN__c = line.location),
					Item__r = new PBSI__PBSI_Item__c(EAN_Number__c = line.ean),
					Quantity__c = line.quantity
				)
			);
		}

		B24SObjectCreatorBase.ParentChildren retObj = new B24SObjectCreatorBase.ParentChildren();
		retObj.parent = invReport;
		retObj.children = items;
		return retObj;
	}

}