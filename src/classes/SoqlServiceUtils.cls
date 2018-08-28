public with sharing class SoqlServiceUtils {
	
	public static void SetMJournalOnSalesOrders(List<PBSI__PBSI_Sales_Order__c> salesOrders, Integer mjIntType, String mjStrType) {
        Map<String, PBSI__Movement_Journal__c>  mjToInsert =  new Map<string,PBSI__Movement_Journal__c>();
		
		for (PBSI__PBSI_Sales_Order__c so : salesOrders) {
			if (so.PBSI__Movement_Journal__c == null ) {
				PBSI__Movement_Journal__c movementJournal = new PBSI__Movement_Journal__c();
				
				movementJournal.PBSI__Movement_Type__c = mjIntType; //200;
				movementJournal.PBSI__Reference_Number__c = so.Name;
				
				if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)
					movementJournal.put('CurrencyIsoCode',so.get('CurrencyIsoCode'));
				
				movementJournal.PBSI__Type__c = mjStrType; //'Goods Issue for Sale - Stock Item';
				movementJournal.PBSI__Reference_Type__c = 'Sales Order';
				mjToInsert.put(so.Name, movementJournal);         
			}
		}
		
		if (mjToInsert.size() > 0) {
			try {
				insert mjToInsert.values();
				
				List<PBSI__PBSI_Sales_Order__c> soToUpdate = new List<PBSI__PBSI_Sales_Order__c>();
				
				for (PBSI__PBSI_Sales_Order__c so : salesOrders) {
					if (mjToInsert.containskey(so.Name)) {
						so.PBSI__hasMJ__c = 1;
						so.PBSI__Movement_Journal__c = mjToInsert.get(so.Name).Id;
						soToUpdate.add(so);
					}
				}
				
				update soToUpdate;
				
			} catch(Exception e) {
				system.debug(e.getMessage());
			}
		}       
	}
	
	public static PBSI__Movement_Line__c CreateMovementLine(Id mjID,
															Id itemid, 
															Id fromlotid,
															Id frompalletid,
															String fromarea,
															String fromcarton,                                                            
															Id tolotid,
															Id topalletid,
															String toarea,
															String tocarton,
															Id shiplineid,
															Id reclineid,
															Id stagelineid, 
															Id rmalineid, 
															Id deplLine,    
															Id unitofmeasureid,
															Id entity,                                                                                                                  
															Decimal quantity,
															String serialnumbers,
															Decimal itemcost,
															Decimal itemprice,
															Decimal transactioncost,
															Decimal transactionprice,
															Decimal transactionunitcost,
															Decimal transactionunitprice,
															String reasoncode,
															String notes) {
		
		PBSI__Movement_Line__c movementline = new PBSI__Movement_Line__c();
		movementline.PBSI__Movement_Journal__c = mjID;
		movementline.PBSI__Item__c = itemid ;
		movementline.PBSI__Lot__c = fromlotid;
		movementline.pbsi__from_pallet__c = frompalletid;
		movementline.pbsi__from_area__C = fromarea;
		movementline.pbsi__from_carton__c = fromcarton;
		movementline.PBSI__To_Lot__c = tolotid;
		movementline.pbsi__to_pallet__c = topalletid;
		movementline.pbsi__area__c = toarea;
		movementline.pbsi__carton__c = tocarton;
		movementline.PBSI__Shipped_Sales_Order_Line__c = shiplineid;  
		movementline.PBSI__Received_Purchase_Order_Line__c = reclineid;
		movementline.PBSI__Staging_Order_Lines__c = stagelineid;
		movementline.PBSI__Depletion_Line__c = deplLine;
		movementline.pbsi__unit_of_measure__c = unitofmeasureid;   
		movementline.pbsi__entity__c = entity;   
		movementline.PBSI__Transfer_Quantity__c = quantity;
		movementline.PBSI__Transfer_Quantity5__c = quantity;
		
		if(serialnumbers == null)
			serialnumbers = '';
		serialnumbers = serialnumbers.toUpperCase();   
		
		movementline.PBSI__Serial_Numbers__c = serialnumbers;
		movementline.PBSI__Item_Cost__c = itemcost;
		movementline.PBSI__Item_Price__c = itemprice;
		movementline.PBSI__Transaction_Cost__c = transactioncost;
		movementline.PBSI__Transaction_Price__c = transactionprice;
		movementline.PBSI__Transaction_Unit_Cost__c = transactionunitcost;
		movementline.PBSI__Transaction_Unit_Price__c = transactionunitprice;
		movementline.PBSI__Reason_Code__c = reasoncode;
		movementline.PBSI__Notestext__c = notes;
		movementline.pbsi__rma_line__c = rmalineid;
		return movementline;
	}
	
	public static PBSI__Movement_Line__c CreateMovementLine(Id soid, 
															Id itemid, 
															Id fromlotid,
															Id tolotid,
															Decimal quantity,
															String serialnumbers,
															String source,
															Id deplLine,
															Decimal itemcost,
															Decimal itemprice,
															Decimal transactioncost,
															Decimal transactionprice,
															Decimal transactionunitcost,
															Decimal transactionunitprice,
															Id shiplineid,
															Id stagelineid,
															String notes,
															String reasoncode,
															Id mjID,
															Id unitofmeasureid) {
		
		PBSI__Movement_Line__c m = CreateMovementline(soid,itemid,fromlotid,tolotid,quantity,
			serialnumbers,source,deplLine,itemcost,itemprice,transactioncost,transactionprice,
			transactionunitcost,transactionunitprice,shiplineid,mjID,unitofmeasureid);
		m.PBSI__Staging_Order_Lines__c = stagelineid;
		m.PBSI__Notestext__c = notes;
		m.PBSI__Reason_Code__c = reasoncode;
		return m;
	}
	
	public static PBSI__Movement_Line__c CreateMovementLine(Id soid, 
															Id itemid, 
															Id fromlotid,
															Id tolotid,
															Decimal quantity,
															String serialnumbers,
															String source,
															Id deplLine,
															Decimal itemcost,
															Decimal itemprice,
															Decimal transactioncost,
															Decimal transactionprice,
															Decimal transactionunitcost,
															Decimal transactionunitprice,
															Id shiplineid,
															Id mjID,
															Id unitofmeasureid) {
		
		PBSI__Movement_Line__c movementline = new PBSI__Movement_Line__c();
		movementline.PBSI__Movement_Journal__c = mjID;
		movementline.PBSI__Item__c = itemid ;
		
		if (source == 'receive')
			movementline.PBSI__To_Lot__c = fromlotid;
		else if (source == 'sale')
		{
			movementline.PBSI__Lot__c = fromlotid;
			movementline.PBSI__To_Lot__c = tolotid;
		}
		
		movementline.PBSI__Transfer_Quantity__c = quantity;
		movementline.PBSI__Transfer_Quantity5__c = quantity;
		movementline.PBSI__Serial_Numbers__c = serialnumbers;
		movementline.PBSI__Depletion_Line__c = deplLine;
		movementline.PBSI__Item_Price__c = itemprice;
		movementline.PBSI__Item_Cost__c = itemcost;
		movementline.PBSI__Transaction_Price__c = transactionprice;
		movementline.PBSI__Transaction_Cost__c = transactioncost;
		movementline.PBSI__Shipped_Sales_Order_Line__c = shiplineid;  
		movementline.pbsi__unit_of_measure__c = unitofmeasureid;
		movementline.PBSI__Transaction_Unit_Cost__c = transactionunitcost;
		movementline.PBSI__Transaction_Unit_Price__c = transactionunitprice;
		
		return movementline;    
	}
	
	public static void SetStagingMJournalOnSalesOrders(List<PBSI__PBSI_Sales_Order__c> salesorders, Integer mjIntType, String mjStrType) {
    	
        Map<string,PBSI__Movement_Journal__c>  mjtoinsert =  new Map<string,PBSI__Movement_Journal__c>();
    
        for (PBSI__PBSI_Sales_Order__c s:salesorders) {
            if (s.PBSI__Staging_Movement_Journal__c == null )
            {
                PBSI__Movement_Journal__c movementjournal = new PBSI__Movement_Journal__c();
                movementjournal.PBSI__Movement_Type__c = mjIntType; //200;
            
                if (salesorders != null)
                {
                    movementjournal.PBSI__Reference_Number__c = s.Name;
                
                    if (UserInfo.isMultiCurrencyOrganization() && Test.isRunningTest() == false)
                        movementjournal.put('CurrencyIsoCode',s.get('CurrencyIsoCode'));
                }
            
                movementjournal.PBSI__Type__c = mjStrType; //'Goods Issue for Sale - Stock Item';
                movementjournal.PBSI__Reference_Type__c='Sales Order';
                mjtoinsert.put(s.Name,movementjournal);         
            }
        }
    
        if (mjtoinsert.size()>0)
        {
            try
            {
                insert mjtoinsert.values();
                
                List<PBSI__PBSI_Sales_Order__c> sotoupdate = new List<PBSI__PBSI_Sales_Order__c>();
        
                for (PBSI__PBSI_Sales_Order__c s:salesorders)
                {
                    if (mjtoinsert.containskey(s.Name))
                    {
                        s.PBSI__Staging_Movement_Journal__c = mjtoinsert.get(s.Name).Id;
                        sotoupdate.add(s);
                    }
                }
        
                update sotoupdate;
            }
            catch(Exception e){}
        }
	}
}