public with sharing class UpdateSODetails{
	public class UpdateException extends Exception {}
	public static Set<Id> solist;
    
    public static void calculateTradeLine(PBSI__PBSI_Sales_Order_Line__c [] soLines,Map<Id,PBSI__Unit__c> unitsMap,Map<Id,PBSI__PBSI_Item__c> itemsMap){  
		Set<Id> unitsIds=new Set<Id>();
        Set<Id> salesorderAcc=new Set<Id>();
        Set<Id> linesItems=new Set<Id>();
        Set<Id> salesorderAccGr=new Set<Id>();
        set<id> soIds=new set<id>();
        Set<Id> linesItemGroup=new Set<Id>();
	    boolean trade2dec=false;
	    boolean trade0dec=true;
	    boolean trade4dec=false;
	    boolean twodec = true;
	    List<PBSI__Property__c> propertiesList;
    	String []propertynames=new String[]{'TradeDecimalPlaces','DecimalPlaces'};
		AscentCustomSettings ascentCustomSetting = new AscentCustomSettings();        
   		AscentProperties ascentProperty; 

        Map<Id,Set<ID>> itemgrMap=new Map<id,set<id>>();
        Map<Id,Set<ID>> accGrMap=new Map<id,set<id>>();
        Map<id,boolean> disableTASO=new map<id,boolean>();
        boolean useDiscount1 = ascentCustomSetting.getUseDiscount2DecimalsOnSOLine();
        
		for (PBSI__PBSI_Sales_Order_Line__c a:soLines){
        	soIds.add(a.pbsi__sales_order__c);
		}
        if (soIds.size() > 0){
        	for (PBSI__PBSI_Sales_Order__c so :[Select PBSI__Disable_Sales_Trade_Agreement__c 
        										From PBSI__PBSI_Sales_Order__c 
        										where id in :soIds])
            	disableTASO.put(so.id,so.PBSI__Disable_Sales_Trade_Agreement__c);
        } 
        for (PBSI__PBSI_Sales_Order_Line__c sol:soLines){
            Double discount=sol.PBSI__Discount__c;
            
            if (useDiscount1){            
               discount=sol.pbsi__discount1__c;
            }
            if (discount == null){            
               discount=0;
            }
                 
           /* if (sol.PBSI__Disable_Sales_Trade_Agreement__c == false 
               && disableTASO.get(sol.pbsi__sales_order__c) == false 
               && sol.PBSI__Quantity_Needed__c > 0 &&  sol.PBSI__HasInstructions__c ==false &&  
                ((sol.Id == null && discount == 0 && sol.PBSI__Trade_Agreement__c == null) || 
                (sol.Id != null  && (discount != 0 && sol.PBSI__Trade_Agreement__c == null) == false)))
            {
            */
	            salesorderAcc.add(sol.PBSI__SOAccount__c);
                linesItems.add(sol.PBSI__Item__c);
                salesorderAccGr.add(sol.PBSI__SOAccountGr__c);
                linesitemGroup.add(sol.PBSI__Item_Group__c);
             
                if (itemgrMap.containsKey(sol.PBSI__Item__c)){                   
                	itemgrMap.get(sol.pbsi__item__c).add(sol.PBSI__Item_Group__c);
                }
                else{                 
                	itemgrMap.put(sol.pbsi__item__c,new Set<Id>{sol.PBSI__Item_Group__c});
                }
           
                if(sol.PBSI__SOAccount__c != null){
                	if (accGrMap.containsKey(sol.PBSI__SOAccount__c)){                        
                    	accGrMap.get(sol.PBSI__SOAccount__c).add(sol.PBSI__SOAccountGr__c);
                	}
                    else{                     
                    	accGrMap.put(sol.PBSI__SOAccount__c,new Set<Id>{sol.PBSI__SOAccountGr__c});
                    }    
                }
            //}
       }
    
       	if (itemsMap == null &&  linesItems.size() > 0)
            itemsMap = new Map<Id,PBSI__PBSI_Item__c>([select 
                                                            Id, 
                                                            Name, 
                                                            PBSI__salesprice__c,
                                                            PBSI__salesprice4__c,
                                                            PBSI__Wholesale_Price__c, 
                                                            PBSI__Standard_Lead_Time__c,
                                                            PBSI__Item_Type__c,
                                                            PBSI__Item_Group__c,
                                                            PBSI__Lot_Tracking__c,
                                                            PBSI__Percentage_Increase_Enabled__c,
                                                            PBSI__Percentage_Increase__c,
                                                            PBSI__Is_Serialized__c,
                                                            PBSI__Shipping_Amount_to_Customer__c,
                                                            Fabric_Code__c                         
                                                     from 
                                                            PBSI__PBSI_Item__c
                                                     where 
                                                            Id in : linesItems]);
        
       	if (itemsMap != null && itemsMap.size() > 0) 
            for (PBSI__junc_Items2ItemGroups__c j: [select 
                                                        pbsi__Item__c,
                                                        pbsi__Item_Group__c 
                                                    from 
                                                        PBSI__junc_Items2ItemGroups__c 
                                                    where 
                                                        pbsi__Item__c in: itemsMap.keySet()]){
           linesitemGroup.add(j.pbsi__Item_Group__c);
            
			if (itemgrMap.containsKey(j.pbsi__Item__c)){             
            	itemgrMap.get(j.pbsi__item__c).add(j.pbsi__item_group__c);
			}
           	else{            
           		itemgrMap.put(j.pbsi__item__c,new Set<Id>{j.pbsi__item_group__c});
           	}
		}
         
      	if (ascentCustomSetting.getUseParentGroupsInTradeAgreements()){
           	Set<Id> allitemgr=new set<Id>();
           	for (id i:itemgrMap.keyset()){               
           		allitemgr.addALL(itemgrMap.get(i));
           	}
           	Map<Id,set<Id>> grpr=recursiveAddParentGroups(allitemgr,null);
           	for (Id i:itemgrMap.keySet()){
               for (id s:itemgrMap.get(i)){
                    itemgrMap.get(i).addAll(grpr.get(s));
                    linesitemGroup.addall(grpr.get(s));
               }
           	}
      	}
       
      	if (salesorderAcc.size() > 0){
            for (PBSI__junc_Accounts2AccountGroups__c j: [select 
                                                                pbsi__Account__c,
                                                                pbsi__Account_Group__c 
                                                          from 
                                                                PBSI__junc_Accounts2AccountGroups__c 
                                                          where 
                                                                pbsi__Account__c in: salesorderAcc]){
	           	salesorderAccGr.add(j.pbsi__Account_Group__c);
	           	if (accGrMap.containsKey(j.pbsi__account__c)){              
	           		accGrMap.get(j.pbsi__account__c).add(j.pbsi__account_group__c);
	           	}else{             
	           		accGrMap.put(j.pbsi__account__c,new Set<Id>{j.pbsi__account_group__c});
	           	}
     		}                
      	}               
		   
      	ascentProperty  = new AscentProperties();
        if (ascentProperty.decimalPlaces == '4'){ 
            trade4dec=true;
            trade0dec=false;
            trade2dec=false;
            twodec=false;
            }
        else 
        if (ascentProperty.tradeDecimalPlaces == '2'){
            trade2dec=true;
            trade0dec=false;
            trade4dec=false;
            }
        else
        if (ascentProperty.tradeDecimalPlaces == '4'){
            trade4dec=true;
            trade0dec=false;
            trade2dec=false;
            }   
        else
        if (ascentProperty.tradeDecimalPlaces == '0'){
            trade4dec=false;
            trade0dec=true;
            trade2dec=false;
            } 		

	    if (unitsMap == null){
			for (PBSI__PBSI_Sales_Order_Line__c sol:soLines){ 
	            if (sol.PBSI__Unit_Of_Measure__c != null && sol.PBSI__Quantity_Needed__c > 0){ 
	                unitsids.add(sol.PBSI__Unit_Of_Measure__c);
	            }
			}
        
        	if (unitsids.size() > 0){ 
            	unitsMap = new Map<Id,PBSI__Unit__c>([select 
                                                    Id,
                                                    PBSI__Quantity__c,
                                                    PBSI__Sale_Price__c,
                                                    PBSI__Sale_Price4__c 
                                               from 
                                                    PBSI__Unit__c 
                                               where 
                                                    id in :unitsids]);
        	}
    	}

		Map<String, Schema.SObjectField> taSchema = Schema.SObjectType.PBSI__Trade_Agreement__c.fields.getMap();
    	List<PBSI__Trade_Agreement__c> allTradeAgreements;

    	String strSelect = 'select Name,Sales_Order_Type__c,PBSI__Price_Type__c, pbsi__Quantity__c, PBSI__Unit_Of_Measure__c, PBSI__Unit_Of_Measure__r.PBSI__Quantity__c, ' +
                       'PBSI__Unit_Of_Measure__r.PBSI__Sale_Price__c,PBSI__Unit_Of_Measure__r.PBSI__Sale_Price4__c,pbsi__Trade_Object__c,pbsi__Price__c, ' +
                       'pbsi__Price4__c,pbsi__TPrice__c,pbsi__Discount__c,pbsi__Level__c,pbsi__Discount_Type__c,pbsi__Agreement_Type__c,pbsi__Date_From__c,pbsi__Date_To__c, ' +
                       'pbsi__Item_Group_Selection__c,pbsi__Item_Selection__c,pbsi__Account_Selection__c,pbsi__Account_Group_Selection__c, Fabric_Code__c ';

    	if (taSchema.containsKey('CurrencyIsoCode'))        strSelect += ' , CurrencyIsoCode ';
    
    	strSelect += 'From PBSI__Trade_Agreement__c d where (';
     
    	string str1=     '( pbsi__Trade_Object__c=\'Item\' AND pbsi__Item_Selection__c in  :linesItems  ) ' +
                   'OR ( pbsi__Discount_Type__c=\'all\') ' + 
                   'OR(pbsi__Trade_Object__c=\'Item/Account\' AND pbsi__Item_Selection__c in :linesItems AND  pbsi__Account_Selection__c  in :salesorderAcc) ' ;
     
    	string str2= ' (pbsi__Trade_Object__c=\'Account\' AND pbsi__Account_Selection__c  in  :salesorderAcc  ) ' + 
                   'OR (pbsi__Trade_Object__c=\'Item Group\' AND pbsi__Item_Group_Selection__c in :linesitemGroup) ' + 
                   'OR ( pbsi__Trade_Object__c=\'Account Group\' AND pbsi__Account_Group_Selection__c in :salesorderAccGr) ' ;
                  
   		string str3=    ' (pbsi__Trade_Object__c=\'Item Group/Account\' AND  pbsi__Item_Group_Selection__c in :linesitemGroup  AND pbsi__Account_Selection__c in :salesorderAcc ) ' +  
                   'OR (pbsi__Trade_Object__c=\'Item/Account Group\' AND pbsi__Item_Selection__c in :linesItems AND pbsi__Account_Group_Selection__c in :salesorderAccGr ) ' + 
                   'OR (pbsi__Trade_Object__c=\'Item Group/Account Group\' AND  pbsi__Item_Group_Selection__c in :linesitemGroup AND pbsi__Account_Group_Selection__c in :salesorderAccGr) ';
 
   		string strfinal= //'AND ((PBSI__Date_From__c <=  TODAY AND (PBSI__Date_To__c = NULL  OR  PBSI__Date_To__c >= TODAY) )) ' +
                    'AND pbsi__Level__c=\'line\'  AND ISDELETED=false ' + 
                    'AND pbsi__Applies_To__c=\'Sales Order\' ';

		if (ascentCustomSetting.getSplitTradeAgreementsQueries()){
        	List<PBSI__Trade_Agreement__c> allt1=Database.query(strselect+str1+')'+strfinal);
        	List<PBSI__Trade_Agreement__c> allt2=Database.query(strselect+str2+')'+strfinal);
        	List<PBSI__Trade_Agreement__c> allt3=Database.query(strselect+str3+')'+strfinal);
        	allTradeAgreements=new List<PBSI__Trade_Agreement__c>();
        	allTradeAgreements.addAll(allt1);
        	allTradeAgreements.addAll(allt2);
        	allTradeAgreements.addAll(allt3);
   		}
   		else
       		allTradeAgreements = Database.query(strSelect+str1+'OR'+str2+'OR'+str3+')'+strfinal);
		if (allTradeAgreements != null && allTradeAgreements.size() > 0){   
	    	for (PBSI__PBSI_Sales_Order_Line__c sol:soLines)
   		    {
            	Double discount=sol.PBSI__Discount__c;
	            if (useDiscount1){              
	            	discount=sol.pbsi__discount1__c;
	            }
            	if (discount == null){               
              		discount=0;
            	}
            	/*
	            if (ascentCustomSetting.getIgnoreTAWhenUserOverridingPrice() 
	            && twodec && sol.pbsi__price__c <> itemsMap.get(sol.pbsi__item__c).pbsi__salesprice__c) break;
	            if (sol.PBSI__Disable_Sales_Trade_Agreement__c == false 
	            && disableTASO.get(sol.pbsi__sales_order__c) == false 
	            && sol.PBSI__Quantity_Needed__c > 0 
	            && sol.PBSI__HasInstructions__c ==false 
	            && ((sol.Id == null && discount == 0 && sol.PBSI__Trade_Agreement__c == null) || 
                  (sol.Id != null  && (discount != 0 && sol.PBSI__Trade_Agreement__c == null) == false)))
            	{
            	*/
                	PBSI__Trade_Agreement__c[] t=new List<PBSI__Trade_Agreement__c>();
                    String accId=sol.PBSI__SOAccount__c;
                   // String accGr=sol.PBSI__SOAccountGr__c;               
                    for (PBSI__Trade_Agreement__c ta:allTradeAgreements)
                    {
                    	if ((ta.pbsi__Trade_Object__c=='Item' && ta.pbsi__Item_Selection__c == sol.PBSI__Item__c) || 
                           (ta.pbsi__Discount_Type__c=='all') || 
                           (ta.pbsi__Trade_Object__c=='Account' && ta.pbsi__Account_Selection__c == accId && ta.pbsi__Account_Selection__c != null) || 
                           (ta.pbsi__Trade_Object__c=='Item Group' &&  itemgrMap.get(sol.pbsi__Item__c).contains(ta.pbsi__Item_Group_Selection__c) && ta.pbsi__Item_Group_Selection__c != NULL) || 
                           (ta.pbsi__Trade_Object__c=='Account Group' &&  accGrMap.containsKey(accId) && accGrMap.get(accId).contains(ta.pbsi__Account_Group_Selection__c) && ta.pbsi__Account_Group_Selection__c != NULL) || 
                           
                           (ta.pbsi__Trade_Object__c=='Item/Account' && ta.pbsi__Item_Selection__c == sol.PBSI__Item__c &&  ta.pbsi__Account_Selection__c == accId) ||  
                           (ta.pbsi__Trade_Object__c=='Item Group/Account' &&  itemgrMap.get(sol.pbsi__Item__c).contains(ta.pbsi__Item_Group_Selection__c) && ta.pbsi__Account_Selection__c == accId ) || 
                           (ta.pbsi__Trade_Object__c=='Item/Account Group' && ta.pbsi__Item_Selection__c == sol.PBSI__Item__c && accGrMap.containsKey(accId) && accGrMap.get(accId).contains(ta.pbsi__Account_Group_Selection__c) ) || 
                           (ta.pbsi__Trade_Object__c=='Item Group/Account Group' &&  itemgrMap.get(sol.pbsi__Item__c).contains(ta.pbsi__Item_Group_Selection__c)&& accGrMap.containsKey(accId) && accGrMap.get(accId).contains(ta.pbsi__Account_Group_Selection__c))) 
                      	{   
                         	if (ta.PBSI__Price_Type__c == sol.PBSI__Price_Type__c || ta.PBSI__Price_Type__c == null || (sol.PBSI__Price_Type__c == null && ta.PBSI__Price_Type__c == 'Retail')){
                            	if (ta.pbsi__Date_From__c <= sol.PBSI__Sales_Order_Ship_Date__c && (ta.pbsi__Date_to__c >= sol.PBSI__Sales_Order_Ship_Date__c || ta.pbsi__Date_to__c == null)){
                             		if (ta.Sales_Order_Type__c == sol.Sales_Order_Type__c || ta.Sales_Order_Type__c == null || sol.Sales_Order_Type__c == null){
   		                        		t.add(ta);
                             		}
                      			}
                         	}
                      	} 
                    }
                    PBSI__Trade_Agreement__c applicableta=null;
                    Double linepPrice;
                    if (sol.Id == null){
                        if (twodec){                   
                        	linepPrice=sol.PBSI__Price__c;
                        }
                        else{                           
                          	linepPrice=sol.PBSI__Price4__c;
                        }
                    }
                    else if (sol.PBSI__Unit_Of_Measure__c != null ){ 
                        if (twodec){        
                        	linepPrice=unitsMap.get(sol.PBSI__Unit_Of_Measure__c).PBSI__Sale_Price__c;
                        }
                        else{               
                        	linepPrice=unitsMap.get(sol.PBSI__Unit_Of_Measure__c).PBSI__Sale_Price4__c;
                        }
                    }
                    else{
                    	if (twodec){
                        	if (sol.PBSI__Price_Type__c == 'Wholesale'){                            
                            	linepPrice=itemsMap.get(sol.PBSI__Item__c).PBSI__Wholesale_Price__c;
                        	}
                            else{                               
	                             linepPrice=sol.PBSI__ItemSalesPrice__c;
                            }
                         }
                         else{
                            linepPrice=itemsMap.get(sol.PBSI__Item__c).PBSI__salesprice4__c;
                         }
                    }
                    Double mindiscount=null;
                    String agrmtype=null;
                    Double price=linepPrice;
                    if (true){                   
                    	linepPrice=null;
                    }
                   	boolean ista1 =false;
                   	boolean ista2 = false;
                   	boolean ista3 = false;
 					Double taPrice;
                    for (PBSI__Trade_Agreement__c ta :t)
                    {
                        if (ascentCustomSetting.getCheckTACurrencyForSOLinePrice() &&((string)ta.get('CurrencyIsoCode')) == ((string)sol.get('CurrencyIsoCode'))){
							if (!ista1 && !ista2 && !ista3 && ta.PBSI__Item_Group_Selection__c == sol.PBSI__Item_Group__c 
														&& ta.Sales_Order_Type__c == sol.Sales_Order_Type__c 
														&& ta.Fabric_Code__c == itemsMap.get(sol.PBSI__item__c).Fabric_Code__c)//sol.PBSI__item__r.Fabric_Code__c )
							{
	    	                    if (trade4dec){ 
	        	                	taPrice=ta.pbsi__Price4__c;
	    	                    }
	            	            else{
	                	            if (trade2dec){        
	                    	        	taPrice=ta.pbsi__TPrice__c;
	                	            }
	                        	    else{                  
	                            		taPrice=ta.pbsi__Price__c;
	                        	    }
	            	            }
	                        	ista1 = true;
								applicableta=ta;
							}
                        }
                    }
                    for (PBSI__Trade_Agreement__c ta :t)
                    {
                        if (ascentCustomSetting.getCheckTACurrencyForSOLinePrice() &&((string)ta.get('CurrencyIsoCode')) == ((string)sol.get('CurrencyIsoCode'))) {
							if (!ista1 && !ista2 && !ista3 && ta.PBSI__Item_Group_Selection__c == sol.PBSI__Item_Group__c 
							&& ta.Sales_Order_Type__c == sol.Sales_Order_Type__c 
							&& ta.Fabric_Code__c==null){
	            	            if (trade4dec){ 
	                	        	taPrice=ta.pbsi__Price4__c;
	            	            }
	                    	    else{
	                        	    if (trade2dec){        
	                            		taPrice=ta.pbsi__TPrice__c;
	                        	    }
	                            	else{                  
	                            		taPrice=ta.pbsi__Price__c;
	                            	}
	                    	    }
	                            ista2 = true;
								applicableta=ta;
                    		}
                        }
                    }
                    for (PBSI__Trade_Agreement__c ta :t)
                    {
                        if (ascentCustomSetting.getCheckTACurrencyForSOLinePrice() &&((string)ta.get('CurrencyIsoCode')) == ((string)sol.get('CurrencyIsoCode'))){ 
							if (!ista1 && !ista2 && !ista3 && ta.PBSI__Item_Group_Selection__c == sol.PBSI__Item_Group__c && ta.Sales_Order_Type__c == null && ta.Fabric_Code__c == null){
	                        	if (trade4dec){ 
	                        		taPrice=ta.pbsi__Price4__c;
	                        	}
	                        	else{
	                            	if (trade2dec){        
	                            		taPrice=ta.pbsi__TPrice__c;
	                            	}
	                            	else{                  
	                            		taPrice=ta.pbsi__Price__c;
	                            	}
	                        	}
	                        	ista3 = true;
								applicableta=ta;
							}
                    	}
                    }

                    for (PBSI__Trade_Agreement__c ta :t)
                    {
                        if(
                        ((ascentCustomSetting.getCheckTACurrencyForSOLinePrice() &&((string)ta.get('CurrencyIsoCode')) == ((string)sol.get('CurrencyIsoCode'))) 
                        || !ascentCustomSetting.getCheckTACurrencyForSOLinePrice()) 
                        && (ista1 || ista2 || ista3) && ta.Id==applicableta.Id){
                            sol.pbsi__price__C=taPrice;
                            if (sol.pbsi__trade_Agreement__C <> null && ta.id == sol.pbsi__trade_Agreement__C && sol.pbsi__price4__c <> ta.pbsi__price4__C){
                            	sol.pbsi__price4__C=taPrice;
                            }
                            if ((ta.pbsi__Agreement_Type__c == 'price' && 
                                 ta.PBSI__Unit_Of_Measure__c == sol.PBSI__Unit_Of_Measure__c &&  
                                 (taPrice < linepPrice || linepPrice == null )
                                 ) 
                                 || 
                                 (ta.pbsi__Agreement_Type__c =='discount' && (linepPrice == null || price-((price * ta.pbsi__Discount__c)/100 ) < linepPrice))){
                                	
                                	boolean ok=true;   
                                	Double quantity=ta.pbsi__Quantity__c;
                                	Double linequant=sol.PBSI__Quantity_Needed__c;
	                                if (sol.PBSI__Unit_Of_Measure__c != null ){                   
    		                            linequant*=unitsMap.get(sol.PBSI__Unit_Of_Measure__c).PBSI__Quantity__c;
	                                }
	                                if (ta.PBSI__Unit_Of_Measure__c != null ){                   
    		                            quantity*=ta.PBSI__Unit_Of_Measure__r.PBSI__Quantity__c;
	                                }
	                                if (quantity > 0){          
    		                            if (linequant < quantity){           
            			                    ok=false; 
    		                            }
	                                }        
	                                if (ok){
	                                    if (ta.pbsi__Agreement_Type__c == 'price'){
	                                        linepPrice=taPrice; 
	                                        agrmtype='price';
	                                    } 
	                                    else if ( ta.pbsi__Agreement_Type__c =='discount' ){ 
	                                    		if(price != null){            
	                                         		linepPrice=price-((price * ta.pbsi__Discount__c)/100 );
	                                    		}
		                                        applicableta=ta;
		                                        agrmtype='discount';
	                                    }
	                               }      
                            } //for (PBSI__Trade_Agreement__c ta :t)
                         }
                    }
                    if (applicableta == null && sol.pbsi__Trade_Agreement__c != null){  
                    	decimal itemprice;
                        if (sol.id <> null){ 
                         	itemprice=itemsMap.get(sol.PBSI__Item__c).PBSI__salesprice4__c;
                        }
                        sol.pbsi__Trade_Agreement__c=null;
                        if (sol.id <> null){
                         	    if (twodec)                   
                         	     sol.PBSI__Price__c=itemprice;
                               else                         
                                 sol.PBSI__Price4__c=itemprice;
                         }
                         else{ 
                         	if (twodec){                   
                         		sol.PBSI__Price__c=price;
                         	}
                         	else{
                         		sol.PBSI__Price4__c=price;
                         	}
                         	if (useDiscount1){             
                         		sol.pbsi__Discount1__c=0;
                         	}  
                         	else{                          
                         		sol.pbsi__Discount__c=0;
                         	}         
                         }         
                     }
                     if (applicableta != null && applicableta.id != sol.pbsi__Trade_Agreement__c){ 
                        sol.pbsi__Trade_Agreement__c=applicableta.Id;
                        if (agrmtype.equals('discount')){
                             if (useDiscount1){ 
                                sol.pbsi__Discount1__c=mindiscount;
                             }
                             else{
                                sol.pbsi__Discount__c=mindiscount;
                             }
                             if (sol.Id != null){
                             	if (twodec){            
                             		sol.pbsi__Price__c=price;
                             	}
                                else{                   
                                	sol.pbsi__Price4__c=price;
                                }
                             }
                        }
                        else{
	                        if (sol.Id != null){
                                if (useDiscount1){                   
                                	sol.pbsi__Discount1__c=0;
                                } 
                                else{                                
                                	sol.pbsi__Discount__c=0;
                                }
	                        }
                            if (twodec){             
                            	sol.pbsi__Price__c=linepPrice;
                            }
                            else{                    
                            	sol.pbsi__Price4__c=linepPrice;
                            }
                        }
                     }

                   // }       
  			} //for (PBSI__PBSI_Sales_Order_Line__c sol:soLines)
        } // if
	}
	public static Map<Id,set<id>> recursiveAddParentGroups(set<id> grids,Map<Id,set<id>> grpr)
	{
		if (grpr == null){
	    	grpr = new Map<Id,set<id>>();
	        for (id i:grids){
	           	grpr.put(i, new set<id>());
	        }
	    }
		Set<Id> parents=new Set<Id>();
        List<PBSI__PBSI_Item_Group__c> itemgroups = [select id,PBSI__Parent_Group__c from PBSI__PBSI_Item_Group__c where Id in:grids];
	    for (PBSI__PBSI_Item_Group__c igr:itemgroups){
		    if (igr.PBSI__Parent_Group__c != null)
		    {
            	if (grpr.containsKey(igr.Id))
              	{
                	grpr.get(igr.Id).add(igr.PBSI__Parent_Group__c);
                   	if (grpr.containskey(igr.PBSI__Parent_Group__c))
                    	grpr.get(igr.id).addALL(grpr.get(igr.PBSI__Parent_Group__c));
              	}
                else{
                	for (Id s:grpr.keySet()){
                    	if (grpr.get(s).contains(igr.Id))
                     	{
                       		grpr.get(s).add(igr.PBSI__Parent_Group__c);
                        	if (grpr.containskey(igr.PBSI__Parent_Group__c)){
                       			grpr.get(s).addALL(grpr.get(igr.PBSI__Parent_Group__c));
                        	}
                     	}
                	}
                }
    	       	if (igr.PBSI__Parent_Group__c != null){ 
		           	parents.add(igr.PBSI__Parent_Group__c);
    	       	}
		    }
		}	    
	    if (parents.size() >0){ 
	    	recursiveaddparentgroups(parents,grpr);
	    }
	    return grpr;
	}
}