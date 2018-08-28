public with sharing class EnhancedLine{
    
   public  PBSI__PBSI_Sales_Order_Line__c line{get;set;}
   public  Integer lineNumber{get;set;}
   public  Double qreserved{get;set;}
   public  Integer qonhand{get;set;}
   public  Double leadtime{get;set;}
   public String itemName{get;set;}
   public String itemId{get;set;}
   public String itemdescr{get;set;}
   public List<PBSI__Unit__c> itemUnits;
   public List<PBSI__Item_Version__c> itemVersions; 
   public PBSI__PBSI_Item__c item{get;set;}
   public String errorqty{get;set;}
   public boolean has0quant=true;
   public List<SelectOption> boms{get;set;}
   public Double atp{get;set;}
   public PBSI__BOM__c bom{get;set;} 
   public decimal atpbyloc{get;set;}
   public decimal atpbyloccalc{get;set;}
   public decimal atpbyloccalc2{get;set;}
   public Date atpdate{get;set;}
   public String actionTitle {get; set;}
    public boolean isSelected{get;set;}
    public Boolean isDeleted {get; set;}    
 public EnhancedLine(PBSI__PBSI_Sales_Order_Line__c line,Integer lineNumber,Double qres,Double atp,List<PBSI__Unit__c> units,List<PBSI__Item_Version__c> versions)
 {
   PBSI__Admin__c CS = PBSI__Admin__c.getOrgDefaults();    this.line=line;    this.lineNumber=lineNumber;
    if (line.PBSI__Item__c != null && line.Id != null) 
    {
            itemName=line.PBSI__Item__r.Name;
         
        leadtime=line.PBSI__Item__r.PBSI__Standard_Lead_Time__c;
      if (line.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c != null)
         if (leadtime == null)            leadtime=line.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c;
       else          leadtime+=line.PBSI__Item__r.PBSI__Standard_Lead_Time_for_PO_Receipt__c;
        if (line.PBSI__Item__r.PBSI__Quantity_on_Hand__c != null)    this.qonhand=line.PBSI__Item__r.PBSI__Quantity_on_Hand__c.intValue() ;
       
        
        if (CS != null && CS.PBSI__Use_Short_Item_Description__c == true) 
        {
        if (line.PBSI__Item__r.PBSI__Sales_Order_Description__c != null) itemdescr=line.PBSI__Item__r.PBSI__Sales_Order_Description__c;
        else
         itemdescr=line.PBSI__Item__r.PBSI__description__c;
        }
        else
        {
        if (line.PBSI__Item_Description_Long__c != null)         this.itemdescr=line.PBSI__Item_Description_Long__c;
               else  this.itemdescr=line.PBSI__ItemDescription__c;
        }
        
        if (cs != null && cs.PBSI__bom_versioning_enabled__c )
      if (line.PBSI__item__r.PBSI__item_type__c == 'BOM')
      {
       List<SelectOption>  options =new List<SelectOption>();
      
            for (PBSI__BOM__c b:[select PBSI__Default__c,id ,Name ,PBSI__version_number__c,PBSI__revision__c from PBSI__BOM__c where PBSI__Item__c =:line.PBSI__item__c order by createdDate])
           
            { 
              
              string s='';
          if (b.PBSI__version_number__c != null) s+=' '+b.PBSI__version_number__c;
          if (b.PBSI__revision__c != null) s+='.'+b.PBSI__revision__c;
          if (b.PBSI__default__c ) s+=' -Default';
           if (b.PBSI__default__c && options.size() > 0 && line.id == null)             options.add(0,new SelectOption(b.Id,b.Name+s));
             else             options.add(new SelectOption(b.Id,b.Name+s));
            }
            if (options.size() == 0 ) {options.add(new SelectOption('','--None--'));} 
           boms=options;
      }   
    }
  qreserved=qres;  this.atp=atp;  itemUnits=units;  itemVersions=versions;
          if(this.line.PBSI__Quantity_Picked__c != 0 && this.line.PBSI__TransactionType__c != 'credit')            actionTitle = 'Credit';
        else if(getShowDelete())            actionTitle = 'Delete';
 
       
 }
 public pagereference configure()
 {
   return new PageReference('/apex/PBSI__ItemConfigurator?itemid='+line.PBSI__Item__c+'&lineid='+line.Id+'&itemname='+line.PBSI__Item__r.Name+'&retUrl=c__ViewSoLines?id='+line.PBSI__Sales_Order__c);
   
 }
  public pagereference configureGroup()
 {
   return new PageReference('/apex/PBSI__ItemConfigurator?itemid='+line.PBSI__Item__c+'&lineid='+line.Id+'&itemname='+line.PBSI__Item__r.Name+'&retUrl=PBSI__viewsowithItemGroupSelection?id='+line.PBSI__Sales_Order__c);
   
 }
 public pagereference editLine()
 {
   ApexPages.standardController c=new ApexPages.Standardcontroller(line);   Pagereference p=c.edit();   p.getParameters().put('retUrl',line.PBSI__Sales_Order__c);    return p;
 }
 
  public List<SelectOption>  getVersion()
 {  
   List<SelectOption> options=new List<SelectOption>();
   options.add(new SelectOption('','--None--'));
    if (itemVersions != null)     for (PBSI__Item_Version__c itv:itemVersions) options.add(new SelectOption(itv.Id,itv.Name));
    return options;
 
 }
  public List<SelectOption> getUMS()
  {
  List<SelectOption> options=new List<SelectOption>();                         
  
    if (line.PBSI__Item__r.PBSI__defaultunitofmeasure__c != null)
                            options.add(new SelectOption('',line.PBSI__Item__r.PBSI__defaultunitofmeasure__c));
                            else
                           if (item != null)  options.add(new SelectOption('',item.PBSI__defaultunitofmeasure__c));
                           else
                           options.add(new SelectOption('','Default'));
                           
                         
                           
                           
  if (itemunits != null)
  for (PBSI__Unit__c u:itemunits)  options.add(new SelectOption(u.Id,u.Name));
  return options;
  }
  public pagereference  changePrice()
  {
                           if (line.PBSI__Unit_Of_Measure__c != null)
                           {
                             PBSI__Unit__c rightUnit;                               for (PBSI__Unit__c u:itemUnits)                                    if (u.Id == line.PBSI__Unit_Of_Measure__c) {rightUnit=u;break;}                               line.PBSI__Price__c=rightUnit.PBSI__Sale_Price__c;                                line.PBSI__Price4__c=rightUnit.PBSI__Sale_Price4__c;
                           }
                           else
                           {
                             if (line.PBSI__Item__c != null)
                             {
                              PBSI__PBSI_Item__c it=[select Id,PBSI__salesprice__c,PBSI__salesprice4__c from PBSI__PBSI_Item__c where Id=:line.PBSI__Item__c];                                line.PBSI__Price__c=it.PBSI__salesprice__c;                                line.PBSI__Price4__c=it.PBSI__salesprice4__c;
                             }
                           }
                           return null;
  }                      


public boolean getshowDelete()
{
if ( line.PBSI__Quantity_Picked__c !=  0)return false;return true;  
}
}