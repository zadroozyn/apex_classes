public with sharing class SOLineWrapper {
  	
	public PBSI__PBSI_Sales_Order_Line__c SOLine {get;set;}
	public Double LineATP {get;set;}
	public Double QtyOnHand {get;set;}
	public Boolean OkForPack {get;set;}
	
	public SOLineWrapper(PBSI__PBSI_Sales_Order_Line__c line, Double atp, Double qoh) {     
		this(line, atp, qoh, true);
	}
	
	public SOLineWrapper(PBSI__PBSI_Sales_Order_Line__c line, Double atp, Double qoh, Boolean ok) {     
		SOLine = line;
		LineATP = atp;
		QtyOnHand = qoh;
		OkForPack = ok;
	}
}