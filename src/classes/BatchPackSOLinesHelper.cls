public with sharing class BatchPackSOLinesHelper {
	
	private AscentProperties ascentPR;
	private AscentCustomSettings ascentCS;
	private Map<Id, PBSI__PBSI_Sales_Order_Line__c> soLinesMap;
	private Map<Id, PBSI__PBSI_Sales_Order_Line__c> soLinesToUpdate;
	private Map<Id, List<PBSI__PBSI_Inventory__c>> inventoriesMap;
    private List<PBSI__Shipped_Sales_Order_Line__c> packedLines;
    private Map<Id, PBSI__Lot__c> lotsMap;
   	private List<SOLineWrapper> sLinesList;
	
	public BatchPackSOLinesHelper() {
		ascentPR = new AscentProperties();
		ascentCS = new AscentCustomSettings();
		sLinesList = new List<SOLineWrapper>();
	}
	
    public void PackLines(List<PBSI__PBSI_Sales_Order_Line__c> soLinesToPack) {
    	soLinesMap = new Map<Id, PBSI__PBSI_Sales_Order_Line__c>(soLinesToPack);
    	soLinesToUpdate = new Map<Id, PBSI__PBSI_Sales_Order_Line__c>();
    	
    	try {
	    	setupLineWrappers();
	    	prepareItemLots();
	    	fetchItemInventories();
	    	
	    	preparePackedLines();
	    	createPackedLines();
	    	createMovementLines();
	    	
    	} catch (Exception ex) {
    		LogService lserv = LogService.getLogService();
    		Log lex = lserv.addError();
    		lex.exception(ex);
    		lex.relatedObjId(soLinesToPack[0].Id);
    		lex.createActivity();
    		lserv.save();
    		
    	} finally {
	    	if (soLinesToUpdate.size() > 0) {
	    		update soLinesToUpdate.values();
	    	}
    	}
    }
    
    private void setupLineWrappers() {
    	Map<Id, Map<Id, Decimal>> atpMap = getATPMap();
		for (PBSI__PBSI_Sales_Order_Line__c line : soLinesMap.values()) {
			Double lineATP = 0;
			if (line.PBSI__Location__c != null) {
				if(atpMap.containskey(line.PBSI__Item__c) && atpMap.get(line.PBSI__Item__c).containskey(line.PBSI__Location__c)) {
					lineATP = atpMap.get(line.PBSI__Item__c).get(line.PBSI__Location__c);
				}
			}
			
			Double qtyOnHand;
			if (line.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null) {
				qtyOnHand = line.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue();
			}
			
			Boolean okForPack = true;
			if (line.PBSI__Sales_Order__r.Sales_Order_Type__c != 'Pre-Order' && lineATP <= 0) {
				line.Batch_Status_Description__c = 'ATP too low for non preorder line';
				okForPack = false;
			}
			if (okForPack && qtyOnHand < line.PBSI__Total_Unit_Qty_Needed__c) {
				line.Batch_Status_Description__c = 'Qty on hand lower than expected';
				okForPack = false;
			}
				
			if (!okForPack) {
				line.Batch_Status__c = 'Failure';
				if (!soLinesToUpdate.containsKey(line.Id)) {
					soLinesToUpdate.put(line.Id, line);
				}
			}
			sLinesList.add(new SOLineWrapper(line, lineATP, qtyOnHand, okForPack));
		}
    }
    
    private void prepareItemLots() {
		Set<Id> itemsIds = new Set<Id>();
		
    	for (SOLineWrapper lineWrapper : sLinesList) {
    		if (lineWrapper.OkForPack && 
    			lineWrapper.SOLine.PBSI__Bom_Type__c != 'BOM-Phantom' && 
    			lineWrapper.SOLine.PBSI__Quantity_Left_To_Ship__c > 0 && 
    			!lineWrapper.SOLine.PBSI__Item__r.PBSI__Is_Serialized__c) {
    			
    			itemsIds.add(lineWrapper.SOLine.PBSI__Item__c);
    		}
    	}
    	
		lotsMap = new Map<Id, PBSI__Lot__c>();
		if (itemsIds.size() > 0) {
			if (ascentPR.LotUsage == 'Yes') {
				for (PBSI__Lot__c lot : 
					[SELECT Id, Name, PBSI__total_landed_cost__c, PBSI__Item__c, PBSI__average_cost__c, PBSI__purchase_price__c 
					FROM PBSI__Lot__c  WHERE PBSI__Item__c in :itemsIds  AND  PBSI__Lot_Status__c = 'Released' 
					AND (PBSI__Expiration_Date__c > Today or PBSI__Expiration_Date__c = null)
					AND PBSI__Location__r.PBSI__Available_for_Packing__c = false]) {
					
					if (lotsMap.containsKey(lot.PBSI__Item__c) && lot.Name.contains('Default')){
						lotsMap.put(lot.PBSI__Item__c, lot);
					} else if (!lotsMap.containsKey(lot.PBSI__Item__c)) {  
							lotsMap.put(lot.PBSI__Item__c, lot);
					}
				}
				
			} else {
        		for (PBSI__Lot__c lot:
					[SELECT Id, Name, PBSI__total_landed_cost__c, PBSI__Item__c, PBSI__average_cost__c, PBSI__purchase_price__c 
					FROM PBSI__Lot__c  WHERE PBSI__Item__c in :itemsIds  AND PBSI__Lot_For_Location__c ='Yes' 
					AND PBSI__Location__r.PBSI__Available_for_Packing__c = false]) {
						
					lotsMap.put(lot.PBSI__Item__c, lot);
				}
			}
		}
    }
    
    private void fetchItemInventories() {
		Set<Id> itemsIds = new Set<Id>();
		
    	for (SOLineWrapper lineWrapper : sLinesList) {
    		if (lineWrapper.OkForPack && 
    			lineWrapper.SOLine.PBSI__Bom_Type__c != 'BOM-Phantom' &&  
    			!lineWrapper.SOLine.PBSI__Item__r.PBSI__Is_Service__c && 
    			!lineWrapper.SOLine.PBSI__Item__r.PBSI__Is_Serialized__c && 
    			!lineWrapper.SOLine.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c) {
    			
    			itemsIds.add(lineWrapper.SOLine.PBSI__Item__c);
    		}
    	}
		
		inventoriesMap = new Map<Id, List<PBSI__PBSI_Inventory__c>>();
		if (itemsIds.size() > 0) {
			String basesoql = 'SELECT Id,PBSI__Lot__r.PBSI__Total_Landed_Cost__c,pbsi__cost__c,PBSI__location_lookup__r.pbsi__entity__c,' + 
								'PBSI__Lot__r.PBSI__Average_Cost__c,PBSI__Lot__r.pbsi__purchase_price__c,PBSI__item_lookup__c,PBSI__qty__c,' + 
								'PBSI__Lot__c,PBSI__Lot__r.Name,PBSI__Lot__r.PBSI__Location__c,PBSI__location_lookup__r.Name,PBSI__Area__c,' + 
								'PBSI__Carton__c FROM PBSI__PBSI_Inventory__c ' +
								'WHERE PBSI__item_lookup__c in :itemsIds and PBSI__Is_Counted__c = \'Yes\' ' + 
								'AND PBSI__Is_Valid__c =\'Yes\' AND PBSI__Lot__r.PBSI__Location__r.PBSI__Available_for_Packing__c = false';
		    				  
			if (ascentPR.LotUsage == 'Yes') {
				basesoql += ' AND (PBSI__Lot__r.PBSI__Expiration_Date__c > Today' +
							' OR PBSI__Lot__r.PBSI__Expiration_Date__c = null)' + 
							' AND PBSI__Lot__r.PBSI__Lot_Status__c=\'Released\' ';
			} else { 
				basesoql += ' AND PBSI__Lot__r.PBSI__Lot_For_Location__c = \'Yes\'';
			}
			basesoql += ' AND PBSI__Qty__c > 0';
			
			if (ascentPR.LotUsage == 'Yes') {
				if (ascentPR.LotSortOrder == 'Name Ascending' ) { 
					basesoql += ' ORDER BY PBSI__Lot__r.Name asc';
				} else if (ascentPR.LotSortOrder == 'FIFO') { 
					basesoql += ' ORDER BY PBSI__Lot__r.PBSI__Created_Date__c ASC';
				} else if (ascentPR.LotSortOrder == 'LIFO') { 
					basesoql += ' ORDER BY PBSI__Lot__r.PBSI__Created_Date__c DESC';
				} else if (ascentPR.LotSortOrder == 'Highest Quantity') {
					basesoql += ' ORDER BY PBSI__Lot__r.PBSI__Total_Quantity__c DESC';
				} else if (ascentPR.LotSortOrder == 'FEFO') {
					basesoql += ' ORDER BY PBSI__Lot__r.PBSI__Expiration_Date__c ASC';
				}
			} else {
				basesoql += ' ORDER BY PBSI__Lot__r.PBSI__Is_In_Default_Location__c DESC';
			}
			List<PBSI__PBSI_Inventory__c> invList = Database.query(basesoql);
			
			if(invList != null) {
				Map<Id, PBSI__PBSI_Inventory__c> invMap = new Map<Id, PBSI__PBSI_Inventory__c>(invList);
				List<PBSI__PBSI_Inventory__c> invLock = [SELECT Id FROM PBSI__PBSI_Inventory__c WHERE Id =: invMap.keySet() FOR UPDATE];
				
				for (SOLineWrapper lineWrapper : sLinesList) {
					if (lineWrapper.OkForPack) {
						if (ascentCS.getForcePackingFromLocation() && lineWrapper.SOLine.PBSI__Sales_Order__r.PBSI__From_Location__c != null) {
							for (PBSI__PBSI_Inventory__c  inv : invList) {
								if (inv.PBSI__Lot__r.pbsi__location__c == lineWrapper.SOLine.PBSI__Sales_Order__r.PBSI__From_Location__c) {
									if (inventoriesMap.containsKey(inv.PBSI__item_lookup__c)) {
										inventoriesMap.get(inv.PBSI__item_lookup__c).add(inv);
									} else { 
										inventoriesMap.put(inv.PBSI__item_lookup__c, new PBSI__PBSI_Inventory__c[]{inv});
									}
								}
							}
						
						} else {
							for (PBSI__PBSI_Inventory__c inv : invList) {
								if (inventoriesMap.containsKey(inv.PBSI__item_lookup__c)) {
									inventoriesMap.get(inv.PBSI__item_lookup__c).add(inv);
								} else {               		
									inventoriesMap.put(inv.PBSI__item_lookup__c, new PBSI__PBSI_Inventory__c[]{inv});
								}
							}
						}
					}
				}
			}
		}
    }
    
	private void preparePackedLines() {
		packedLines = new List<PBSI__Shipped_Sales_Order_Line__c>();
		
		for (SOLineWrapper lineWrapper : sLinesList) {
			if (lineWrapper.OkForPack) {
				
				PBSI__PBSI_Sales_Order_Line__c soLine = lineWrapper.SOLine;
				if (soLine.PBSI__discount_amount__c == null) {
					soLine.PBSI__discount_amount__c = 0;
				}
				
				Double qtyLeft = soLine.PBSI__Quantity_Needed__c - soLine.PBSI__Quantity_Picked__c;
				if (soLine.PBSI__Quantity__c > 0) {
					qtyLeft = soLine.PBSI__Quantity__c;
				}
				
				Double unitQuant = 1;
				if (soLine.PBSI__Unit_Of_Measure__c != null && soLine.PBSI__Unit_Of_Measure__r.PBSI__Quantity__c > 0) {
					qtyLeft *= soLine.PBSI__Unit_Of_Measure__r.PBSI__Quantity__c;
					unitQuant = soLine.PBSI__Unit_Of_Measure__r.PBSI__Quantity__c;
				}
				
				if (soLine.PBSI__hasInstructions__c == false && 
					soLine.PBSI__Bom_Type__c != 'BOM-Phantom') {
					if (soLine.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c == false && 
						soLine.PBSI__Item__r.PBSI__Is_Service__c == false) {
						if (soLine.PBSI__Quantity_Left_To_Ship__c < 0) {
							
							Decimal recordedCost = getRecordedCost(soLine, true, true, false);
							packedLines.add(new PBSI__Shipped_Sales_Order_Line__c(PBSI__recorded_cost_4__c = recordedCost, PBSI__recorded_cost__c = recordedCost, PBSI__Quantity_shipped__c = qtyLeft,
								PBSI__discount_amount__c = soLine.PBSI__discount_amount__c * qtyLeft / soLine.pbsi__quantity_needed__c, PBSI__Item__c = soLine.PBSI__Item__c,
								PBSI__Sales_Order__c = soLine.PBSI__Sales_Order__c, PBSI__Sales_Order_Line__c = soLine.id, PBSI__Price__c = soLine.PBSI__Price__c,
								PBSI__discount__c = soLine.PBSI__discount__c, PBSI__price4__c = soLine.PBSI__price4__c, PBSI__discount1__c = soLine.PBSI__discount1__c,
								PBSI__unit_of_measure__c = soLine.PBSI__unit_of_measure__c, PBSI__lot__c = lotsMap.get(soLine.PBSI__item__c).Id));
							
						} else {
							PBSI__Shipped_Sales_Order_Line__c packedLine = takeInvOut(soLine, qtyLeft, 0, unitQuant);
							if (packedLine != null) {
								packedLines.add(packedLine);
							} else {
								lineWrapper.OkForPack = false;
								soLine.Batch_Status__c = 'Failure';
								soLine.Batch_Status_Description__c = 'No inventory available from the order location';
								if (!soLinesToUpdate.containsKey(soLine.Id)) {
									soLinesToUpdate.put(soLine.Id, soLine);
								}
							}
						}
						
					} else {
						Decimal recordedCost = getRecordedCost(soLine, false, false, false);
						packedLines.add(new PBSI__Shipped_Sales_Order_Line__c( PBSI__recorded_cost_4__c = recordedCost, PBSI__recorded_cost__c = recordedCost, PBSI__Quantity_shipped__c = qtyLeft,
							PBSI__discount_amount__c = soLine.PBSI__discount_amount__c * qtyLeft / soLine.PBSI__quantity_needed__c, PBSI__Item__c = soLine.PBSI__Item__c,
							PBSI__Sales_Order__c = soLine.PBSI__Sales_Order__c, PBSI__Sales_Order_Line__c = soLine.id, PBSI__Price__c = soLine.PBSI__Price__c, PBSI__discount__c = soLine.PBSI__discount__c,
							PBSI__price4__c = soLine.PBSI__price4__c, PBSI__discount1__c = soLine.PBSI__discount1__c, PBSI__unit_of_measure__c = soLine.PBSI__unit_of_measure__c));
					}
					
				} else {
					lineWrapper.OkForPack = false;
					soLine.Batch_Status__c = 'Failure';
					soLine.Batch_Status_Description__c = 'Line has shipping instructions or is a phantom BOM';
					if (!soLinesToUpdate.containsKey(soLine.Id)) {
						soLinesToUpdate.put(soLine.Id, soLine);
					}
				}
			}
		}
	}
	
	private void createPackedLines() {
		if (packedLines.size() > 0) {
			try {
				insert packedLines;
				
			} catch (Exception ex) {
				for (SOLineWrapper lineWrapper : sLinesList) {
					if (lineWrapper.OkForPack) {
						lineWrapper.OkForPack = false;
						PBSI__PBSI_Sales_Order_Line__c soLine = lineWrapper.SOLine;
						soLine.Batch_Status__c = 'Failure';
						soLine.Batch_Status_Description__c = ex.getMessage().abbreviate(32000);
						if (!soLinesToUpdate.containsKey(soLine.Id)) {
							soLinesToUpdate.put(soLine.Id, soLine);
						}
					}
				}
				throw ex;
			}
		}
		
		for (PBSI__Shipped_Sales_Order_Line__c shipLine : packedLines) {
			for (SOLineWrapper lineWrapper : sLinesList) {
				PBSI__PBSI_Sales_Order_Line__c soLine = lineWrapper.SOLine;
				if (soLine.Id == shipLine.PBSI__Sales_Order_Line__c) {
					soLine.Batch_Status__c = 'Success';
					soLine.Batch_Status_Description__c = '';
					if (!soLinesToUpdate.containsKey(soLine.Id)) {
						soLinesToUpdate.put(soLine.Id, soLine);
					}
				}
			}
		}
	}
	
	private void createMovementLines() {
		List<PBSI__Movement_Line__c> movementLines = new List<PBSI__Movement_Line__c>();
		Map<Id, PBSI__Shipped_Sales_Order_Line__c> packedLinesMap = new Map<Id, PBSI__Shipped_Sales_Order_Line__c>(packedLines);
		
		list<PBSI__Shipped_Sales_Order_Line__c> packedLinesNew = 
			[SELECT Id, Name, PBSI__item__r.PBSI__total_landed_Cost__c, PBSI__Item__r.PBSI__cost4__c, PBSI__Serial_Numbers__c, 
			PBSI__unit_of_measure__c, PBSI__unit_of_measure__r.PBSI__quantity__c, PBSI__Recorded_Cost__c, PBSI__Sales_Order__c,
			PBSI__Item__r.PBSI__Quantity_on_Hand__c, PBSI__ship_lot__c, PBSI__lot__c, PBSI__Quantity_Shipped__c,
			PBSI__Item__r.PBSI__Cost__c, PBSI__Item__r.PBSI__salesprice__c, PBSI__sales_order_line__r.PBSI__Item_Cost__c,
			PBSI__sales_order_line__r.PBSI__Price__c, PBSI__item__c, PBSI__BOM_Depletion_Line__c, PBSI__Area__c,
			PBSI__pallet__c, PBSI__carton__c, PBSI__sales_order_line__c
			FROM  PBSI__Shipped_Sales_Order_Line__c
			WHERE Id IN :packedLinesMap.keySet()];
			
		for (PBSI__Shipped_Sales_Order_Line__c plnew : packedLinesNew) {
			Double itemcost=0, itemprice=0, transactioncost=0, transactionprice=0;
			
			itemcost = plnew.PBSI__Item__r.PBSI__Cost__c;
			if (ascentCS.getUseCost4decOnItemMaster()){ 
				itemcost = plnew.pbsi__item__r.pbsi__cost4__C;
			}
			if (ascentCS.getUseLandedCost()){
				itemcost = plnew.pbsi__item__r.pbsi__total_landed_cost__c;
			}
			itemprice = plnew.PBSI__Item__r.PBSI__salesprice__c ;
			
			transactionCost = plnew.pbsi__sales_order_line__r.PBSI__Item_Cost__c;
			if (ascentCS.getUseSOLineCostForRecordedCost() || ascentCS.getUseSOLineCostForRecordedCost() || 
				ascentCS.getUseLotPurchasePriceForRecordedCost() || ascentCS.getUseInventoryCostForRecordedCost()) {
				transactionCost = plnew.PBSI__Recorded_Cost__c;
			}
			transactionPrice = plnew.pbsi__sales_order_line__r.PBSI__Price__c ;
			
			String source = 'sale';
			Decimal unitquant = 1;
			if (plnew.pbsi__unit_of_measure__r.pbsi__quantity__c <> null && plnew.pbsi__unit_of_measure__r.pbsi__quantity__c <> 0) {
				unitquant = plnew.pbsi__unit_of_measure__r.pbsi__quantity__c;
			}
			if (plnew.PBSI__Quantity_Shipped__c < 0) {
				source = 'receive';
			}
			
			Id fromLotId, fromPallet, toPallet, toLotId;
			String fromArea, fromCarton, toArea, toCarton;
			
			if (source == 'receive'){
				toLotId = plnew.PBSI__Lot__c;
				toPallet = plnew.pbsi__pallet__c;
				toArea = plnew.pbsi__Area__c;
				toCarton = plnew.pbsi__carton__c;
				
			} else {
				fromLotId = plnew.PBSI__Lot__c;
				fromPallet = plnew.pbsi__pallet__c;
				fromArea = plnew.pbsi__Area__c;
				fromCarton = plnew.pbsi__carton__c;      
				toLotId = plnew.pbsi__ship_lot__c; 	
			}
			
			PBSI__PBSI_Sales_Order_Line__c soLine = null;
			for (SOLineWrapper lineWrapper : sLinesList) {
				if (lineWrapper.SOLine.Id == plnew.PBSI__Sales_Order_Line__c) {
					soLine = lineWrapper.SOLine;
				}
			}
			
			Id movementJournal, entity;
			if (soLine != null && soline.PBSI__Sales_Order__r.PBSI__Movement_Journal__c != null) {
				movementJournal = soline.PBSI__Sales_Order__r.PBSI__Movement_Journal__c;
			}
			if (soLine != null && soline.PBSI__Sales_Order__r.PBSI__Entity__c != null) {
				entity = soline.PBSI__Sales_Order__r.PBSI__Entity__c;
			}
			
			movementLines.add(SoqlServiceUtils.CreateMovementLine(
				movementJournal, 
				plnew.PBSI__Item__c, 
				fromLotId, 
				fromPallet, 
				fromArea, 
				fromCarton, 
				toLotId, 
				toPallet, 
				toArea, 
				toCarton,
				plnew.id, 
				null, 
				null, 
				null, 
				plnew.PBSI__BOM_Depletion_Line__c, 
				plnew.pbsi__unit_of_measure__c,
				entity,
				plnew.pbsi__quantity_shipped__c, 
				plnew.PBSI__Serial_Numbers__c, 
				itemcost, 
				itemprice, 
				transactionCost * unitquant, 
				transactionPrice, 
				transactionCost, 
				transactionPrice / unitquant, 
				null, 
				null));
		}
		
		if (movementLines.size() > 0) {
			insert movementLines;
		}
	}
	
	private PBSI__Shipped_Sales_Order_Line__c takeInvOut(PBSI__PBSI_Sales_Order_Line__c soLine, Double qtyLeft, Double transferQty, Double unitQuant) {
		PBSI__Shipped_Sales_Order_Line__c packedLine = null;
		
		if (soLine != null && inventoriesMap.containsKey(soLine.PBSI__Item__c)) {
			while (qtyLeft > 0 && inventoriesMap.get(soLine.PBSI__Item__c).size() > 0) {
				PBSI__PBSI_Inventory__c inventory = inventoriesMap.get(soLine.PBSI__Item__c)[0];
				Boolean removeCurr = false;
				
				if (inventory.PBSI__qty__c > 0) {
					packedLine = new PBSI__Shipped_Sales_Order_Line__c (PBSI__item__c = soLine.PBSI__item__c, PBSI__sales_order__c = soLine.pbsi__sales_order__c,
						PBSI__sales_order_line__c = soLine.Id, PBSI__price__c = soLine.PBSI__price__c, PBSI__price4__c = soLine.PBSI__price4__c,
						PBSI__Discount__c = soLine.PBSI__Discount__c, PBSI__Discount1__c = soLine.PBSI__Discount1__c, PBSI__Unit_Of_Measure__c = soLine.PBSI__Unit_Of_Measure__c);
					
					if (inventory.PBSI__qty__c >= qtyLeft) {
						inventory.PBSI__qty__c -= qtyLeft;
						transferQty = qtyLeft;
						qtyLeft = 0;
						
					} else {
						transferQty = inventory.PBSI__qty__c;
						qtyLeft -= inventory.PBSI__qty__c;
						inventory.PBSI__qty__c = 0;
						removeCurr = true;
					}
					
					if (soLine.pbsi__discount_amount__c == null) {
						soLine.pbsi__discount_amount__c=0;
					}
					
					packedLine.PBSI__quantity_shipped__c = transferQty / unitQuant;
					packedLine.PBSI__discount_amount__c = soLine.pbsi__discount_amount__c * packedLine.pbsi__quantity_shipped__c / soLine.pbsi__quantity_needed__c;
					packedLine.PBSI__Area__c = inventory.PBSI__Area__c;
					packedLine.PBSI__Carton__c = inventory.PBSI__Carton__c;
					packedLine.PBSI__Lot__c = inventory.PBSI__Lot__c;
					
					Decimal recordedCost = getRecordedCost(soLine, true, true, true);
					packedLine.pbsi__recorded_cost__c = recordedCost;
					packedLine.pbsi__recorded_cost_4__c = recordedCost;    
				} else {
					removeCurr = true;
				}
				
				if (removeCurr) {
					inventoriesMap.get(soLine.PBSI__item__c).remove(0);
				}
			}
		}
		
		return packedLine;                        
	}
	
	private Decimal getRecordedCost(PBSI__PBSI_Sales_Order_Line__c soline, Boolean useaverage, Boolean usepurchase, Boolean useinvcost) {
		Decimal recordedCost = soline.PBSI__Item__r.PBSI__Cost__c;
		
		if (ascentCS.getUseCost4decOnItemMaster()) {
			recordedCost = soline.PBSI__Item__r.PBSI__Cost4__c;
		} 
		if (ascentCS.getUseLandedCost()) {
			recordedCost = soline.PBSI__Item__r.pbsi__total_landed_Cost__c;
		}
		if (ascentCS.getUseSOLineCostForRecordedCost()) {
			recordedCost = soline.PBSI__Item_Cost__c;
		}
		if (useaverage) {
			if (ascentCS.getUseLotAverageCostForRecordedCost() && lotsMap.get(soline.PBSI__item__c) != null) {
				if (ascentCS.getUseLandedCost()) {
					recordedCost = lotsMap.get(soline.PBSI__item__c).PBSI__total_landed_Cost__c ;
				} else {               
					recordedCost = lotsMap.get(soline.PBSI__item__c).PBSI__Average_Cost__c ;
				}
			}
		}
		if (usepurchase) {
			if (ascentCS.getUseLotPurchasePriceForRecordedCost() && lotsMap.get(soline.PBSI__item__c) != null) {
				if (ascentCS.getUseLandedCost()){
					recordedCost = lotsMap.get(soline.PBSI__item__c).PBSI__total_landed_Cost__c ;
				} else {
					recordedCost = lotsMap.get(soline.PBSI__item__c).pbsi__purchase_price__c;
				}
			}
		}
		if (useinvcost) {
			if (ascentCS.getUseInventoryCostForRecordedCost() && inventoriesMap.get(soline.PBSI__item__c) != null){
				recordedCost = inventoriesMap.get(soLine.PBSI__item__c)[0].pbsi__cost__c;
			}
		}
		
		return recordedCost != null ? recordedCost : 0;
	}
	
	private Map<Id, Map<Id, Decimal>> getATPMap() {
		Set<Id> locationIds = new Set<Id>();
		Set<Id> itemIds = new Set<Id>();
		
		for (PBSI__PBSI_Sales_Order_Line__c line : soLinesMap.values()) {
			itemIds.add(line.PBSI__Item__c);
			if (line.PBSI__Location__c != null)
				locationIds.add(line.PBSI__Location__c);
        }
		
		Map<Id, Map<Id, Decimal>> atpMap = new map<Id,map<Id,Decimal>>();
		if (itemIds.size() > 0 && locationIds.size() > 0) {
			List<ATP__c> atpList = [SELECT Location__c, Item__c, Current_ATP__c FROM ATP__c
									WHERE Location__c IN :locationIds AND Item__c IN :itemIds ];
			
			for (ATP__c atp : atpList) {
				if (atpMap.containskey(atp.Item__c))
					atpMap.get(atp.Item__c).put(atp.Location__c, atp.Current_ATP__c);
				else
					atpMap.put(atp.Item__c, new map<Id,Decimal>{atp.Location__c => atp.Current_ATP__c});
			}
		}
		
		return atpMap;
	}
}