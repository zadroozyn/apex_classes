public with sharing class AscentCustomSettings {
	
	private PBSI__Admin__c admin = PBSI__Admin__c.getOrgDefaults();
	
    public boolean getPackFromLocationsWithoutEntity() {
	    Boolean result = admin != null && admin.PBSI__Pack_from_Locations_without_Entity__c;        
    	return result;    
    }
    
    public boolean getATPWarningLevel() {
	    Boolean result = admin != null && admin.ATP_Warning_Level__c != null;         
    	return result;    
    }
    
	public boolean getPackMoreThanNeededOnSO() {
		Boolean result = admin != null && admin.PBSI__Pack_More_than_Needed_on_SO__c;        
        return result;    
     }

     public boolean getAllowPacking0QtyOrders() {
		Boolean result = admin != null && admin.PBSI__Allow_Packing_0_Qty_Orders__c; 
        return result;    
     }		 

     public boolean getForcePackingFromLocation(){
		Boolean result = admin != null && admin.PBSI__Force_Packing_From_Location__c;
        return result;    
     }		 

     public boolean getUseCost4decOnItemMaster() {
		Boolean result = admin != null && admin.PBSI__Use_Cost_4_dec_on_Item_Master__c;
        return result;    
     }		 

     public boolean getUseLandedCost() {
		Boolean result = admin != null && admin.PBSI__Use_Landed_Cost__c;
        return result;    
     }		 

     public boolean getUseInventoryCostForRecordedCost() {
		Boolean result = admin != null && admin.PBSI__Use_Inventory_Cost_for_Recorded_Cost__c;
        return result;    
     }		 
          
     public boolean getUseSOLineCostForRecordedCost() {
		Boolean result = admin != null && admin.PBSI__Use_SO_Line_Cost_for_Recorded_Cost__c;
        return result;    
     }		 

     public boolean getUseLotAverageCostForRecordedCost() {
		Boolean result = admin != null && admin.PBSI__Use_Lot_Average_Cost_for_Recorded_Cost__c;
        return result;    
     }		 

     public boolean getUseLotPurchasePriceForRecordedCost() {
		Boolean result = admin != null && admin.PBSI__Use_Lot_Purchase_Price_for_Recorded_Cost__c;
        return result;    
     }		 

     public boolean getUseDiscount2DecimalsOnSOLine() {
		Boolean result = admin != null && admin.PBSI__Use_Discount_2_decimals_on_SOLine__c;
        return result;    
     }
     
     public boolean getUseParentGroupsInTradeAgreements() {
		Boolean result = admin != null && admin.PBSI__Use_Parent_Groups_in_Trade_Agreements__c;
        return result;    
     }
     public boolean getSplitTradeAgreementsQueries() {
		Boolean result = admin != null && admin.PBSI__Split_Trade_agreements_queries__c;
        return result;    
     }

     public boolean getCheckTACurrencyForSOLinePrice() {
		Boolean result = admin != null && admin.PBSI__Check_TA_Currency_for_SO_Line_Price__c;
        return result;    
     }
     
     public boolean getIgnoreTAWhenUserOverridingPrice() {
		Boolean result = admin != null && admin.PBSI__Ignore_TA_when_user_overriding_price__c;
        return result;    
     }
     
     public Integer getAutoPackBulkQueueSize() {
		Integer result = 0;
		if (admin != null && admin.Auto_Pack_Bulk_Queue_Size__c != null)
			result = admin.Auto_Pack_Bulk_Queue_Size__c.intValue();
		if (result < 0)
			result = 0;
        return result;
     }
     
     public Integer getAutoPackBulkBatchSize() {
		Integer result = 50;
		if (admin != null && admin.Auto_Pack_Bulk_Batch_Size__c != null)
			result = admin.Auto_Pack_Bulk_Batch_Size__c.intValue();
		if (result < 1)
			result = 1;
		if (result > 200)
			result = 200;
        return result;
     }
}