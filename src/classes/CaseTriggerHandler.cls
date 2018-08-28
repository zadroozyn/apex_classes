public class CaseTriggerHandler extends TriggerHandler {
	
	private static CaseTriggerHandler singleton;
    
    public static CaseTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new CaseTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    public static final String RT_ACCOUNT_ACTIVATION = 'Account_Activation';
    public static final String RT_ACCOUNT_DEACTIVATION = 'Account_Deactivation';

    private Map<String,Id> mapAccountApprovalRT {
    	get {
    		if(mapAccountApprovalRT == null) {
    			mapAccountApprovalRT = new Map<String,Id>{
    				RT_ACCOUNT_ACTIVATION => RecordTypeService.getRecordTypeIdByDeveloperName('Case',RT_ACCOUNT_ACTIVATION),
    				RT_ACCOUNT_DEACTIVATION => RecordTypeService.getRecordTypeIdByDeveloperName('Case',RT_ACCOUNT_DEACTIVATION)
    			};

    		}
    		return mapAccountApprovalRT;
    	}
    	set;
    }

    protected override void handleBeforeInsert() {
        copyHDEmail(Trigger.new);
    }

    protected override void handleAfterInsert() {
    	handleClosedAccountActivatedCases(filterAccountActivation(filterClosed(Trigger.new)));
    	handleClosedAccountDactivatedCases(filterAccountDeactivation(filterClosed(Trigger.new)));
    }

	protected override void handleAfterUpdate() {
        preventRejectWithoutComment(Trigger.oldMap,Trigger.newMap);
		handleClosedAccountActivatedCases(filterAccountActivation(filterClosed(Trigger.oldMap,Trigger.newMap)));
		handleClosedAccountDactivatedCases(filterAccountDeactivation(filterClosed(Trigger.oldMap,Trigger.newMap)));
    }   

    private void handleClosedAccountActivatedCases(List<Case> lCasesClosedActivation) {
    	List<Account> lAccountsToApprove = new List<Account>();
    	List<Account> lAccountsToReject = new List<Account>();
    	for(Case c: lCasesClosedActivation) {
    		if(c.AccountId != null) {
    			Account acc = new Account(
                    Id = c.AccountId,
                    Activated_At_Least_Once__c = c.Account_Was_Once_Active__c
                );
    			if(c.Status == 'Approved') {
    				lAccountsToApprove.add(acc);
    			} else if(c.Status == 'Declined') {
    				lAccountsToReject.add(acc);
    			}
    		}
    	}
    	AccountApprovalService approvalService = new AccountApprovalService(lAccountsToApprove);
        System.debug('!!!### lAccountsToApprove '+lAccountsToApprove);
    	approvalService.approveActivation();
    	approvalService = new AccountApprovalService(lAccountsToReject);
    	approvalService.revokeAcivationApproval();
    }

    private void handleClosedAccountDactivatedCases(List<Case> lCasesClosedDeactivation) {
    	List<Account> lAccountsToApprove = new List<Account>();
    	List<Account> lAccountsToReject = new List<Account>();
    	for(Case c: lCasesClosedDeactivation) {
    		if(c.AccountId != null) {
    			Account acc = new Account(
                    Id = c.AccountId,
                    Activated_At_Least_Once__c = c.Account_Was_Once_Active__c
                );
    			if(c.Status == 'Approved') {
    				lAccountsToApprove.add(acc);
    			} else if(c.Status == 'Declined') {
    				lAccountsToReject.add(acc);
    			}
    		}
    	}
    	AccountApprovalService approvalService = new AccountApprovalService(lAccountsToApprove);
    	approvalService.approveDeactivation();
    	approvalService = new AccountApprovalService(lAccountsToReject);
		approvalService.revokeDeacivationApproval();
    }

    private List<Case> filterAccountActivation(List<Case> lCases) {
    	return filterByRecordType(lCases,mapAccountApprovalRT.get(RT_ACCOUNT_ACTIVATION));
    }

    private List<Case> filterAccountDeactivation(List<Case> lCases) {
    	return filterByRecordType(lCases,mapAccountApprovalRT.get(RT_ACCOUNT_DEACTIVATION));
    }

    private List<Case> filterByRecordType(List<Case> lCases, Id rtId) {
    	return filterByRecordType(lCases, new Set<Id>{rtId});
    }

    private List<Case> filterByRecordType(List<Case> lCases, Set<Id> rtIds) {
        List<Case> lFiltered = new List<Case>();
        for(Case c: lCases) {
            if(rtIds.contains(c.RecordTypeId)) {
                lFiltered.add(c);
            }
        }
        return lFiltered;
    }

    private List<Case> filterClosed(List<Case> lCasesNew) {
    	List<Case> lClosed = new List<Case>();
    	for(Case c: lCasesNew) {
    		if(c.IsClosed) {
    			lClosed.add(c);
    		}
    	}
    	return lClosed;
    } 

    private List<Case> filterClosed(Map<Id,Sobject> mapCasesOld, Map<Id,Sobject> mapCasesNew) {
    	List<Case> lClosed = new List<Case>();
    	for(Id key: mapCasesNew.keySet()) {
    		Case caseOld = (Case) mapCasesOld.get(key);
    		Case caseNew = (Case) mapCasesNew.get(key);

    		if(caseNew.IsClosed && caseNew.IsClosed != caseOld.IsClosed) {
    			lClosed.add(caseNew);
    		}
    	}
    	return lClosed;
    }

    private void copyHDEmail(List<Case> lCasesNew) {
        for(Case c: lCasesNew) {
            c.HD_Team_Email__c = c.HD_email__c;
        }
    }

    private void preventRejectWithoutComment(Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
        List<Case> approvalCases = 
            filterByRecordType(
                newMap.values(),
                new Set<Id>(mapAccountApprovalRT.values())
        );
        Map<Id,sObject> newMapFiltered = new Map<Id,sObject>(approvalCases);
        Map<Id,sObject> oldMapFiltered = new Map<Id,sObject>();

        for(Id key: newMapFiltered.keySet()) {
            oldMapFiltered.put(key,oldMap.get(key));
        }

        if(!newMapFiltered.isEmpty() && !oldMapFiltered.isEmpty()) {
            sObjectMethods.preventApprovalStep(
                oldMapFiltered, newMapFiltered, 'Status', 'Declined', System.Label.Acc_Approval_Rejection_Error_No_Comment
            );
        }
    }

}