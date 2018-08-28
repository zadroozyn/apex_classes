public class AccountApprovalService {

    private List<Account> baseList;

    public class ApprovalStartException extends Exception {}

    public static final String STATUS_IN_ACTIVATION_PROCESS = 'In Activation Process';
    public static final String STATUS_IN_DEACTIVATION_PROCESS = 'In Deactivation Process';
    public static final String STATUS_ACTIVE = 'Active';
    public static final String STATUS_INACTIVE = 'Inactive';
    public static final String STATUS_PROSPECT = 'Prospect';
    public static final String PROCESS_ACTIVATION_NAME = 'Account_Activation3';
    public static final String PROCESS_DEACTIVATION_NAME = 'Account_Deactivation3';
    public static final Set<String> TO_AUTO_APPROVAL_STATUSES = new Set<String> {STATUS_PROSPECT};
    public static final Set<String> SO_NOT_STARTING_PROCESS = new Set<String> {
        'Experience Shoes',
        'Test Shoe Set',
        'Warranty'
    };


    public static Set<Id> sApprovalRequiredRTs {
        get {
            if(sApprovalRequiredRTs == null) {
                sApprovalRequiredRTs = new Set<Id> {
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','Business_Customer'),
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','Dealer_Supplier'),
                    RecordTypeService.getRecordTypeIdByDeveloperName('Account','PersonAccount')
                };
            }
            return sApprovalRequiredRTs;
        }
        private set;
    }

    public AccountApprovalService(List<Account> lAccounts) {
        baseList = lAccounts;
    }

    public AccountApprovalService(Account acc) {
        baseList = new List<Account> {acc};
    }

    public void markIsApprovalRequired() {
        for(Account acc: baseList) {
            acc.Approval_Required__c = isApprovalRequired(acc);
        }
    }

    public void approveActivation() {
        setApprovedActivation(true);
    }

    public void revokeAcivationApproval() {
        setApprovedActivation(false);
    }

    public void approveDeactivation() {
        setApprovedDeactivation(true);
    }

    public void revokeDeacivationApproval() {
        setApprovedDeactivation(false);
    }

    public List<Approval.ProcessResult> startActivationProcess() {
        return startActivationProcess(false);
    }

    public List<Approval.ProcessResult> startActivationProcess(Boolean skipEntryCriteria) {
        List<Approval.ProcessResult> processStartResults = new List<Approval.ProcessResult>();
        List<Case> lApprovalCases = new List<Case>();
        for(Account acc: baseList) {
            lApprovalCases.add(
                createActivationApprovalCase(acc)
            );
        }
        if(!lApprovalCases.isEmpty()) {
            insert lApprovalCases;
            processStartResults = startApprovalProcess(PROCESS_ACTIVATION_NAME,lApprovalCases,
                skipEntryCriteria);
            Map<Id,Case> mapApprovalCases = new Map<Id,Case>(lApprovalCases);
            List<Account> lAccToLock = new List<Account>();
            List<Case> lCasesToDelete = new List<Case>();
            for(Integer i=0; i<processStartResults.size(); i++) {
                Approval.ProcessResult result = processStartResults[i];
                Case c = mapApprovalCases.get(result.getEntityId());
                if(result.isSuccess()) {
                    if(c != null) {
                        lAccToLock.add(
                            new Account(
                                Id = c.AccountId,
                                Status__c = STATUS_IN_ACTIVATION_PROCESS
                            )
                        );
                    }
                } else {
                    lCasesToDelete.add(lApprovalCases[i]);
                }
            }
            delete lCasesToDelete;
            update lAccToLock;
            Approval.lock(lAccToLock);
        }
        return processStartResults;
    }

    public List<Approval.ProcessResult> startDeactivationProcess() {
        return startDeactivationProcess(false);
    }

    public List<Approval.ProcessResult> startDeactivationProcess(Boolean skipEntryCriteria) {
        List<Approval.ProcessResult> processStartResults = new List<Approval.ProcessResult>();
        List<Case> lApprovalCases = new List<Case>();
        for(Account acc: baseList) {
            lApprovalCases.add(
                createDeactivationApprovalCase(acc)
            );
        }
        if(!lApprovalCases.isEmpty()) {
            insert lApprovalCases;
            processStartResults = startApprovalProcess(PROCESS_DEACTIVATION_NAME,lApprovalCases,
                skipEntryCriteria);
            Map<Id,Case> mapApprovalCases = new Map<Id,Case>(lApprovalCases);
            List<Account> lAccToLock = new List<Account>();
            List<Case> lCasesToDelete = new List<Case>();
            for(Integer i=0; i<processStartResults.size(); i++) {
                Approval.ProcessResult result = processStartResults[i];
                Case c = mapApprovalCases.get(result.getEntityId());
                if(result.isSuccess()) {
                    if(c != null) {
                        lAccToLock.add(
                            new Account(
                                Id = c.AccountId,
                                Status__c = STATUS_IN_DEACTIVATION_PROCESS
                            )
                        );
                    }
                } else {
                    lCasesToDelete.add(lApprovalCases[i]);
                }
            }
            delete lCasesToDelete;
            update lAccToLock;
            Approval.lock(lAccToLock);
        }
        return processStartResults;
    }

    private List<Approval.ProcessResult> startApprovalProcess(String processName, List<Case> lCases, 
        Boolean skipEntryCriteria) {

        List<Approval.ProcessSubmitRequest> processRequests = new List<Approval.ProcessSubmitRequest>();
        for(Case caseObj: lCases) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setSkipEntryCriteria(skipEntryCriteria);
            req.setObjectId(caseObj.Id);
            req.setSubmitterId(UserInfo.getUserId());
            req.setProcessDefinitionNameOrId(processName);
            processRequests.add(req);
        }
        return Approval.process(processRequests,false);
    } 

    private void setApprovedActivation(Boolean approved) {
        for(Account acc: baseList) {
            String newStatus;
            if(approved) {
                newStatus = STATUS_ACTIVE;
                acc.Activated_At_Least_Once__c = true;
            } else if(acc.Activated_At_Least_Once__c) {
                newStatus = STATUS_INACTIVE;
            } else {
                newStatus = STATUS_PROSPECT;
            }
            acc.Status__c = newStatus;
        }
        update baseList;
        Approval.unlock(baseList);
    }

    private void setApprovedDeactivation(Boolean approved) {
        for(Account acc: baseList) {
            String newStatus = approved ? STATUS_INACTIVE : STATUS_ACTIVE;
            acc.Status__c = newStatus;
        }
        update baseList;
        Approval.unlock(baseList);
    }

    private static Case createActivationApprovalCase(Account acc) {
        Case aCase = new Case(
            AccountId = acc.Id,
            RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Case','Account_Activation'),
            Subject = 'Account activation: '+acc.Name,
            Origin = 'Approval'
        );
        return aCase;
    }

    private static Case createDeactivationApprovalCase(Account acc) {
        Case dCase = new Case(
            AccountId = acc.Id,
            RecordTypeId = RecordTypeService.getRecordTypeIdByDeveloperName('Case','Account_Deactivation'),
            Subject = 'Account deactivation: '+acc.Name,
            Origin = 'Approval'
        );
        return dCase;
    }

    public static Boolean isApprovalRequired(Account acc) {
        return sApprovalRequiredRTs.contains(acc.RecordTypeId);
    }

}