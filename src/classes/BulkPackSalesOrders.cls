public with sharing class BulkPackSalesOrders {
	
	public class BulkPackException extends Exception {}
	
	private Set<Id> soIdSet = new Set<Id>();
	private Map<Id, PBSI__PBSI_Sales_Order__c> salesOrdersMap;
	private List<PBSI__PBSI_Sales_Order_Line__c> salesOrderLinesList;
	private AscentCustomSettings ascentCS = new AscentCustomSettings();
    
    public BulkPackSalesOrders(List<String> soIds) {
		for (String soId : soIds) {
			soIdSet.add(soId);
		}
    }
    
    public void BulkPack() {
    	salesOrdersMap = querySalesOrders();
    	salesOrderLinesList = querySalesOrderLines();
    	
    	try {
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
	        mail.setSenderDisplayName('On SF Bulk Auto Pack');
	        mail.setSubject('Bulk Pack Sales Order Lines Batch Request');
	 		mail.setPlainTextBody('Trying to process ' + salesOrderLinesList.size() + ' sales order lines');
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	} catch (Exception ex) {
    		system.debug(ex);
    	}
    	
        Map<Id, PBSI__PBSI_Sales_Order_Line__c> lineSoIdsMap = new Map<Id, PBSI__PBSI_Sales_Order_Line__c>();
       	for (PBSI__PBSI_Sales_Order_Line__c line : salesOrderLinesList) {
       		if (!lineSoIdsMap.containsKey(line.PBSI__Sales_Order__c)) {
       			lineSoIdsMap.put(line.PBSI__Sales_Order__c, line);
       		}
       	}
       	Map<Id, PBSI__PBSI_Sales_Order__c> newSalesOrdersMap = new Map<Id, PBSI__PBSI_Sales_Order__c>();
       	for (Id soid : salesOrdersMap.keySet()) {
       		if (lineSoIdsMap.containsKey(soid)) {
       			newSalesOrdersMap.put(soid, salesOrdersMap.get(soid));
       		}
       	}
       	salesOrdersMap = newSalesOrdersMap;
       	
    	if (salesOrdersMap.size() > 0) {
    		SoqlServiceUtils.SetMJournalOnSalesOrders(salesOrdersMap.values(), 200, 'Goods Issue for Sale - Stock Item');
    	} else {
    		throw new BulkPackException('No Sales Order Lines to pack for this request');
    	}
    	
    	Integer queueSize = ascentCS.getAutoPackBulkQueueSize();
    	Integer batchSize = ascentCS.getAutoPackBulkBatchSize();
    	List<String> soLineIds = new List<String>();
    	for (PBSI__PBSI_Sales_Order_Line__c soLine : salesOrderLinesList) {
    		soLineIds.add(soLine.Id);
    	}
    	
    	if (soLineIds.size() > 0) {
    		if (queueSize <= 0 || queueSize >= soLineIds.size()) {
    			Set<String> soLineIdsSet = new Set<String>(soLineIds);
	    		BatchPackSOLines bpsols = new BatchPackSOLines(soLineIdsSet);
	    		Database.executeBatch(bpsols, batchSize);
	    		
    		} else {
    			Integer batchCount = 0;
    			List<String> allSoLineIds = new List<String>(soLineIds);
    			
    			do {
    				if(allSoLineIds.size() == 0) {
    					break;
    				}
    				
    				++batchCount;
    				Set<String> queueLineIds = new Set<String>();
    				
    				while (queueLineIds.size() < queueSize) {
    					if (allSoLineIds.size() > 0) {
    						queueLineIds.add(allSoLineIds.remove(0));
    					} else {
    						break;
    					}
    				}
    				
    				if (queueLineIds.size() > 0) {
    					BatchPackSOLines bpsols = new BatchPackSOLines(queueLineIds);
	    				Database.executeBatch(bpsols, batchSize);
    				}
    				
    			} while (batchCount < 4);
    			
    			if (allSoLineIds.size() > 0) {
    				Set<String> remainingLineIds = new Set<String>(allSoLineIds);
    				BatchPackSOLines bpsols = new BatchPackSOLines(remainingLineIds);
	    			Database.executeBatch(bpsols, batchSize);
    			}
    		}
    	}
    }
    
    private Map<Id, PBSI__PBSI_Sales_Order__c> querySalesOrders() {
		String soQuery = 'SELECT PBSI__Staging_Movement_Journal__c, PBSI__BillingCity__c, PBSI__BillingStreet__c, PBSI__BillingZip__c, ' +
			'PBSI__BillingCompany__c, PBSI__BillingState__c, PBSI__BillingCountry__c, PBSI__From_Location__c, ' +
			'Id, PBSI__hasMJ__c, PBSI__Movement_Journal__c, Name, PBSI__Status__c, PBSI__Ship_Location__c, ' +
			'PBSI__Order_Date__c, PBSI__Delivery_Street__c, PBSI__Delivery_City__c, PBSI__Contact_Email__c, ' +
			'PBSI__Customer__c, PBSI__Delivery_State__c, PBSI__Delivery_Postal_Code__c, PBSI__Delivery_Country__c, ' +
			'PBSI__Contact__c, PBSI__Due_Date__c, PBSI__Mode_of_Delivery__c, PBSI__Shipping_Instructions__c, ' +
			'PBSI__Delivery_Streetnew__c, PBSI__Delivery_ATTN_to__c, PBSI__Delivery_ATTN_to_Phone__c, ' +
			'PBSI__Delivery_Company__c, PBSI__Delivery_Address_line2__c, PBSI__Delivery_Address_line_3__c';
			
		if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)
			soQuery += ', CurrencyIsoCode';
			
		soQuery += ' FROM PBSI__PBSI_Sales_Order__c WHERE Id IN ';
		soQuery += CommonUtils.fn_getStringIds(soIdSet);
		soQuery += ' AND PBSI__Status__c != \'closed\'';
		soQuery += ' AND PBSI__Status__c != \'Cancelled\'';
		soQuery += ' FOR UPDATE';
		
		return new Map<Id, PBSI__PBSI_Sales_Order__c>((List<PBSI__PBSI_Sales_Order__c>)Database.query(soQuery));
    }
    
    private List<PBSI__PBSI_Sales_Order_Line__c> querySalesOrderLines() {
        String soQuery = 'SELECT Id, PBSI__Item__c, PBSI__Sales_Order__c';
		soQuery += ' FROM PBSI__PBSI_Sales_Order_Line__c WHERE PBSI__Sales_Order__c IN ';
		soQuery += CommonUtils.fn_getStringIds(salesOrdersMap.keySet());
		soQuery += ' AND PBSI__TransactionType__c = \'sale\'';
        if (ascentCS.getPackMoreThanNeededOnSO()) {
          	if (!ascentCS.getAllowPacking0QtyOrders()) {                
           		soQuery += ' AND PBSI__Quantity_Needed__c <> 0';
          	} else {              
           		if (ascentCS.getAllowPacking0QtyOrders()) {                 
           			soQuery += ' AND ( PBSI__Quantity_Needed__c = 0 OR ( PBSI__Line_Status__c = \'Open\' AND PBSI__Quantity_Left_To_Ship__c <> 0)) ';
           		}
           	}
        } else {                 
        	soQuery += ' AND PBSI__Line_Status__c = \'Open\' AND PBSI__Quantity_Left_To_Ship__c <> 0 AND PBSI__Quantity_Needed__c <> 0 AND PBSI__Item__c <> null';
        }
        soQuery += ' ORDER BY PBSI__Sales_Order__c';
 		return (List<PBSI__PBSI_Sales_Order_Line__c>)Database.query(soQuery);
    }
}