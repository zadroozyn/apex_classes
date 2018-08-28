public class AccountTriggerHandler extends TriggerHandler {
    private static AccountTriggerHandler singleton;
    
    public static AccountTriggerHandler Instance {
        get {
            if(singleton == null) {
                singleton = new AccountTriggerHandler();
            }
            return singleton;
        }
        private set;
    }

    private Id inactiveAccRT {
        get {
            if(inactiveAccRT == null) {
                inactiveAccRT = RecordTypeService.getRecordTypeIdByDeveloperName('Account','Inactive_Account');
            }
            return inactiveAccRT;
        }
        set;
    }

    private Features_enable_disable_settings__c features_settings {
        get {
            if(features_settings == null) {
                Map<String, Features_enable_disable_settings__c> mFeatureSettings = Features_enable_disable_settings__c.getAll();
                if (mFeatureSettings.containsKey('organisation_setting')) {
                    features_settings = mFeatureSettings.get('organisation_setting');
                } else {
                    features_settings = new Features_enable_disable_settings__c();
                }
            }
            return features_settings;
        }
        private set;
    }

    protected override void handleBeforeInsert() {
        setOnAgent(Trigger.new);
        if (features_settings.Enable_account_pefilling__c) {
            AccountMethods.assignDefaultValues(Trigger.new, false);
        }
        new AccountInvoiceService().assignNewInvoiceEmail((List<Account>)Trigger.new);
        accountApprovalHandler(Trigger.new);
    }
    
    protected override void handleBeforeUpdate() {
        setOnAgent(Trigger.new);
        if (features_settings.Enable_account_pefilling__c) {
            AccountMethods.assignDefaultValues(AccountMethods.getAccountsToActualize((Map<ID, Account>) Trigger.oldMap, (Map<ID, Account>) trigger.newMap), false);
        }
        new AccountInvoiceService().assignNewInvoiceEmail((List<Account>)Trigger.new);
        accountApprovalHandler(Trigger.new);
    }

    protected override void handleAfterInsert() {
        AccountMethods.validateEuroDealers(Trigger.new);
        accountDimensionHandler(Trigger.new);
        oscaHandler(Trigger.new);
    }

    protected override void handleAfterUpdate() {
        AccountMethods.validateEuroDealers(
            filterFieldsChanged(Trigger.oldMap, Trigger.newMap, new Set<String>{'pw_ccpro__BillingCountryLookup__c','PBSI__Account_Group__c'})
        );
        accountNameChangeHandler((Map<Id, Account>)Trigger.oldMap, (Map<Id, Account>)Trigger.newMap);
        oscaHandler(Trigger.oldMap, Trigger.newMap);
    }

    private void accountApprovalHandler(List<Account> lAccountsNew) {
        AccountApprovalService approvalService = new AccountApprovalService(lAccountsNew);
        approvalService.markIsApprovalRequired();
    }

    private void accountDimensionHandler(List<Account> accounts) {
        AccountDimension2Service service = new AccountDimension2Service(accounts);
        System.enqueueJob(service);
    }

    private void accountNameChangeHandler(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        AccountDimension2Service service = new AccountDimension2Service(oldAccounts, newAccounts);
        service.updateDimensionsName();
        service.saveDimensions();
    }

    private static List<SObject> filterFieldsChanged(Map<Id,SObject> mapAccountsOld, Map<Id,SObject> mapAccountsNew, Set<String> fNames) {
        List<SObject> lObjsChanged = new List<Account>();
        for(String key: mapAccountsOld.keySet()) {
            SObject objOld = mapAccountsOld.get(key);
            SObject objNew = mapAccountsNew.get(key);

            Boolean change = false;
            for(String fName: fNames) {
                if(objOld.get(fName) != objNew.get(fName)) {
                    change = true;
                    break;
                }
            }
            if(change) {
                lObjsChanged.add(objNew);
            }
        }
        return lObjsChanged;
    }

    private void oscaHandler(List<SObject> lSObjsNew) {
        OSCA_TriggerHandler.Instance.account().insertListener(lSObjsNew);
    }

    private void oscaHandler(Map<Id,SObject> mapAccountsOld, Map<Id,SObject> mapAccountsNew) {
        OSCA_TriggerHandler.Instance.account().updateListener(mapAccountsOld, mapAccountsNew);
    }

    private void setOnAgent(List<Account> accounts){
        AgentService ags = new AgentService();
        for(Account acc : accounts){
            if(acc.Agent_lookup__c != null){
                acc.Agent__c = ags.getAgentNameById(acc.Agent_lookup__c);
            }
        }
    }

}