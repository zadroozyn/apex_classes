public with sharing class BatchPackSOLines implements Database.Batchable<SObject>, Database.Stateful {
    	
	private Integer procLineCount = 0;
	private Set<Id> soLinesIdSet = new Set<Id>();
	private Map<Id, List<PBSI__PBSI_Sales_Order_Line__c>> deferedLineItemsMap = new Map<Id, List<PBSI__PBSI_Sales_Order_Line__c>>();
	private AscentCustomSettings ascentCS = new AscentCustomSettings();
	
	public BatchPackSOLines(Set<String> soLineIds) {
		for (String soLineId : soLineIds) {
			soLinesIdSet.add(soLineId);
		}
	}
    
	public List<PBSI__PBSI_Sales_Order_Line__c> start(Database.BatchableContext bcMain)  {
		return (List<PBSI__PBSI_Sales_Order_Line__c>)Database.query(prepareSOLinesQuery());
	}
	
	public void execute(Database.BatchableContext bcMain, List<PBSI__PBSI_Sales_Order_Line__c> soLinesToPack) {
		List<PBSI__PBSI_Sales_Order_Line__c> packLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		List<PBSI__PBSI_Sales_Order_Line__c> deferLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
		Map<Id, PBSI__PBSI_Sales_Order_Line__c> lineItemsMap = new Map<Id, PBSI__PBSI_Sales_Order_Line__c>();
		
		for (PBSI__PBSI_Sales_Order_Line__c soLine : soLinesToPack) {
			if (!lineItemsMap.containsKey(soLine.PBSI__Item__c)) {
				lineItemsMap.put(soLine.PBSI__Item__c, soLine);
				packLines.add(soLine);
			} else {
				deferLines.add(soLine);
			}
		}
		
    	Integer batchSize = ascentCS.getAutoPackBulkBatchSize();
		for (Id itId : deferedLineItemsMap.keySet()) {
			if (!lineItemsMap.containsKey(itId) && packLines.size() < batchSize) {
				List<PBSI__PBSI_Sales_Order_Line__c> itLines = deferedLineItemsMap.get(itId);
				if (itLines != null && itLines.size() > 0) {
					PBSI__PBSI_Sales_Order_Line__c addLine = itLines.remove(0);
					lineItemsMap.put(addLine.PBSI__Item__c, addLine);
					packLines.add(addLine);
				}
			}
		}
		
		for (PBSI__PBSI_Sales_Order_Line__c defLine : deferLines) {
			List<PBSI__PBSI_Sales_Order_Line__c> defLines;
			if (deferedLineItemsMap.containsKey(defLine.PBSI__Item__c)) {
				defLines = deferedLineItemsMap.get(defLine.PBSI__Item__c);
			} else {
				defLines = new List<PBSI__PBSI_Sales_Order_Line__c>();
				deferedLineItemsMap.put(defLine.PBSI__Item__c, defLines);
			}
			defLines.add(defLine);
		}
		
		BatchPackSOLinesHelper helperInstance = new BatchPackSOLinesHelper();
		helperInstance.PackLines(packLines);
		procLineCount += packLines.size();
	}
	
	public void finish(Database.BatchableContext bcMain) {
		Set<String> deferedSoLinesIdSet = new Set<String>();
		for (Id defId : deferedLineItemsMap.keySet()) {
			List<PBSI__PBSI_Sales_Order_Line__c> defLns = deferedLineItemsMap.get(defId);
			if (defLns != null) {
				for (PBSI__PBSI_Sales_Order_Line__c defLn : defLns) {
					deferedSoLinesIdSet.add(defLn.Id);
				}
			}
		}
		
		if (deferedSoLinesIdSet.size() > 0) {
    		Integer batchSize = ascentCS.getAutoPackBulkBatchSize();
		    BatchPackSOLines bpsolines = new BatchPackSOLines(deferedSoLinesIdSet);
		    Database.executeBatch(bpsolines, batchSize);
		}
		
		AsyncApexJob aaJob = 
			[SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
				FROM AsyncApexJob 
				WHERE Id = :bcMain.getJobId()];
		
		try {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[] {aaJob.CreatedBy.Email});
	        mail.setSenderDisplayName('On SF Bulk Auto Pack');
	        mail.setSubject('Partial Bulk Pack Batch Status ' + aaJob.Status);
	 		mail.setPlainTextBody('Batch apex job processed ' + procLineCount + ' sales order lines');
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	} catch (Exception ex) {
    		system.debug(ex);
    	}
	}
	
	private String prepareSOLinesQuery() {
		Set<String> queryFields = new Set<string>();
		for(Schema.FieldSetMember f : Schema.SObjectType.PBSI__PBSI_Sales_Order_Line__c.FieldSets.pbsi__packso_open_lines.getFields())
			queryFields.add(f.getFieldPath());
		
		List<String> otherFields = new List<String> {
			'PBSI__Total_Unit_Qty_Shipped__c','PBSI__Total_Unit_Qty_Needed__c','pbsi__sales_order__r.PBSI__staging_location__c',
			'PBSI__Sales_Order__r.PBSI__Customer_Purchase_Order__c','PBSI__Sales_Order__r.PBSI__Customer__c','PBSI__Quantity__c',
			'PBSI__Quantity_Left_To_Ship__c','PBSI__Sales_Order__r.PBSI__From_Location__c','PBSI__Discount1__c','PBSI__price__c',
			'PBSI__price4__c','PBSI__discount__C','PBSI__Invoice__c','PBSI__Vendor__c','PBSI__Item_Description_Long__c',
			'PBSI__ItemDescription__c','PBSI__Ship_Lot__c','CreatedDate','PBSI__Line_Number__c','PBSI__Item__r.PBSI__Cost4__c',
			'PBSI__Item__c','PBSI__Bom_Type__c','PBSI__Item__r.PBSI__description__c','PBSI__Item__r.PBSI__Is_Service__c',
			'PBSI__Discount_Amount__c','PBSI__Item__r.PBSI__Default_Location__c','PBSI__Item__r.Name','PBSI__Lot__c',
			'PBSI__Item__r.PBSI__defaultunitofmeasure__c','PBSI__Item__r.PBSI__Quantity_on_Hand__c','PBSI__Quantity_Needed__c',
			'PBSI__Quantity_Picked__c' ,'PBSI__Sales_Order__c','PBSI__Location__c','PBSI__Location__r.Name','PBSI__Sales_Order__r.PBSI__Entity__c',
			'PBSI__Stage_Quantity__c','PBSI__Item__r.PBSI__Is_Serialized__c','PBSI__Serial_Number__c,PBSI__Line_Status__c',
			'PBSI__Sales_Order__r.Sales_Order_Type__c','pbsi__RMA_Line__c','PBSI__Item__r.PBSI__Configurable__c',
			'PBSI__hasInstructions__c','PBSI__Item__r.PBSI__Not_Count_In_Inventory__c','PBSI__Item__r.PBSI__Cost__c',
			'PBSI__Item__r.PBSI__Allow_for_Drop_Ship__c','PBSI__Item__r.PBSI__Default_Vendor__c','PBSI__Sales_Order__r.PBSI__Movement_Journal__c',
			'PBSI__Item__r.PBSI__Quantity_on_Hand__c','PBSI__Unit_of_Measure__r.PBSI__Quantity__c','PBSI__Unit_Of_Measure__c',
			'PBSI__Area__c','PBSI__Carton__c','PBSI__Item_Cost__c','PBSI__Exchange_Rate__c','PBSI__Estimated_Ship_Date__c' };
		queryFields.addAll(otherFields);
		if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)
			queryFields.add('CurrencyIsoCode');
		
        List<String> queryFieldsList = new List<String>(queryFields);
        String concatFields = String.join(queryFieldsList, ',');
        String queryString = 'SELECT ';
        queryString += String.escapeSingleQuotes(concatFields);
		queryString += ' FROM PBSI__PBSI_Sales_Order_Line__c WHERE Id IN ';
		queryString += CommonUtils.fn_getStringIds(soLinesIdSet);
        queryString += ' ORDER BY CreatedDate';
        
        return queryString;
	}
}