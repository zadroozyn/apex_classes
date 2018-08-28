public with sharing class ATPPlannerController extends PBSI.SortClass{

public PBSI__PBSI_Sales_Order_Line__c input{get;set;}
public PBSI__PBSI_Item__c item{get;set;}
public double atp{get;set;}
public double qoh{get;set;}
public List<GrdiLine> grlines{get;set;}
public double qohatlocation{get;set;}
public ATPPlannerController()
{
    input=new PBSI__PBSI_Sales_Order_Line__c();
}
public pagereference calculate()
{
    item=[select id, PBSI__description__c, PBSI__Quantity_on_Hand__c from PBSI__PBSI_Item__c where id=:input.pbsi__item__c];
    
  list<PBSI__PBSI_Inventory__c> invs=[select Id,pbsi__qty__c from PBSI__PBSI_Inventory__c 
       where PBSI__item_lookup__c =:input.pbsi__item__c
         and PBSI__location_lookup__c =:input.pbsi__location__c];
         
      qohatlocation=0;
      //qoh=qohatlocation;
      
      for (PBSI__PBSI_Inventory__c i:invs)
             qohatlocation+=i.pbsi__qty__c; 
    
    AggregateResult arqtyfromsolines=[select sum(PBSI__Quantity_Left_To_Ship__c) qty
                        from PBSI__PBSI_Sales_Order_Line__c 
                        where pbsi__sales_order__r.pbsi__from_location__c =:input.PBSI__Location__c
                        and pbsi__sales_order__r.pbsi__due_date__c <= :input.PBSI__Ship_Date1__c
                        and pbsi__item__C=:input.PBSI__Item__c
                        and PBSI__Quantity_Left_To_Ship__c > 0];
                        
                        
     double   qtyfromsolines=(double)arqtyfromsolines.get('qty');
              if (qtyfromsolines == null) qtyfromsolines=0;        
   AggregateResult  arqtyfrompoline=[Select  SUM(PBSI__Quantity_Left_To_Receive__c) qty
         from PBSI__PBSI_Purchase_Order_Line__c d  
         where pbsi__purchase_order__r.PBSI__Due_Date__c <= :input.PBSI__Ship_Date1__c
         and PBSI__Quantity_Left_To_Receive__c >0
         and PBSI__Item__c =:input.pbsi__item__c
         and pbsi__purchase_order__r.pbsi__delivery_location__c =:input.PBSI__Location__c]; 
      
      double   qtyfrompoline=(double)arqtyfrompoline.get('qty');    
           if (qtyfrompoline == null) qtyfrompoline=0;
                      
    AggregateResult arqtyfrompwo=[select sum(PBSI__Quantity_Left__c) qty from PBSI__Production_Work_Order__c 
                                where pbsi__item__c=:input.PBSI__Item__c
                                and PBSI__Quantity_Left__c > 0
                                and pbsi__location__c =:input.pbsi__location__c
                                and PBSI__Delivery_Date__c <= :input.PBSI__Ship_Date1__c ];
     
       double   qtyfrompwo=(double)arqtyfrompwo.get('qty');    
      if (qtyfrompwo == null) qtyfrompwo=0;                            
    AggregateResult arqtyfrombomcomponents=[select sum(PBSI__Quantity_Left__c) qty from PBSI__BOM_Depletion_Line__c
              where pbsi__item__C = :input.PBSI__Item__c
              and PBSI__Quantity_Left__c > 0
              and ((PBSI__Production_Work_Order__c <> null and PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c <= :input.PBSI__Ship_Date1__c AND PBSI__Production_Work_Order__r.pbsi__location__c =:input.pbsi__location__c) 
              OR (PBSI__Sales_Order__c <> null and pbsi__sales_order__r.pbsi__due_date__c <= :input.PBSI__Ship_Date1__c and pbsi__sales_order__r.pbsi__from_location__c =:input.PBSI__Location__c))
              ];                            
  
    double   qtyfrombomcomponents=(double)arqtyfrombomcomponents.get('qty'); 
    if (qtyfrombomcomponents == null) qtyfrombomcomponents=0;   
    
  atp=qohatlocation+qtyfrompoline+qtyfrompwo-qtyfromsolines-qtyfrombomcomponents;  
  if (atp < 0) atp=0;
    qoh=atp;
    
        grlines=new list<GrdiLine>();
        
           PBSI__Production_Work_Order__c [] pwos=[Select 
                                                      Id,Name, PBSI__Item__c,PBSI__Item__r.PBSI__defaultunitofmeasure__c,PBSI__Quantity_Left__c,PBSI__Item__r.PBSI__Not_Count_In_Inventory__c, PBSI__Status__c,PBSI__Delivery_Date__c 
                                                  from 
                                                      PBSI__Production_Work_Order__c
                                                  where 
                                                      (PBSI__Status__c='In Progress' or PBSI__Status__c ='Open') 
                                                      and PBSI__Quantity_Left__c >0 
                                                  and 
                                                       PBSI__Item__c=:item.Id
                                                     and pbsi__location__c =:input.pbsi__location__c 
                                                       ]; 
                                                       
        List<PBSI__PBSI_Item__c> items= [Select Id, 
         
                 (Select 
                      PBSI__Sales_Order__r.PBSI__Due_Date__c,Id,PBSI__Sales_Order__c,PBSI__Location__c,PBSI__Location__r.PBSI__Count_in_Inventory__c,PBSI__Sales_Order__r.Name,PBSI__SOAccount__c, Name, PBSI__Type__c, PBSI__Line_Status__c, PBSI__Estimated_Ship_Date__c,PBSI__Quantity_Left_To_Ship__c,PBSI__Unit_Of_Measure__c,PBSI__Unit_Of_Measure__r.PBSI__Quantity__c,PBSI__Unit_Of_Measure__r.Name
                  from 
                      PBSI__Sales_Order_Lines__r 
                  where 
                      PBSI__Line_Status__c = 'Open' and PBSI__TransactionType__c = 'sale' and PBSI__Sales_Order__r.PBSI__Status__c != 'Closed' and PBSI__Sales_Order__r.PBSI__Status__c !='Cancelled' and pbsi__sales_order__r.pbsi__from_location__c =:input.PBSI__Location__c
                  order by 
                      PBSI__Estimated_Ship_Date__c limit 1000)
                      
                      , 
                 
                 (Select  
                      PBSI__Purchase_Order__r.PBSI__Due_Date__c,pbsi__sales_order__r.PBSI__Due_Date__c,  pbsi__sales_order__r.pbsi__customer__c,pbsi__purchase_order__r.pbsi__account__c,Id,PBSI__Sales_Order__c,PBSI__Sales_Order__r.Name, PBSI__Purchase_Order__c,PBSI__Purchase_Order__r.Name, PBSI__Purchase_Order_Line__c, PBSI__Production_Work_Order__c,PBSI__Production_Work_Order__r.Name,PBSI__Type__c, PBSI__Quantity_Left__c, PBSI__Line_Status__c, PBSI__Estimated_Ship_Date__c ,pbsi__Sales_Order_Line__r.PBSI__Estimated_Ship_Date__c,pbsi__Production_Work_Order__r.PBSI__Delivery_Date__c,PBSI__Purchase_Order_Line__r.PBSI__Due_Date__c
                  from 
                      PBSI__BOM_Depletion_Line__r 
                  where
                  PBSI__Quantity_Left__c > 0
                      
                  
                 and ( PBSI__Purchase_Order_Line__r.PBSI__LineStatus__c ='Open'  
                 OR
                 (PBSI__Production_Work_Order__c <> null and PBSI__Production_Work_Order__r.PBSI__Delivery_Date__c <= :input.PBSI__Ship_Date1__c AND PBSI__Production_Work_Order__r.pbsi__location__c =:input.pbsi__location__c and  PBSI__Sales_Order_Line__r.PBSI__Line_Status__c ='Open' and PBSI__Sales_Order_Line__r.PBSI__TransactionType__c = 'sale' and pbsi__sales_order__r.pbsi__status__c <> 'Cancelled') 
                   OR (PBSI__Sales_Order__c <> null and pbsi__sales_order__r.pbsi__due_date__c <= :input.PBSI__Ship_Date1__c and pbsi__sales_order__r.pbsi__from_location__c =:input.PBSI__Location__c))
 
                  order by 
                       PBSI__Estimated_Ship_Date__c limit 500), 
                 (Select 
                       PBSI__Purchase_Order__r.PBSI__Due_Date__c,Id,PBSI__Purchase_Order__c,PBSI__Location__c,PBSI__Location__r.PBSI__Count_in_Inventory__c,PBSI__POAccount__c,PBSI__Purchase_Order__r.Name, Name, PBSI__LineStatus__c, PBSI__Due_Date__c,PBSI__Quantity_Left_To_Receive__c,PBSI__Unit_Of_Measure__c,PBSI__Unit_Of_Measure__r.PBSI__Quantity__c ,PBSI__Unit_Of_Measure__r.Name
                  from 
                       PBSI__Purchase_Order_Lines__r 
                  where  
                        PBSI__LineStatus__c = 'Open'  and  PBSI__Purchase_Order__r.PBSI__Status__c != 'Complete' and pbsi__purchase_order__r.pbsi__delivery_location__c =:input.PBSI__Location__c
                  order by 
                        PBSI__Due_Date__c limit 1000) 
                  from 
                        PBSI__PBSI_Item__c p 
                  where 
                        p.Id =: item.Id limit 1];
         
         
           for (PBSI__PBSI_Item__c it:items)   
           {            
           for(PBSI__PBSI_Purchase_Order_Line__c poline : it.PBSI__Purchase_Order_Lines__r)
           {
              GrdiLine g=new GrdiLine();
              g.source=poline.pbsi__purchase_order__r.Name;
              g.sign='+';
              g.sourceid=poline.pbsi__purchase_order__c;
              g.dateexpected=poline.pbsi__purchase_order__r.pbsi__due_date__c;
              g.qty=poline.PBSI__Quantity_Left_To_Receive__c;
              grlines.add(g);
              
           }                
           for(PBSI__PBSI_Sales_Order_Line__c soline : it.PBSI__Sales_Order_Lines__r)
           {
              GrdiLine g=new GrdiLine();
              g.source=soline.pbsi__sales_order__r.Name;
              g.sign='-';
              g.sourceid=soline.pbsi__sales_order__c;
              g.dateexpected=soline.pbsi__sales_order__r.pbsi__due_date__c;
              g.qty=soline.PBSI__Quantity_Left_To_Ship__c;
              grlines.add(g);           
           }
           
           
            for(PBSI__BOM_Depletion_Line__c bomline : it.PBSI__BOM_Depletion_Line__r)
             {
                 GrdiLine gl=new GrdiLine();
                 
                 if (bomline.PBSI__Sales_Order__c !=null) 
                 {
                    
                    gl.source=bomline.PBSI__Sales_Order__r.Name;
                    gl.sign='-';
                    gl.sourceid=bomline.PBSI__Sales_Order__c;
                  
                    gl.dateexpected=bomline.PBSI__Sales_Order__r.pbsi__due_date__c;
                    gl.qty=bomline.PBSI__Quantity_Left__c;
                    
                }
                else if (bomline.PBSI__Purchase_Order__c != null) 
                {
                    
                    gl.source=bomline.PBSI__Purchase_Order__r.Name;
                    gl.sign='-';
                    gl.sourceid=bomline.PBSI__Purchase_Order__c;
                  
                    gl.dateexpected=bomline.PBSI__Purchase_Order__r.PBSI__Due_date__c;
                    gl.qty=bomline.PBSI__Quantity_Left__c;
                    
                                        
                  
                }
                else if (bomline.PBSI__Production_Work_Order__c != null) 
                {
                    gl.source=bomline.PBSI__Production_Work_Order__r.Name;
                    gl.sign='-';
                    gl.sourceid=bomline.PBSI__Production_Work_Order__c;
                  
                    gl.dateexpected=bomline.PBSI__Production_Work_Order__r.PBSI__Delivery_date__c;
                    gl.qty=bomline.PBSI__Quantity_Left__c;
                    
                                        
                }
                if (gl != null)
                {
                

                    grlines.add(gl);
                }
          }
          
          
    
         
           }
           
             for (PBSI__Production_Work_Order__c pwo:pwos)
        {    
            
              GrdiLine g=new GrdiLine();
              g.source=pwo.Name;
              g.sign='+';
              g.sourceid=pwo.Id;
              g.dateexpected=pwo.PBSI__Delivery_Date__c;
              g.qty=pwo.PBSI__Quantity_Left__c;
              grlines.add(g);                   
            
          
         } 
    List<GrdiLine> tmp=new GrdiLine[grlines.size()];
    m_sort(grlines,tmp,0,grlines.size()-1,'dateExpected',true); 
     double atpforl=qohatlocation;
     for (GrdiLine g:grlines)
     {
        if (g.sign == '+')  {g.atp=atpforl+g.qty; atpforl=g.atp;}
        else
        if ( g.qty <> null && atpforl <> null)
        {g.atp=atpforl-g.qty; atpforl=g.atp;}
        if (g.atp <0) g.atp=0;
     }
    
    return null;                    
}

public class GrdiLine implements PBSI.SortingLine
{
    public string source{get;set;}
    public double qty{get;set;}
    public double invamount{get;set;}
    public string sign{get;set;}
    public Date dateExpected{get;set;}
    public Id sourceid{get;set;}
    public double atp{get;set;}
    public  boolean compareTo(PBSI.SortingLine right,String coltocompare,Boolean ascending)
{
    GrdiLine r=(GrdiLine)right;
    
      if (coltocompare == 'dateExpected')
    {
        if (ascending)
      return (dateExpected <= r.dateExpected ) ;
     else
      return (dateExpected >= r.dateExpected ) ;
    }
  
    
    
   return false;     
  
}
}

}