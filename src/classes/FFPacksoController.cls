public with sharing class FFPacksoController extends PageControllerBase{
	public boolean UpdateQuant {get;  set;}
	public Pagereference UpdateQuants() 	{ if (mypack != null) mypack.updateQuants = UpdateQuant; return null;}
	public PackSoControllerOn mypack {get;set;}
    public PBSI__PBSI_Sales_Order__c so{get;set;}
  	public FFPacksoController(ApexPages.StandardController c)  	{  		so=(PBSI__PBSI_Sales_Order__c)c.getRecord();   	}
  
	public override void setComponentController(ComponentControllerBase compController) {    	mypack = (PackSoControllerOn)compController;	}
  	public override ComponentControllerBase getMyComponentController() {      return mypack;  	}
 	public Pagereference savepacked() 	{   		update so;	     	mypack.savepacked();     	return null; 	}
 	public Pagereference backtoso() 	{   		string  url='/'+so.Id;    	PageReference so=new PageReference(url);    	return so; 	 	}
 	public boolean getalertstatus()
    {
    	PBSI__Admin__c CS = PBSI__Admin__c.getOrgDefaults();        string fromtextarea;        string sostatus;		
        sostatus = so.PBSI__Status__c;
        if (CS != null && cs.PBSI__Prevent_So_Packing_if_Status_is__c != null)        	fromtextarea = cs.PBSI__Prevent_So_Packing_if_Status_is__c;
		if  (fromtextarea==null && so.PBSI__Status__c=='Cancelled')      		return true;
		if (fromtextarea!=null && sostatus!=null)		{			boolean result=fromtextarea.contains(sostatus);			if (result)	            	return true;            else            	return false;		}
      	return false;     
	}
 

}