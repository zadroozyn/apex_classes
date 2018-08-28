public without sharing class BackstageShareService {

	private String reasonApiName;
	public final static Map<String, String> OBJ_NAME_TO_ACC_REF = new Map<String, String> {
		'PBSI__PBSI_Sales_Order__c' => 'PBSI__Customer__c',
		'c2g__codaInvoice__c' => 'c2g__Account__c',
		'c2g__codaCreditNote__c' => 'c2g__Account__c'
	};

	public BackstageShareService() {
		this('Portal_user_access__c');
	}

	public BackstageShareService(String reasonApiName) {
		this.reasonApiName = reasonApiName;
	}

	public List<sObject> createSharesForObjects(List<sObject> scope, Schema.sObjectType targetType) {
		String objName = String.valueOf(targetType);
		Map<Id, Set<Id>> acc2objects = this.convertToAccTree(scope, OBJ_NAME_TO_ACC_REF.get(objName));
		Map<Id, Set<Id>> acc2users = this.convertToAccTree([SELECT Id, AccountId FROM User WHERE AccountId IN : acc2objects.keySet() AND isActive = TRUE], 'AccountId');
		acc2objects.keyset().retainAll(acc2users.keyset());
		return this.createShares(acc2users, acc2objects, objName);
	}

	public List<sObject> createSharesForUsers(List<User> scope, Schema.sObjectType targetType) {
		String objName = String.valueOf(targetType);
		String accRef = OBJ_NAME_TO_ACC_REF.get(objName);
        Map<Id, Set<Id>> acc2users = convertToAccTree(scope, 'AccountId');
        Map<Id, Set<Id>> acc2objects = convertToAccTree(Database.query('SELECT Id, ' + accRef + ' FROM ' + objName + ' WHERE ' + accRef + ' IN (\'' + String.join(new List<Id>(acc2users.keyset()), '\',\'') + '\')'), accRef);
		acc2users.keyset().retainAll(acc2objects.keyset());
		return this.createShares(acc2users, acc2objects, objName);
	}

	private List<sObject> createShares(Map<Id, Set<Id>> users, Map<Id, Set<Id>> objects, String objName) {
		List<sObject> output = new List<sObject>();
        for(Id accId : users.keySet()) {
            output.addAll(ShareHandler.createShares(new List<Id>(users.get(accId)), new List<Id>(objects.get(accId)), ShareHandler.READACCESSLEVEL, objName, this.reasonApiName, false));
        }
		return output;
	}

	private Map<Id, Set<Id>> convertToAccTree(List<sObject> input, String accRef) {
		Map<Id, Set<Id>> output = new Map<Id, Set<Id>>();
		for(sObject current : input) {
			Id currentAccId = (Id) current.get(accRef);
			if(!output.containsKey(currentAccId)) {
				output.put(currentAccId, new Set<Id>());
			}
			output.get(currentAccId).add(current.Id);
		}
		return output;
	}
}