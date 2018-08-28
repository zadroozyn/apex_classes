global class AccountFinanceCalculationBatch implements Database.Batchable<sObject> {
	
	@testVisible
	private static Set<Id> sScopeRTs {
        get {
            if(sScopeRTs == null) {
                sScopeRTs = new Set<Id> {
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','Business_Customer'),
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','Dealer_Supplier'),
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','PersonAccount')
                };
            }
            return sScopeRTs;
        }
        private set;
    }

	private static final String QUERY = 
		'select id, Account_overdue_balance__c, Avg_days_overdue__c, Account_Balance_new__c '
		+ ' from Account '
		+ ' where recordtypeid IN :sScopeRTs ';
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	webservice static String executeForSingleAccount(Id accId) {
		Response res = new Response();
		AccountFinanceCalculationBatch batchClass = new AccountFinanceCalculationBatch();
		try {
			Account acc = [SELECT Id,Account_overdue_balance__c, Avg_days_overdue__c, Account_Balance_new__c
							FROM Account WHERE Id = :accId];
			batchClass.execute(null, new List<Account>{acc});
		} catch(Exception e) {
			res.isSuccess = false;
			res.errMsg = e.getMessage();
		}
		return JSON.serialize(res);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {

   		List<Account> accModified = new List<Account>();
   		Map<Id, List<c2g__codaTransactionLineItem__c>> allLinesMap = getMapAccId2Lines(scope);
		for(Account acc: scope) {
			Decimal newOverdueBalance = 0.0;
			Decimal newDaysOverdue = 0.0;
			Decimal newBalance = 0.0;
			List<c2g__codaTransactionLineItem__c> lines = allLinesMap.get(acc.Id);
            
			if(lines == null) {
				lines = new List<c2g__codaTransactionLineItem__c>();
			}
			for(c2g__codaTransactionLineItem__c lineItem: lines) {
				newOverdueBalance += replaceNullWithZero(lineItem.Document_Outstanding_Overdue_Value__c);
                
                Decimal tmpVal = replaceNullWithZero(lineItem.days_overdue_new__c);
				if(tmpVal > newDaysOverdue) {
					newDaysOverdue = tmpVal;
				}
                
				newBalance += replaceNullWithZero(lineItem.c2g__AccountOutstandingValue__c);
			}

			Boolean modified = false;
			if(newOverdueBalance != acc.Account_overdue_balance__c) {
				modified = true;
				acc.Account_overdue_balance__c = newOverdueBalance;
			}
			if(newDaysOverdue != acc.Avg_days_overdue__c) {
				modified = true;
				acc.Avg_days_overdue__c = newDaysOverdue;
			}
			if(newBalance != acc.Account_Balance_new__c) {
				modified = true;
				acc.Account_Balance_new__c = newBalance;
			}

			if(modified) {
				accModified.add(acc);
			}
		}
		Database.update(accModified,false);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	private static Map<Id, List<c2g__codaTransactionLineItem__c>> getMapAccId2Lines(List<Account> scope) {
		List<c2g__codaTransactionLineItem__c> allLines = 
		[select Id, Days_overdue_new__c, c2g__AccountOutstandingValue__c, c2g__Account__c,
				Document_Outstanding_Overdue_Value__c
			from c2g__codaTransactionLineItem__c where c2g__Account__c IN :scope and
				(days_overdue_new__c <> 0 or c2g__AccountOutstandingValue__c <> 0
				or Document_Outstanding_Overdue_Value__c <> 0)];
		Map<Id, List<c2g__codaTransactionLineItem__c>> linesMap = new Map<Id, List<c2g__codaTransactionLineItem__c>>();
		
		for(c2g__codaTransactionLineItem__c line: allLines) {
			if(linesMap.containsKey(line.c2g__Account__c)) {
				linesMap.get(line.c2g__Account__c).add(line);
			} else {
				linesMap.put(line.c2g__Account__c, new List<c2g__codaTransactionLineItem__c>{line});
			}
		}

		return linesMap;
	}

	private static Decimal replaceNullWithZero(Decimal d) {
		return d != null ? d : 0;
	}

	public class Response {
		Boolean isSuccess;
		String errMsg;

		public Response() {
			isSuccess = true;
			errMsg = '';
		}
	}
	
}