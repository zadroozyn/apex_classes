public with sharing class PackLineModel {
    public PBSI__Shipped_Sales_Order_Line__c line{get;set;}
    public list<PBSI__Unit__c> units;
    public PBSI__Staging_Order_Lines__c stageline{get;set;}
    public PBSI__PBSI_Sales_Order_Line__c soline{get;set;}
    public PBSI__BOM_Depletion_Line__c bomdepline{get;set;}
    public List<SelectOption> options = new List<SelectOption>();
    public Map<Id,Double> lotsqty=new Map<Id,Double>{};
    public PBSI__Lot__c lot;
    public Decimal unitquant=1;
    public Decimal originalunitquant=1;
    public integer lineNumber{get;set;} 
    
    public List<PackLineModel> childlines=new List<PackLineModel>();
    
    public PBSI.SerialN[] serialnumbers{get;set;}
    public List<List<PBSI.SerialN>> limitedSerials {get; set;}
    
    public PackLineModel parent;
    public String unitofmeasure{get;set;}
    public String errorStyle{get;set;}
    public string qtyerrorstyle{get;set;}
    public String atperrorStyle{get;set;}
    public String generatedsn;
   
    public String itemname{get;set;}  
    public string itemcolor{get;set;} 
    
    public String itemDescr{get;set;}
    public boolean islineBomPhantom=false;
    public boolean isdropship=false;
    public boolean countInInventory=true;
   
    public boolean uselots=true;
    public boolean isShipping=true;
    public boolean usecarton=false;
    public boolean usePallets{get;set;}
    public boolean showSN=false; 
    public List<String> invstr=new list<string>();
    public List<Id> invstrlotid=new list<Id>();
    public Map<Id,Double> invqty=new Map<Id,Double>();
    public Double oldqty;
     public Double oldqtystage;
    public String oldinv;
    public String oldlot; 
    public String inventory{get;set;}
    public List<PBSI__Property__c> prop;
    public String serialsDivStyle{get;set;} 
    
    public boolean getislineBomPhantom() { return islineBomPhantom;}
    public boolean getshowsn(){return showsn;} 
    public boolean getisshipping(){return isshipping;}
    public double qshp;
    public double atp{get;set;}
    public boolean isDeleting = false;
    
    public PackLineModel(PBSI__PBSI_Sales_Order_Line__c l,boolean usinglots,boolean usecartonarea,List<PBSI__PBSI_Inventory__c> inv, double qsh)
    {
    	PBSI__Admin__c admin= PBSI__Admin__c.getOrgDefaults();        usecarton=usecartonarea;        uselots=usinglots;        
    	usePallets=(admin <> null && admin.PBSI__Use_Pallets__c);
        soline=l;        assignInventory(inv);
        line=new PBSI__Shipped_Sales_Order_Line__c(PBSI__rma_line__c=l.PBSI__rma_line__c,PBSI__item__c=l.PBSI__item__c,PBSI__sales_order__c=l.PBSI__sales_order__c,PBSI__sales_order_line__c=l.Id,PBSI__price__c=l.PBSI__price__c,PBSI__price4__c=l.PBSI__price4__c,PBSI__Discount__c=l.PBSI__Discount__c,PBSI__Discount1__c=l.PBSI__Discount1__c,PBSI__Unit_Of_Measure__c=l.PBSI__Unit_Of_Measure__c); 
        stageline=new PBSI__Staging_Order_Lines__c(pbsi__sales_order_line__c=l.id,pbsi__sales_order__c=l.pbsi__sales_order__c,pbsi__stage_quantity__c=qsh,pbsi__item__c=l.pbsi__item__c,PBSI__Unit_Of_Measure__c=l.PBSI__Unit_Of_Measure__c);
        if (l.pbsi__sales_order__r.PBSI__staging_location__c <> null)       	stageline.PBSI__To_Location__c=l.pbsi__sales_order__r.PBSI__staging_location__c;
           
        if (UserInfo.isMulticurrencyOrganization() && Test.isRunningTest() == false)        {             line.put('CurrencyIsoCode',l.get('CurrencyIsoCode'));             line.put('PBSI__Exchange_Rate__c',l.get('PBSI__Exchange_Rate__c'));       }
      
        this.itemname=l.PBSI__Item__r.name;
        
        if (l.PBSI__Item_Description_Long__c != null)            this.itemDescr=l.PBSI__Item_Description_Long__c;
        else            this.itemDescr=l.PBSI__ItemDescription__c;
        
        
        unitofmeasure=l.PBSI__Item__r.PBSI__defaultunitofmeasure__c;
        
        if (l.PBSI__Quantity__c > 0) line.PBSI__quantity_shipped__c=l.PBSI__Quantity__c;
        else          line.PBSI__quantity_shipped__c=qsh;
        qshp=line.PBSI__quantity_shipped__c;
        if (line.PBSI__quantity_shipped__c < 0 && l.PBSI__Quantity_Needed__c > 0)  line.PBSI__quantity_shipped__c=0;
         Double actquantreceived=line.PBSI__quantity_shipped__c;
           if (line.PBSI__Unit_Of_Measure__c != null)           {             PBSI__Unit__c unit;                    unit=[select id,PBSI__Quantity__c,Name from PBSI__Unit__c where Id=:line.PBSI__Unit_Of_Measure__c];             unitquant=unit.PBSI__Quantity__c;            originalunitquant=unit.PBSI__Quantity__c;         }
           if (l.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c == true || l.PBSI__Item__r.PBSI__Is_Service__c == true)  countInInventory=false; 
        if (soline.PBSI__Item__r.PBSI__Is_Serialized__c == true || (admin != null && admin.PBSI__Always_show_serial_number_on_pack_SO__c == true))        {            actquantreceived=line.PBSI__quantity_shipped__c*unitquant;            showSN=true;                InitSerialNumbers(Math.abs(actquantreceived));
        this.limitedSerials = CommonUtils.GetLimitedSerials(this.serialnumbers);            SetLineSerialsStyle();
        }
        if (l.PBSI__Bom_Type__c == 'BOM-Phantom')           islineBomPhantom=true;
            line.PBSI__Phantom_Bom__c=islineBomPhantom;       oldqty=line.PBSI__quantity_shipped__c*unitquant;        oldqtystage=stageline.pbsi__stage_quantity__c*unitquant;
        if (l.PBSI__Sales_Order__r.PBSI__From_Location__c != null && inv != null )
          for (PBSI__PBSI_inventory__c i: inv)
             if (i.PBSI__location_lookup__c == l.PBSI__Sales_Order__r.PBSI__From_Location__c)               {line.PBSI__lot__c=i.PBSI__lot__c;break;}
             
         if (line.PBSI__Lot__c == null && inv != null && inv.size() > 0) line.PBSI__Lot__c=inv[0].PBSI__Lot__c;
         inv=null;         admin=null;
    }
    
 
   
    public PackLineModel(PBSI__PBSI_Sales_Order_Line__c l,double qsh)
    {
    	 PBSI__Admin__c admin= PBSI__Admin__c.getOrgDefaults();         usecarton=false;         uselots=false;
         usePallets=(admin <> null && admin.PBSI__Use_Pallets__c);
                
        soline=l.clone(true,true);        this.itemname=l.PBSI__Item__r.name;        unitofmeasure=l.PBSI__Item__r.PBSI__defaultunitofmeasure__c;
        if (l.PBSI__Item_Description_Long__c != null)            this.itemDescr=l.PBSI__Item_Description_Long__c;
        else            this.itemDescr=l.PBSI__ItemDescription__c;
       
        line=new PBSI__Shipped_Sales_Order_Line__c(PBSI__item__c=l.PBSI__item__c,PBSI__sales_order__c=l.PBSI__sales_order__c,PBSI__sales_order_line__c=l.Id,PBSI__price__c=l.PBSI__price__c,PBSI__price4__c=l.PBSI__price4__c,PBSI__Discount__c=l.PBSI__Discount__c,PBSI__Unit_Of_Measure__c=l.PBSI__Unit_Of_Measure__c);
        if (UserInfo.isMulticurrencyOrganization() && Test.isRunningTest() == false)        {          line.put('CurrencyIsoCode',l.get('CurrencyIsoCode'));          line.put('PBSI__Exchange_Rate__c',l.get('PBSI__Exchange_Rate__c'));        }
        line.PBSI__quantity_shipped__c=qsh;
        if (line.PBSI__quantity_shipped__c < 0 && l.PBSI__Quantity_Needed__c > 0)  line.PBSI__quantity_shipped__c=0;
        this.isdropship=true;
    }
 
    public PackLineModel(PBSI__BOM_Depletion_Line__c l,PBSI__PBSI_Sales_Order_Line__c pline,PackLineModel parent,boolean usinglots,boolean usecartonarea,List<PBSI__PBSI_Inventory__c> inv)
    {     
       
    	 PBSI__Admin__c admin= PBSI__Admin__c.getOrgDefaults();
         usecarton=usecartonarea;         uselots=usinglots;
         usePallets=(admin <> null && admin.PBSI__Use_Pallets__c);
         assignInventory(inv);         this.parent=parent;         unitofmeasure=l.PBSI__Item__r.PBSI__defaultunitofmeasure__c;         bomdepline=l.clone(true,true);         soline=pline;
         line=new PBSI__Shipped_Sales_Order_Line__c(PBSI__BOM_Depletion_Line__c=l.Id,PBSI__item__c=bomdepline.PBSI__item__c,PBSI__sales_order__c=l.PBSI__sales_order__c,PBSI__sales_order_line__c=pline.Id,PBSI__price__c=l.PBSI__Item__r.PBSI__salesprice__c,PBSI__price4__c=l.PBSI__Item__r.PBSI__salesprice4__c,PBSI__Discount__c=soline.PBSI__Discount__c,PBSI__Discount1__c=soline.PBSI__Discount1__c,PBSI__Bill_of_Materials__c=bomdepline.PBSI__Bill_of_Materials__c);
         stageline=new PBSI__Staging_Order_Lines__c(pbsi__sales_order_line__c=pline.id,pbsi__sales_order__c=l.pbsi__sales_order__c,pbsi__stage_quantity__c=0,PBSI__item__c=bomdepline.PBSI__item__c,PBSI__bom_depletion_line__c=l.id);

        if (pline.pbsi__sales_order__r.PBSI__staging_location__c <> null)           stageline.PBSI__To_Location__c=pline.pbsi__sales_order__r.PBSI__staging_location__c;

         if (UserInfo.isMulticurrencyOrganization() && Test.isRunningTest() == false)        {            line.put('CurrencyIsoCode',pline.get('CurrencyIsoCode'));            line.put('PBSI__Exchange_Rate__c',pline.get('PBSI__Exchange_Rate__c'));        }
        itemname=l.PBSI__Item__r.name +'('+l.PBSI__BOM_Name__c+')';
        if (l.PBSI__Type__c != null)
        {
           itemname=l.PBSI__Item__r.name;
           
           if (l.PBSI__type__c == 'Remove') {itemname+='(Receive)';isShipping =false;line.PBSI__type__c='receive';}
                 else { itemname+='(Ship)'; line.PBSI__type__c='sale';}
        }
        
        if (l.PBSI__Item__r.PBSI__Not_Count_In_Inventory__c == true || l.PBSI__Item__r.PBSI__Is_Service__c == true)            countInInventory=false;
        
        itemDescr=l.PBSI__Item__r.PBSI__description__c;        Double q=parent.line.PBSI__quantity_shipped__c;        Double qst=parent.stageline.PBSI__stage_quantity__c;
        if (q <0)    q=0;
        if (qst < 0) qst=0;
        line.PBSI__quantity_shipped__c=q*(l.PBSI__Quantity__c/soline.PBSI__Quantity_Needed__c);        stageline.PBSI__stage_quantity__c=qst*(l.PBSI__Quantity__c/soline.PBSI__Quantity_Needed__c);
     
        if ((l.PBSI__Item__r.PBSI__Is_Serialized__c == true) || (admin != null && admin.PBSI__Always_show_serial_number_on_pack_SO__c == true))
        {
            showSn=true;            serialnumbers=new PBSI.SerialN[]{};         
            for (integer j=0;j < line.PBSI__quantity_shipped__c;j++)                serialnumbers.add(new PBSI.SerialN('')); 
         
            limitedSerials =CommonUtils.GetLimitedSerials(serialnumbers);            SetLineSerialsStyle();
        }
        
        itemcolor='color:blue';        oldqty=line.PBSI__quantity_shipped__c*unitquant;        oldqtystage=stageline.pbsi__stage_quantity__c*unitquant;        qshp=line.PBSI__quantity_shipped__c;
        
        if (l.PBSI__Sales_Order__r.PBSI__From_Location__c != null && inv != null )
          for (PBSI__pbsi_inventory__c i: inv)
             if (i.PBSI__location_lookup__c == l.PBSI__Sales_Order__r.PBSI__From_Location__c)             {                line.PBSI__lot__c=i.PBSI__lot__c;                break;             }
               
        if (line.PBSI__Lot__c == null && inv != null && inv.size() > 0)             line.PBSI__Lot__c=inv[0].PBSI__Lot__c;
        admin=null;
        
    }
    public decimal gettotalqty()    {    	return unitquant*line.PBSI__Quantity_Shipped__c;    }
    public void assignInventory(List<PBSI__PBSI_Inventory__c> inv)
    {
          for (PBSI__PBSI_Inventory__c i :inv)
          {
            string strname=i.PBSI__Lot__r.Name;            if (uselots) strname+='('+i.PBSI__location_lookup__r.Name +')';
            
            if (usecarton || usepallets)
            {
                invqty.put(i.id,i.pbsi__qty__c);
                if (usecarton)                strname+='-Area : '+i.PBSI__Area__c+';Carton : '+i.PBSI__Carton__c;
                if (usepallets)                if (i.PBSI__pallet__C <> null)                    strname+=' Pallet :'+i.PBSI__pallet__r.name;                else                    strname+=' Pallet : empty';
                invstrlotid.add(i.id);
            }
            else            {                invqty.put(i.pbsi__lot__c,i.pbsi__qty__c);                invstrlotid.add(i.pbsi__lot__c);            }
            invstr.add(strname);
      
          }     
    }
    
    // RI - updated for orgs that do not use default unit of measure as default but as primary instead.
    public list<Selectoption> getuom() {
    	
    	PBSI__Admin__c admin = PBSI__Admin__c.getOrgDefaults();        list<SelectOption> opts = new list<SelectOption>();        boolean dontusedefuom = (admin != null && admin.PBSI__Do_Not_Use_Default_Unit_Of_Measure__c);	    map<id, PBSI__Unit__c> unitsmap = new map<id,PBSI__Unit__c>();
        if (units != null) {	        unitsmap = new map<id,PBSI__Unit__c>(units);        }
        
        if (unitsmap != null && !unitsmap.isEmpty()) {
        	if (dontusedefuom) {
	        	for (PBSI__Unit__c u : unitsmap.values()) {
	        		if (u.Name != null && u.Name != '' && u.Name == unitofmeasure) {	          			opts.add(new Selectoption(u.id, u.name));	          			unitsmap.remove(u.id);	          			break;	        		}
	        	}
        	} else {
        		opts.add(new SelectOption('', unitofmeasure));
        	}
        	
        	for (PBSI__Unit__c u : unitsmap.values()) {
        		if (u.Name != null && u.Name != '' && u.Id != null) {          			opts.add(new Selectoption(u.id, u.name));        		}
        	}
        }
		if (opts.size() < 1) {        	opts.add(new SelectOption('', unitofmeasure));        }
        return opts;
    }
	
      private void InitSerialNumbers(Double actquantreceived)
    {
         this.serialnumbers = new PBSI.SerialN[]{};
         for (integer j=0;j<actquantreceived;j++)         {            this.serialnumbers.add(new PBSI.SerialN(''));         }
    }
   public boolean getinvNotNeeded(){return (CountInInventory == false || isdropship == true  || islineBomPhantom == true);}

    public void SetLineSerialsStyle()
    {
        if(serialnumbers.size() > 5)            serialsDivStyle = 'height: 100px;padding-top: 5px;overflow: auto;overflow-x: hide;';
        else            serialsDivStyle = '';
    }
   

    

 
   public void assignSerialNumbers(boolean stage)
   {
       line.PBSI__Serial_Numbers__c='';       line.PBSI__Parent_Serial_Numbers__c='';       stageline.PBSI__Serial_Numbers__c='';
        
        // RI - 11/27/2013 : Ascent4Salesforce MainAM-195 - Rental Security Review
        // Do not log sensitive data such as PII and secrets
        // system.debug('qqq='+serialnumbers);
       if (stage)
       {
       if (serialnumbers!= null)
         for (integer i=0;i<serialnumbers.size();i++)
         {
                if (stageline.PBSI__Serial_Numbers__c == null)                    stageline.PBSI__Serial_Numbers__c=serialnumbers[i].getValue();
                else                   stageline.PBSI__Serial_Numbers__c+=serialnumbers[i].getValue();
                
            if (i != serialnumbers.size()-1)
               if (serialnumbers[i+1].getValue()!='' && stageline.PBSI__Serial_Numbers__c!='')                      stageline.PBSI__Serial_Numbers__c+=';';
          }       	
       }
       else
        if (serialnumbers!= null)
         for (integer i=0;i<serialnumbers.size();i++)
         {
                if (line.PBSI__Serial_Numbers__c == null)                    line.PBSI__Serial_Numbers__c=serialnumbers[i].getValue();
                else                   line.PBSI__Serial_Numbers__c+=serialnumbers[i].getValue();
                
            if (i != serialnumbers.size()-1)
               if (serialnumbers[i+1].getValue()!='' && line.PBSI__Serial_Numbers__c!='')                      line.PBSI__Serial_Numbers__c+=';';
          }
          
          if (parent != null)
          {
              if (parent.serialnumbers != null)
                 for (integer i = 0; i< parent.serialnumbers.size(); i++)
                 {
                    if (line.PBSI__Parent_Serial_Numbers__c == null)                        line.PBSI__Parent_Serial_Numbers__c=parent.serialnumbers[i].getValue();
                    else                       line.PBSI__Parent_Serial_Numbers__c+=parent.serialnumbers[i].getValue();
                
                    if (i != parent.serialnumbers.size()-1)
                       if (parent.serialnumbers[i+1].getValue()!='' && line.PBSI__Serial_Numbers__c!='')
                           // WARNING (Elaine): changed serialnumbers with parent.serialnumbers
                       {
                           if(line.PBSI__Parent_Serial_Numbers__c != null)                               line.PBSI__Parent_Serial_Numbers__c+=';';
                       }
                }   
          }   
    }
    

      public List<SelectOption> getNegLot()
      {
    	PBSI__Admin__c admin= PBSI__Admin__c.getOrgDefaults();        options.clear();
        if (line.PBSI__quantity_shipped__c < 0)
        {
            
                id itemid=line.PBSI__item__c;       
                String basesoql='select Id,PBSI__Total_Quantity__c,Name,PBSI__Location__c,PBSI__location__r.Name from pbsi__lot__c where PBSI__item__c=:itemid and pbsi__location__r.PBSI__Available_for_Packing__c = false and pbsi__location__r.pbsi__Account__c = null ';
                
                if(admin == null || admin.PBSI__Use_Not_Counted_Loc_on_Receive_and_Pack__c == false)                   basesoql += ' and pbsi__location__r.PBSI__Count_in_Inventory__c = \'Yes\'';
                
                if (uselots)                    basesoql+=' and (PBSI__Expiration_Date__c > Today or PBSI__Expiration_Date__c=null) and PBSI__Lot_Status__c=\'Released\' ';
                else                    basesoql+=' and PBSI__Lot_For_Location__c =\'Yes\'';     
              
              String sorder=getsortorder();
               if (sorder == 'Name Ascending' ) basesoql+=' order by Name asc';
               else
               if (sorder == 'FIFO') basesoql+=' order by PBSI__Created_Date__c asc';
               else
               if (sorder == 'LIFO') basesoql+=' order by PBSI__Created_Date__c desc';
               else
               if (sorder == 'Highest Quantity') basesoql+=' order by PBSI__Total_Quantity__c desc';
              
                List<pbsi__lot__c> lots=Database.query(basesoql);
                for (pbsi__lot__c i:lots)
                            if (uselots)                             options.add(new SelectOption(i.id,i.Name+'('+i.PBSI__location__r.Name +')'+' Qty:'+i.PBSI__total_quantity__c));
                                  else                             options.add(new SelectOption(i.id,i.Name+'(Qty:'+i.PBSI__total_quantity__c+')'));
                                                
             if (options.size() == 0)    options.add(new SelectOption('','--None--'));  
             options.add(new SelectOption('','Other'));
            
        }
        return options;
      }
      
      public List<SelectOption> getLot() 
      {
           options.clear();
         
           if (isshipping)
           {  
                if (usecarton || usepallets) 
                {
                    options.add(new SelectOption('','Select One'));
                    
                     for (integer i=0;i<invstr.size();i++)                        options.add(new SelectOption(invstrlotid[i],invstr[i]+' Qty:'+invqty.get(invstrlotid[i])));
                }
                else
                    for (integer i=0;i<invstr.size();i++)                        options.add(new SelectOption(invstrlotid[i],invstr[i]+' Qty:'+lotsqty.get(invstrlotid[i])));
    
                if (options.size() == 0)                        options.add(new SelectOption('','--None--'));  
             
                if (oldlot == null)                     oldlot=options[0].getValue();                                  
            }                                      
            else
            {     
                List<PBSI__Lot__c> lotslist;                options.clear();
                
                lotslist = [Select 
                                Id, Name, PBSI__Item__c,PBSI__Location_Name__c 
                            From 
                                PBSI__Lot__c p 
                            where 
                               ( PBSI__Expiration_Date__c > Today or PBSI__Expiration_Date__c=null)
                            and 
                                PBSI__Lot_Status__c = 'Released' 
                            and 
                                PBSI__Item__c = :line.PBSI__item__c  
                            order by 
                                Name asc];
              
                if (lotslist.size() == 0)                       options.add(new SelectOption('','--None--'));
                for (PBSI__Lot__c ll:lotslist)                     options.add(new SelectOption(ll.Id,ll.Name+'('+ll.PBSI__Location_Name__c+')'));
                options.add(new SelectOption('','Other'));                  
        }
        
        return options;
   }
   
	public string getsortorder()
 	{
    	if (prop == null)            prop=[select PBSI__property_value__c,PBSI__property_name__c from PBSI__property__c where PBSI__property_name__C ='LotSortOrder' ];
    	if (prop.size() >0  ) return prop[0].PBSI__property_value__c;
    	return 'Name Ascending';
 	}
//is shipping equals false
	public List<SelectOption> getShipLot() 
      {
            List<SelectOption> options = new List<SelectOption>();                       options.add(new SelectOption('','--None--'));
           for (PBSI__Lot__c lot :[select Id,Name,PBSI__Location__c,PBSI__Location__r.Name from PBSI__Lot__c  where PBSI__Item__c =:line.PBSI__item__c and PBSI__Location__r.PBSI__Count_in_Inventory__c = 'No'])
             options.add(new SelectOption(lot.Id,lot.Name+'('+lot.PBSI__Location__r.Name+')'));                       
            options.add(new SelectOption('','Other'));                 return options;
      }

	public String getLocation()    {        if ( bomdepline  == null  && soline.PBSI__Location__c != null)            return soline.PBSI__Location__c;            return 'default';    }
}