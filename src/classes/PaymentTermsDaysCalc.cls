global class PaymentTermsDaysCalc implements Database.Batchable<sObject> {
	
	String query = 'SELECT Id,End_Next_Month__c,X90_Days_Month_End__c FROM On_Payment_Terms__c WHERE End_Next_Month__c = true OR X90_Days_Month_End__c = true';
	
	global PaymentTermsDaysCalc() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<On_Payment_Terms__c> scope) {
   		recalculateDaysToEndTerm(scope);
   		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	global void recalculateDaysToEndTerm(List<On_Payment_Terms__c> scope) {
		Integer daysToEndNextMonth = daysToEndNextMonth();
		Integer daysToEnd3Months = daysToEnd3Months();
		for(On_Payment_Terms__c pt: scope) {
			if(pt.End_Next_Month__c) {
				pt.Terms_Days__c = daysToEndNextMonth;			
			} else if(pt.X90_Days_Month_End__c) {
				pt.Terms_Days__c = daysToEnd3Months;
			}
		}
	}

	@testVisible
	private static Integer daysToEndNextMonth() {
		return daysToEndOfMonth(1);
	}

	@testVisible
	private static Integer daysToEnd3Months() {
		return daysToEndOfMonth(3);
	}

	private static Integer daysToEndOfMonth(Integer months) {
		return Date.today().daysBetween(Date.today().addmonths(months + 1).toStartOfMonth().addDays(-1));
	}
	
}