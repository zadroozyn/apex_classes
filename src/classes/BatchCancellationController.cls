public with sharing class BatchCancellationController implements Database.Batchable<sObject>, Database.Stateful {
	
	private PBSI__PBSI_Sales_Order__c so;
	private Boolean linesCancelled = false;
	private Boolean linesShipped = false;
	private String exMessage = null;
	
	public BatchCancellationController(ID soid, String cancellingReason) {
		
		so = 
			[SELECT ID, Name, PBSI__Status__c, Cancelling_Reason__c, SO_Cancel_Reason__c, 
				PBSI__Contact__c, SO_Cancellation_In_Progress__c, SO_Cancellation_Date_Time__c
	    	FROM PBSI__PBSI_Sales_Order__c
	    	WHERE Id =: soid][0];
	    	
	    if (so.SO_Cancellation_In_Progress__c) {
	    	DateTime check = DateTime.now().addMinutes(-5);
	    	if (check < so.SO_Cancellation_Date_Time__c) {
	    		throw new BatchCancellationException('Cancellation is already in progress!');
	    	}
	    }
	    
	    so.SO_Cancellation_In_Progress__c = true;
	    so.SO_Cancel_Reason__c = cancellingReason;
	    	
	    if (so.PBSI__Status__c == 'Cancelled') {
	    	throw new BatchCancellationException('This order is already cancelled!');
	    }
	    
	    if (so.PBSI__Status__c == 'closed') {
	    	throw new BatchCancellationException('You cannot cancel a closed order!');
	    }
	    
	    if (so.SO_Cancel_Reason__c == null) {
	    	throw new BatchCancellationException('Please selet a cancelling reason!');
	    }
		
	    so.SO_Cancellation_Date_Time__c = DateTime.now();
	    update so;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
	    
		return Database.getQueryLocator(
			'SELECT Id, Name, PBSI__Sales_Order__c, PBSI__Line_Status__c, PBSI__Closed__c, ' +
			'PBSI__Cancelled__c, Cancelling_Reason__c, PBSI__Quantity__c, PBSI__Item__c, ' +
			'PBSI__Quantity_Needed__c, PBSI__Quantity_Picked__c, PBSI__Quantity_Cancelled__c, PBSI__Quantity_Closed__c ' + 
			'FROM PBSI__PBSI_Sales_Order_Line__c ' + 
			'WHERE PBSI__Sales_Order__c = \'' + so.ID + '\'');
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		List<PBSI__PBSI_Sales_Order_Line__c> solines = (List<PBSI__PBSI_Sales_Order_Line__c>)scope;
		List<PBSI__PBSI_Sales_Order_Line__c> solinesToUpdate = new List<PBSI__PBSI_Sales_Order_Line__c>();
		
		for (PBSI__PBSI_Sales_Order_Line__c soline : solines) {
			if (soline.PBSI__Line_Status__c == 'open' || soline.PBSI__Line_Status__c == 'back ordered') {
				
				if (soline.PBSI__Quantity_Picked__c == null || soline.PBSI__Quantity_Picked__c == 0) {
					soline.PBSI__Cancelled__c = true;
					soline.Cancelling_Reason__c = so.SO_Cancel_Reason__c;
					solinesToUpdate.add(soline);
					
				} else {
					linesShipped = true;
					soline.PBSI__Closed__c = true;
					solinesToUpdate.add(soline);
				}
				
			} else {
				if (soline.PBSI__Line_Status__c != 'Cancelled') {
					linesShipped = true;
					soline.PBSI__Closed__c = true;
					solinesToUpdate.add(soline);
				}
			}
		}
		
		/* Ascent - temp workaround until Ascent Release 2.17
		if (solinesToUpdate.size() > 0) {
			linesCancelled = true;
			update solinesToUpdate;
		} */
		if (solinesToUpdate.size() > 0) {
			linesCancelled = true;
			PBSI__PBSI_Sales_Order_Line__c newsoline = solinesToUpdate[0].clone(false, true, false, false);
			
			newsoline.PBSI__Quantity_Picked__c = 0;
			newsoline.Cancelling_Reason__c = '';
			newsoline.PBSI__Cancelled__c = false;
			newsoline.PBSI__Closed__c = false;
			
			insert newsoline;
			try {
				update solinesToUpdate;
			} catch (Exception ex) {
				exMessage = ex.getMessage();
				system.debug(exMessage);
			}
			delete newsoline;
		}
		/* Ascent - temp workaround until Ascent Release 2.17 */
	}
	
	public void finish(Database.BatchableContext BC) {
		
		so = 
			[SELECT ID, Name, PBSI__Status__c, Cancelling_Reason__c, SO_Cancel_Reason__c, 
            	SO_Cancellation_Failure__c, SO_Cancellation_In_Progress__c, SO_Cancellation_Date_Time__c 
	    	FROM PBSI__PBSI_Sales_Order__c
	    	WHERE Id =: so.Id][0];
        String originalStatus = so.PBSI__Status__c;
	    	
	    so.SO_Cancellation_In_Progress__c = false;
	    so.SO_Cancellation_Failure__c = exMessage;
		update so;
	    
		if (exMessage == null) {
			if (!linesShipped) {
				so.PBSI__Status__c = 'Cancelled';
				so.Cancelling_Reason__c = so.SO_Cancel_Reason__c;
				
			} else {
				so.PBSI__Status__c = 'closed';
			}
		
			try {
				update so;
			} catch (Exception ex) {
				exMessage = ex.getMessage();
				system.debug(exMessage);
			    
                so.PBSI__Status__c = originalStatus;
                so.Cancelling_Reason__c = null;
			    so.SO_Cancellation_In_Progress__c = false;
			    so.SO_Cancellation_Failure__c = exMessage;
				update so;
			}
		}
	}
}