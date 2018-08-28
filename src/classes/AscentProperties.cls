public with sharing class AscentProperties {
    
    public String DecimalPlaces{get;set;}
    public String TradeDecimalPlaces {get;set;}
    public String LotUsage {get;set;}
    public String LotSortOrder {get;set;}
    public String UseCarton {get;set;}
	
    private List<PBSI__Property__c> propertiesList;
    
	public AscentProperties() {
    	InitData();     
	}
	
	private void InitData() {
		DecimalPlaces = '4';
		TradeDecimalPlaces = '4';
		LotUsage = 'No';
		LotSortOrder = 'Name Ascending';
		UseCarton = 'No';
		
     	propertiesList = [SELECT PBSI__Property_Name__c, PBSI__Property_Value__c 
							FROM  PBSI__Property__c];
							
		for (PBSI__Property__c p:propertiesList) {
	        if (p.PBSI__Property_Name__c == 'DecimalPlaces')
	        	DecimalPlaces = p.PBSI__Property_Value__c;
	        	
	        else  if (p.PBSI__Property_Name__c == 'TradeDecimalPlaces') 
	        	TradeDecimalPlaces = p.PBSI__Property_Value__c; 
	        	
	        else  if (p.PBSI__Property_Name__c == 'Lot_Usage') 
	        	LotUsage = p.PBSI__Property_Value__c; 
	        	
	        else  if (p.PBSI__Property_Name__c == 'LotSortOrder') 
	        	LotSortOrder = p.PBSI__Property_Value__c; 
	        	
	        else  if (p.PBSI__Property_Name__c == 'UseCarton') 
	        	UseCarton = p.PBSI__Property_Value__c; 
		}
	}
}