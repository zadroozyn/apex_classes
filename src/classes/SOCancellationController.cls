public with sharing class SOCancellationController {
    
    public PBSI__PBSI_Sales_Order__c SO {get; set;}
    public String SaveValue {get; set;}
    
    private ID soid;
    private String failMessage;
    private Integer checkCount;
    
    public SOCancellationController(ApexPages.StandardController controller) {
    	
    	SaveValue = 'Save';
    	soid = controller.getId();
    	
    	failMessage = null;
    	checkCount = 0;
    	
    	try {
    		SO = [SELECT ID, Name, Cancelling_Reason__c, SO_Cancel_Reason__c FROM PBSI__PBSI_Sales_Order__c WHERE Id =: soid][0];
    		
    	} catch (Exception ex) {
    		failMessage = ex.getMessage();
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, failMessage));
    	}
    	
    	SO.SO_Cancel_Reason__c = SO.Cancelling_Reason__c;
    }
    
	public PageReference SaveChanges() {
		
		if (SO != null && SO.ID != null) {
			try {
				BatchCancellationController batchable = new BatchCancellationController(SO.ID, SO.SO_Cancel_Reason__c);
				Database.executeBatch(batchable, 200);
				
	    	} catch (Exception ex) {
	    		SaveValue = 'Save';
	    		failMessage = ex.getMessage();
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, failMessage));
	    	}
	    	
			SaveValue = 'Saving...';
		}
    	
    	return null;
	}
    
	public PageReference CheckBatch() {
		
		if (SaveValue != 'Saving...') {
			if (failMessage != null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, failMessage));
			}
			return null;
		}
		
    	try {
    		SO = 
    			[SELECT ID, Name, Cancelling_Reason__c, SO_Cancel_Reason__c, SO_Cancellation_In_Progress__c, SO_Cancellation_Date_Time__c, SO_Cancellation_Failure__c
    			FROM PBSI__PBSI_Sales_Order__c
    			WHERE Id =: SO.ID][0];
    		failMessage = null;
    		
    	} catch (Exception ex) {
    		failMessage = ex.getMessage();
    	}
    	
    	if (SO.SO_Cancellation_In_Progress__c) {
    		if (++checkCount > 20) {
    			
    			if (failMessage == null) {
    				failMessage = 'The operation timed out!';
    			}
    			
    			SaveValue = 'Save';
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, failMessage));
    		}
    		
    		return null;
            
        } else {
            if (SO.SO_Cancellation_Failure__c != null) {
                failMessage = SO.SO_Cancellation_Failure__c;
                
    			SaveValue = 'Save';
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, failMessage));
                
                return null;
            }
        }
    	
		return new PageReference('/' + SO.ID);
	}
    
	public PageReference CancelChanges() {
		
		if (SaveValue == 'Saving...') {
			return null;
		}
		
		return new PageReference('/' + soid);
	}
}